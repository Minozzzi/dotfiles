# GitHub mechanics

Everything goes through the `gh` CLI, authenticated as the user, so it works
the same in Claude Code and OMP. Comments are posted under the user's account:
the hidden marker below is the only way to tell which agent wrote a thread.

## Reading the PR

`python3 <skill-dir>/scripts/pr_context.py <PR> [--repo owner/name]` prints
JSON with:

- `pr`: title, body, state, base and head branches, head commit, merge state;
- `stack`: `mergesInto` (the open PR whose head is this base, if any) and
  `mergedIntoThis` (open PRs whose base is this head);
- `diffLines`: for each changed file, the lines a comment may use, per side
  (`RIGHT` added lines, `LEFT` removed lines);
- `threads`: every review thread, with `id`, `isResolved`, `isOutdated`,
  `path`, `line`, `diffSide`, the root comment `databaseId` (to reply) and all
  comments with author, the hidden `agent` marker and body;
- `checks`: the CI checks of the head commit.

The full diff: `gh pr diff <PR>`. A file as the PR head has it:
`git show <head-ref>:<path>` after `git fetch origin <head-ref>`.

## Publishing a review

Write a JSON file and run
`python3 <skill-dir>/scripts/post_review.py <PR> <review.json> [--dry-run]`:

```json
{
  "agent": "claude",
  "body": "## 📋 Review Summary\n...\n\n## 🔍 General Feedback\n- ...",
  "comments": [
    {
      "path": "src/a.ts",
      "line": 42,
      "start_line": 38,
      "side": "RIGHT",
      "body": "[MEDIUM] ..."
    }
  ]
}
```

- `start_line` is optional (multi-line comment). `side` defaults to `RIGHT`.
- The script validates every line against the diff and posts nothing when
  one is invalid; it prints the nearest valid lines to move the comment to.
- It posts one review with event `COMMENT` on the current head commit and
  adds the hidden `<!-- pr-review-loop: agent=<agent> -->` marker to every
  comment and to the body.

Comment body: `[SEVERITY] <the point, the failure scenario or cost, the fix>`
followed, when exact, by a GitHub suggestion block:

````
```suggestion
<replacement for exactly the commented lines>
```
````

Summary body:

```
## 📋 Review Summary

<2-3 sentences: objective and quality of the PR.>

## 🔍 General Feedback

- <observations not suited to an inline comment, without repeating them>
```

## Replying and resolving

- Reply to a thread (use the root comment `databaseId`):
  `gh api -X POST repos/<owner>/<repo>/pulls/<PR>/comments/<id>/replies -f body="..."`
- Resolve a thread (use the thread `id`):
  `gh api graphql -f query='mutation{resolveReviewThread(input:{threadId:"<id>"}){thread{isResolved}}}'`
- A reply names the commit as a link
  (`https://github.com/<owner>/<repo>/pull/<PR>/commits/<sha>`) and says what
  changed, or why the point was not taken.

## Stacked PRs

A stack is a chain of PRs where each one's base is the previous one's head
branch (`main <- A <- B <- C`).

- **Where to fix.** Code reviewed on A is often rewritten by B or C. Fixing on
  A would conflict when B merges into it. Fix on the topmost branch that
  rewrites the same code (often the top of the stack), and reply on A's
  threads with that commit: the fix reaches A when the stack merges down.
  Until then A's own branch still has the old code: say so to the user.
- **Already fixed.** Before opening a thread on A, check the same code at the
  top of the stack (`git show <top-head>:<path>`). Fixed there means "already
  fixed in <PR>", not a new thread.
- **Merge order.** Merging top-down (C into B, B into A, A into main) keeps
  main from ever holding a half-built feature. Use a merge commit, not
  squash, at least for the last step, so each story keeps its own commits.
  Wait for CI on each target branch before merging it down. Bottom-up
  (A into main, retarget B) gives each PR its own CI against main, but only
  when main may hold A alone.
- **CI on a stack.** A check that compares with the base (for example API
  compatibility) runs against the stacked base, not main; failures inherited
  from a lower PR are expected only when that PR documents them.
