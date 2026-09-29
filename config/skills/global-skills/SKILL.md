# Global Skills (cross-project)

Master index of all skills available across AGY → OpenCode. Organized by source.

---

## Built-in skills (project-level `.agents/skills/`)

Loaded per-project. Most already in this repo's `.agents/skills/`.

| Skill | Location | Trigger |
|-------|----------|---------|
| `caveman` | `.agents/skills/caveman/SKILL.md` | `/caveman [lite\|full\|ultra\|wenyan\|off]` |
| `caveman-commit` | `.agents/skills/caveman-commit/SKILL.md` | `/caveman-commit` |
| `caveman-compress` | `.agents/skills/caveman-compress/SKILL.md` | `/caveman-compress <path>` |
| `caveman-help` | `.agents/skills/caveman-help/SKILL.md` | `/caveman-help` |
| `caveman-review` | `.agents/skills/caveman-review/SKILL.md` | `/caveman-review [files]` |
| `caveman-stats` | `.agents/skills/caveman-stats/SKILL.md` | `/caveman-stats` |
| `cavecrew` | `.agents/skills/cavecrew/SKILL.md` | delegate to subagent / spawn investigator/builder/reviewer |
| `caveman-init` | `~/.gemini/antigravity-cli/plugins/caveman/skills/caveman-init/SKILL.md` | Drop caveman activation into current repo |

---

## graphify — Knowledge graph from any folder

**Locations (synced):** `~/.claude/skills/graphify/SKILL.md` · `~/.copilot/skills/graphify/SKILL.md` · `~/.gemini/skills/graphify/SKILL.md`

**Trigger:** `/graphify`

**Quick start:** `/graphify <path>` — full pipeline. If `graphify-out/graph.json` exists, `/graphify query "<question>"` queries existing graph.

**Flags:** `--deep`, `--update`, `--cluster-only`, `--directed`, `--no-viz`, `--obsidian`, `--wiki`, `--neo4j`, `--svg`, `--graphml`, `--mcp`, `--watch`.

---

## Mestre TCC — Academic writing coach

**Location:** `~/.gemini/skills/mestre-tcc/SKILL.md`

Reviews for: ABNT norms, formal language, LaTeX formatting, cohesion, citations.

Workflow: structural feedback → revised text → change justification.

---

## Antigravity Superpowers (dev workflow)

**Location:** `~/.gemini/antigravity-cli/plugins/superpowers/skills/<name>/SKILL.md`

When a task matches a superpower below, load its SKILL.md and follow workflow.

| Skill | When to use |
|-------|------------|
| `brainstorming` | Before ANY creative work — features, components, architecture |
| `dispatching-parallel-agents` | 2+ independent tasks with no shared state |
| `executing-plans` | Have a written plan, need step-by-step execution with review |
| `finishing-a-development-branch` | Implementation done, tests pass — complete branch, commit, PR |
| `receiving-code-review` | Processing review feedback, especially if unclear |
| `requesting-code-review` | Before merging — verify work meets requirements |
| `subagent-driven-development` | Spec → implementer → reviewer pipeline in current session |
| `systematic-debugging` | Any bug, test failure, or unexpected behavior BEFORE fixing |
| `test-driven-development` | Before writing ANY implementation code |
| `using-git-worktrees` | Starting feature work that needs isolation |
| `verification-before-completion` | Before claiming work is done — run verification checklist |
| `writing-plans` | Have a spec/requirements for multi-step task |
| `writing-skills` | Creating or editing SKILL.md files |

---

## Chrome DevTools MCP — Browser debugging

**Location:** `~/.gemini/antigravity-cli/plugins/chrome-devtools-mcp/skills/<name>/SKILL.md`

Requires MCP server `chrome-devtools` configured. Use for web debugging.

