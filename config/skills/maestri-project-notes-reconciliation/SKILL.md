---
name: maestri-project-notes-reconciliation
description: Reconcile stale Maestri workspace notes against verified current repository and runtime context without leaking sensitive data
---

# Maestri Project Notes Reconciliation

When workspace notes reference a different project than the actual workdir, reconcile ALL notes systematically.

## Discovery
1. `maestri list` — get all connected notes and agents.
2. Read every note (`maestri note read "<name>"`).
3. Check actual project: `package.json`, repo structure, `git remote -v`, `git branch`.
4. Identify every mismatch.

## Notes to reconcile (in order)

| Note | Key fields to verify |
|---|---|
| `maestro-notes` | Workspace name, workdir path |
| `current-feature` | Clear if feature belongs to old project → write `# Feature atual` |
| `project-tech-stack` | Framework, package manager, libraries, test runner, verification commands |
| `qa-checklist` | Build/test/lint commands, validation focus areas |
| `portal-config` | Dev server command (`npm run dev` vs `pnpm dev`) |
| `release-flow-rules` | Branch strategy, remote platform, merge flow, commit conventions |
| `restricted-*` credentials | Clear immediately if from another project |
| `maestri-governance` | Usually generic — verify but likely unchanged |

## Gotchas
- **Auto-rename**: `maestri note write` renames the note if the first line changes and the note wasn't created with `--name`. The command response tells you the new name.
- **Credentials**: Never leave credentials from another project. Clear and note that none are registered.
- **Package manager**: npm vs pnpm vs yarn changes every command in qa-checklist, portal-config, and project-tech-stack.
- **Test runner**: Some projects have none — state this explicitly so agents don't assume `jest`/`vitest` exist.
- **Branch strategy**: Simple single-branch (main only) vs multi-environment (dev/sandbox/main) changes release-flow-rules completely.

## Verification
After all writes, run `maestri list` to confirm note names and topology are intact.
