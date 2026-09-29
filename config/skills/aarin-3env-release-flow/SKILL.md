# 3-Environment Release Flow for internal-sales-frontend

This skill governs the multi-environment release process when delivering feature tasks in `internal-sales-frontend` across `dev`, `sandbox`, and `main` branches.

## Branching Strategy
For a given task (e.g. ClickUp ID `86ak13gkp` with slug `boleto_balcao`):

1. **DEV Branch & MR**
   - Base branch: `dev`
   - New branch: `feat/dev_86ak13gkp_boleto_balcao`
   - Target MR: `dev`

2. **Sandbox (SDX) Branch & MR**
   - Base branch: `sandbox`
   - New branch: `feat/sdx_86ak13gkp_boleto_balcao`
   - Process: Cherry-pick the commit from DEV branch
   - Target MR: `sandbox`

3. **Production (PRD) Branch & MR**
   - Base branch: `main`
   - New branch: `feat/prd_86ak13gkp_boleto_balcao`
   - Process: Cherry-pick the commit from DEV branch
   - Target MR: `main`

## Commit & Push Rules
- Commit messages in English.
- Always bypass local hooks and GPG signing using flags:
  `git commit -m "..." --no-gpg-sign --no-verify`
  `git push origin <branch_name> --no-verify`

## GitLab MCP Fallback
If GitLab MCP fails due to permissions or undefined API errors, output the exact git commands and MR description templates for manual creation in GitLab.