| Skill | Problem |
|-------|---------|
| `a11y-debugging` | Accessibility issues, semantic HTML, ARIA audit |
| `chrome-devtools` | General debugging, browser automation |
| `chrome-devtools-cli` | Shell scripts for browser automation |
| `debug-optimize-lcp` | Slow Largest Contentful Paint |
| `memory-leak-debugging` | High memory usage, OOM crashes, leaking DOM nodes |
| `troubleshooting` | MCP connection issues, `list_pages` failures |

---

## Code Review

**Location:** `~/.gemini/antigravity-cli/plugins/code-review/skills/<name>/SKILL.md`

| Skill | Purpose |
|-------|---------|
| `code-review` | Review changes on current branch |
| `code-review-commons` | Shared guidelines, persona, critical constraints |
| `pr-code-review` | Review open pull request |

---

## AGY Antigravity Guide

**Location:** `~/.gemini/antigravity-cli/builtin/skills/antigravity_guide/SKILL.md`
**References:** `~/.gemini/antigravity-cli/builtin/skills/antigravity_guide/references/`

Use when user asks about AGY / Antigravity CLI / Antigravity IDE / agy commands / config. Load SKILL.md first, then the relevant reference doc:

- `references/cli.md` — CLI, TUI, keyboard shortcuts, settings
- `references/ide.md` — standalone IDE, sidebar chat, code lenses
- `references/app.md` — desktop app, subagents, artifacts, terminals
- `references/sdk.md` — Python SDK for agent leasing

---

## RTK (Rust Token Killer)

Token-optimized CLI proxy. Saves 60-90% tokens on dev commands.

- `rtk gain` — show savings analytics
- `rtk gain --history` — history with savings
- `rtk discover` — analyze for missed optimization
- `rtk proxy <cmd>` — run raw without filtering

Hooks rewrite transparently: `git status` → `rtk git status`.

---

## Aarin/Consórcio MR Flow

**Location:** `~/.config/opencode/instructions/aarin-mr-flow.md`

Create branches and MRs across DEV/SDX/PRD envs using GitLab MCP. Detailed workflow in separate instruction file.

---

## Maverick Task Creator (ClickUp)

**Location:** `~/.config/opencode/instructions/clickup-tasks.md`

Create ClickUp tasks on Maverick dev board with standard template (Objetivo, Background, Requisitos, etc).

---

---

## Figma — Design integration (9 skills)

**Location:** `~/.gemini/extensions/Figma/skills/<name>/SKILL.md`

MCP via npx (`figma-mcp`) with PAT, or HTTP OAuth at `https://mcp.figma.com/mcp`.

| Skill | Purpose |
|-------|---------|
| `figma-use` | Primary Figma tools — inspect frames, extract styles, export assets |
| `figma-code-connect` | Generate code from design frames |
| `figma-create-new-file` | Create Figma files programmatically |
| `figma-generate-design` | Generate designs from prompts |
| `figma-generate-diagram` | Generate diagrams |
| `figma-generate-library` | Design systems & component libraries |
| `figma-swiftui` | Code-to-design / design-to-code bidirectional |
| `figma-use-figjam` | FigJam boards |
| `figma-use-slides` | Presentation slides |

---

## Extra MCP servers

Configured in `opencode.jsonc`. Tokens in `~/.gemini/antigravity-cli/plugins/<name>/mcp_config.json` or `~/.gemini/config/mcp_config.json`.

| Server | How | What it provides |
|--------|-----|-----------------|
| `datadog` | HTTP remote `mcp.datadoghq.com/v1/mcp` | Datadog observability queries |
| `memory` | npx `@modelcontextprotocol/server-memory` | Persistent knowledge graph across sessions |
| `figma` (OAuth) | HTTP remote `mcp.figma.com/mcp` | Figma via OAuth (alternative to PAT) |

---

## How to use a skill

1. Check if `SKILL.md` is in the project's `.agents/skills/<name>/` — if so, use the `skill` tool
2. Otherwise, read the SKILL.md file directly from the path listed above
3. Follow its workflow. Skills contain full pipeline instructions.
