---
name: pr-review-loop
description: "Multi-agent pull request review loop (Claude Code and OMP/Gemini): first review, complementary review of another agent's threads, fixing every thread, and the final merge-readiness check. Use for /pr-review-loop <review|fix|final> <PR>, or whenever asked to review a PR, complement or validate another reviewer's threads, fix PR review comments, or say whether a PR can be merged."
---

# PR review loop

One loop, several agents, GitHub as the only shared state. Any agent (Claude
Code: `/pr-review-loop`, OMP: `/skill:pr-review-loop`) can run any phase; the
phase reads what the previous agents left on the PR, so no agent needs another
one's session.

```
review (1st agent) -> review (2nd agent complements) -> fix -> final
                                                ^                  |
                                                +---- not ready ---+
```

Arguments: `<phase> <PR number or URL> [notes]`. Phase defaults to `review`.
The notes are the user's focus for this run; they never widen what may be
published or pushed.

## Rules for every phase

1. **Context first.** Read the repository's agent rules (`AGENTS.md`,
   `CLAUDE.md`, `GEMINI.md`, and the docs they point to) before judging or
   changing code. Project rules override this skill; this skill never relaxes
   them (no lowered thresholds, no skipped checks, no commits the project
   forbids).
2. **Load the PR state** with
   `python3 <skill-dir>/scripts/pr_context.py <PR>`: metadata, the stack (the
   PR it merges into and the PRs that merge into it), the valid diff lines and
   every review thread. `<skill-dir>` is the folder of this file.
3. **Judge against the final code of the stack**, not only this PR's diff: a
   point already fixed by a PR stacked on top is reported as such, not opened
   again. See "Stacked PRs" in `references/github.md`.
4. **What to look for and how to grade it** is in `references/rubric.md`:
   architecture of the project, functionality, security, clean code, DRY,
   KISS, design patterns, contracts, data and tests.
5. **Nothing leaves the machine without the user's yes**: publishing threads,
   replying, resolving, committing, pushing and merging each need an explicit
   approval in this conversation. Ask once per phase for the whole bundle
   (for example "publish these 6 threads?" or "commit, push, reply and
   resolve?"), never per item. Never approve or request changes on GitHub:
   reviews are always `COMMENT`.
6. **Write to the user in their language.** Write PR comments in the PR's
   language (its title and body).
7. **Report what was verified and what was not**: commands run with their
   result, and anything left unverified (CI not checked yet, a path not run).

## Phase `review`

Use it for the first review and for complementing another agent's review; the
existing threads decide which.

1. Summarize the PR's intent in one or two sentences.
2. Read every changed file and what it imports or is imported by. Trace the
   application code for bugs first; review tests only for wrong or empty
   assertions.
3. **If there are threads already**, give each one a verdict before looking
   for more:
   - **makes sense**: keep it;
   - **makes sense with an adjustment**: say what changes in the fix;
   - **does not make sense**: say why, with the code that proves it;
   - **already fixed in the stack**: name the PR and commit.
     Also correct factual mistakes in their review summary, if any.
4. Look for new points the existing threads do not cover. Never repeat one: if
   a new point extends an open thread, say so in the new comment.
5. Bring the consolidated list to the user, before publishing anything:
   - verdicts of the existing threads;
   - a table of new threads: file:line, severity, one-line point;
   - what was considered and left out, and why;
   - what was not verified.
6. On the user's yes, publish one review with
   `python3 <skill-dir>/scripts/post_review.py <PR> <review.json>`. The script
   refuses lines outside the diff before anything is posted; move such a
   comment to the nearest changed line instead of dropping it. The comment
   format is in `references/github.md`.

## Phase `fix`

1. Load every unresolved thread and triage each one: fix, already fixed (point
   to the commit), or push back with the technical reason. Nothing is fixed
   blindly: check the claim against the code first.
2. **Pick the branch to fix on** (see "Stacked PRs"): when PRs stacked on top
   rewrite the same code, fix on the topmost branch that merges into this PR,
   so the merge does not conflict. Say which branch and why.
3. Fix the cause in the owner the project rules name. Every changed behavior
   gets a test that proves it; keep coverage where the project requires it.
4. Run the project's canonical gate (from its agent rules; for example
   `pnpm validate`) and the changed path itself. If a fix would change a public
   contract, measure the compatibility impact and pick the option with the
   smallest break; explain the choice in the thread.
5. Bring to the user: what changed per thread, the gate result and the
   branch. Ask once to commit, push, reply and resolve.
6. On yes: commit (Conventional Commits, the project's attribution rules),
   push, reply to every thread with the commit link and what changed (or why
   not), and resolve the threads that were fixed or already fixed. A thread
   that was pushed back stays open for the reviewer.

## Phase `final`

The merge-readiness check. Trust nothing a previous agent wrote: replies and
resolved threads are claims.

1. For every thread (resolved included), open the code at the head of the
   branch that will be merged and confirm the fix is really there and correct.
   A reply without the change in the code is a blocker.
2. Review the commits added since the last review as in the `review` phase.
3. Check CI on the head commit: green, or failing only in ways the PR body
   documents and that need a reviewer's acceptance (say exactly which). An
   undocumented failure is a blocker. Never call CI green without reading it.
4. For a stack, confirm the merge order and the merge method (see "Stacked
   PRs").
5. Give a verdict: **ready to merge**, or **not ready** with the list of
   blockers. New non-blocking points go to the user as optional, and get
   published only on their yes, as in `review`.
6. Never merge. The user merges, or asks for it explicitly.
