---
name: maestri-maestro-workflow
description: Orchestration sequence for driving a feature end-to-end via Maestri canvas agents without editing code directly.
---

# Maestri Maestro Workflow

When the user instructs you to "use the Maestri workflow" or act as the "Maestro", you MUST act strictly as an orchestrator. Do not edit source code, run tests, or execute git commands directly.

Follow this exact procedure to drive a feature end-to-end:

1. **Context Initialization:**
   - Read the active context: `maestri note read current-feature`.
   - Update the note with the new scope, MR, and branch details: `maestri note write "current-feature" "..."`.

2. **Delegated Planning & Execution:**
   - Ask the Planner to formulate the technical plan and hand it off to the Coder:
     `maestri ask "Planner Agent" "A note current-feature foi atualizada com o escopo... Formule o plano técnico e faça o handoff assíncrono (--async) para o Coder Agent executar na branch X, instruindo-o a rodar os testes."`
   - Monitor the Coder's progress. Use `maestri check "Coder Agent"` (you can poll using `sleep 20 && maestri check "Coder Agent"`) until the agent completes the code edits, `pnpm type-check`, and `pnpm test`.

3. **Delegated Deployment:**
   - Once the Coder finishes successfully, delegate the git operations:
     `maestri ask "Release Manager Agent" "O Coder finalizou... Faça git add, git commit (usando as flags de segurança do projeto, ex: --no-gpg-sign --no-verify) e git push."`

4. **Cleanup:**
   - Reset the feature note to prepare for the next task:
     `maestri note write "current-feature" "# Feature atual"`
