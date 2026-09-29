---
name: omp-roles-config
description: "How to find and read OMP agent roles, models, and fallback chains."
---

When asked about OMP roles, agents (like Coder, Maestro, Planner), or model fallbacks, read `~/.omp/agent/config.yml`. The active primary models for each role are mapped under `modelRoles`. The fallback sequences for each role are defined under `retry.fallbackChains`.
