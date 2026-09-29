# Maestri Reconciliation Playbook

Standard operating procedure for maintaining and updating Maestri workspace notes.

## Procedure
1. Always run `maestri list` first to get exact agent and note names.
2. Read all existing notes before editing; classify by domain responsibility.
3. Establish facts from primary sources (source code, manifests, runtime/git state).
4. Treat memory as advisory: resolve conflicts using repository code as ground truth.
5. Use `maestri note edit` for targeted updates; use `write` for completely stale notes.
6. Never delete notes without explicit user authorization.
7. Re-read all notes post-write to verify accurate persistence.
