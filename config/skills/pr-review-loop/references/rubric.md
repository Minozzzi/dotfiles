# Review rubric

## What to look for

Read the code as a principal engineer who owns it after the merge. In order of
weight:

1. **Functionality.** Does it do what the PR says, for every input the
   contract allows? Edge cases, off-by-one, null or empty, races, retries and
   repeated delivery (webhooks, jobs, reconnections), error paths, partial
   writes, invariants the code relies on but nothing enforces.
2. **Security.** Authorization on every operation (never trust ids, rooms or
   origins sent by the client), data leaks in responses, logs and errors,
   injection, secrets, and weakened checks or gates.
3. **Architecture of the project.** Is each rule in the module the project
   rules say owns it? Module boundaries (who reads whose tables), dependency
   direction, no second convention for a problem the code already solves,
   public contracts derived the way the project derives them.
4. **Data and contracts.** Migrations (additive, reviewed, never editing an
   applied one), constraints and transactions where an invariant needs them,
   backward compatibility of the public contract, how precisely the contract
   describes what the code really returns.
5. **Clean code, DRY, KISS, design patterns.** The same decision made in
   several places, the third copy of a query or rule, branching that a single
   resolver or strategy would remove, names that lie, comments that disagree
   with the code, abstractions with one caller and no reason.
6. **Efficiency.** Queries that always return nothing, N+1 reads, work held
   inside a lock or transaction that could happen outside it, hot paths (what
   every player or request calls).
7. **Tests.** Only major problems: assertions that cannot fail, a setup step
   whose failure would make the test pass anyway, changed behavior with no
   test, coverage the project requires.

## Severity

- **CRITICAL**: security hole, data loss, system-breaking bug.
- **HIGH**: functional bug against the PR's intent, resource leak, N+1 or
  similar bottleneck, major architectural violation.
- **MEDIUM**: missing validation, wrong user-facing text, logic that could be
  much simpler, module boundary or DRY problem with a real maintenance cost.
- **LOW**: naming, constants, comments out of date, small query savings, test
  quality, documentation.

## What makes a comment worth opening

- Only on lines the PR changed (`+` lines, or `-` lines on the left side).
- Only for a demonstrable bug, risk or a significant improvement, with the
  failure scenario or the cost stated.
- One issue per comment; if it repeats, say where else instead of repeating
  the comment.
- Never "check", "confirm" or "ensure" something: look it up and say what is
  true.
- Never explain the code back to its author or praise it inline.
- A suggestion block only when it is exact for those lines (indentation
  included); otherwise a plain code snippet.
- Decisions of product (what the system should do when the rules are silent)
  are listed for the user, not opened as code threads.
