---
name: maestri-rate-limit-fallback
description: Fallback strategies when Maestri sub-agents hit 429/410 rate limits during delegation
---

# Handling Agent Rate Limits in Maestri

When orchestrating a team of agents via the `maestri` CLI, your delegated agents may hit API provider rate limits (e.g. 429 Too Many Requests) or model exhaustion (410 Gone).

## Identification
- You run `maestri check "Agent Name"` and see repeated `429` or `410` errors in their terminal.
- The agent takes exceptionally long and times out on standard requests.

## Fallback Strategy
Do not block the entire pipeline waiting for a rate-limited agent to recover.

1. **Re-delegate to a different agent (different model):**
   If you have another agent in the team that uses a different LLM (e.g. falling back from Coder to Coder Hotfixer), send the specs to them using `maestri ask`.

2. **Take over mechanical tasks directly:**
   If the blocked task is a standard shell command (like `check-types`, `lint`, or `git push`) and doesn't strictly require the agent's persona, run it yourself directly via the `bash` tool in your own terminal.

3. **User confirmation bypass:**
   If the user explicitly confirms out-of-band that a blocked step is actually complete ("Fixes implementados e check-types ok"), skip the blocked validation agent and move directly to the next phase (e.g. Release) instead of forcing the agent to verify.
