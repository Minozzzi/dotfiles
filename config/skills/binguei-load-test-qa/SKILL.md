---
name: binguei-load-test-qa
description: "Use when validating the Binguei realtime load test (pnpm load:realtime, scripts/load) as Tester: negative controls with a fault-injecting server image, exit-code checks, Ctrl-C cleanup, and local DB/Redis isolation."
---

## Binguei load-test QA recipe (FT US-012, `pnpm load:realtime`)

Never edit the repo. Use a scratch copy for the server mutant and a JS eval harness (spawn + poll docker state).

### 1. Baseline and cleanliness
- Snapshot before/after: `docker ps -a`, `docker network ls`, `docker images`, `docker volume ls | wc -l`, plus counts of `binguei-load*` containers/networks/images and `docker ps -a --filter label=binguei.load-run`. Diff must be identical at the end.
- Local dev PG/Redis containers (`binguei-app-postgres-1`, `binguei-app-redis-1`) show healthcheck noise every 5s: compare against a 14s idle control, and compare `tup_inserted/updated/deleted` + `DBSIZE` + `pg_database` list, not session/command counters.
- Poisoned env (`DATABASE_URL`, `REDIS_URL`, `BETTER_AUTH_SECRET`, `ABACATEPAY_API_KEY`, `NODE_ENV`) must not change anything: script ignores env.

### 2. Server-side fault injection (negative control)
- `rsync` repo to `/tmp/x` excluding node_modules/.git/dist/.env*; patch `apps/api/src/modules/realtime/realtime.ts` `publisher.drawCreated` to read `/tmp/fault.json` at runtime (modes: drop-players@ordinal, dup-players, delay-all ms, drop-organizer, leak) and append hits to `/tmp/fault-hits`; `docker build --file apps/api/Dockerfile --tag tk02-mut-api:1 .` (~40s).
- Run the REPO script with `--image=tk02-mut-api:1 --no-build`; inject the fault file with `docker exec -i <binguei-load-api-*> sh -c 'cat > /tmp/fault.json'` (stdin, not `echo '{...}'` quoting). Confirm hits in `/tmp/fault-hits`. Always run a no-fault control first.
- Expected: drop mid-round => exit 1 missingPushes>0; dup => exit 1; delay 2500ms => exit 1 (non-exploratory) ; delay 1500ms => exit 0; S3 exploratory: correctness failures still exit 1, latency only EXPLORATORY (exit 0).
- Historic bug to re-check on regressions: `LoadPlayer` disconnect handler flagged every `close()` as `reconnected=true`, silently disabling the missingPushes gate (fix: ignore reason "io client disconnect").

### 3. Exit codes
- ulimit: `sh -c 'ulimit -n N; exec node ...'`; needed = events*(players+1)+200; below => exit 2, zero docker resources, no report.
- `--max-loop-lag-ms=1` => exit 2 INCONCLUSIVE with all gates ok.
- Docker unreachable (`DOCKER_HOST=unix:///nonexistent.sock`, `tcp://127.0.0.1:1`, docker missing from PATH) => exit 2, no stack trace.
- Kill API/Postgres container mid-draw (`docker kill` after "drawing 75 balls" + ~1.5s) => exit 1, process must exit on its own (<~1s after message), no orphan node.

### 4. Ctrl-C cleanup
- Spawn with `detached: true` and `process.kill(-pid, "SIGINT")` (real Ctrl-C = process group), sweep delays across build (image only), startup (3 containers + net), migrations, drawing; test both `node ...realtime.ts` and `pnpm load:realtime --`. Expect exit 130 and 0 `binguei-load*` resources, 0 orphans. Stray `docker stats --all --no-trunc` processes with another parent are not the script's.

### 5. Gates and facts
- `pnpm test:scripts`, `lint`, `typecheck`, `format`, `turbo lint typecheck --force`.
- Threshold source: PRD RNF-03 (<=2s, gate is max not percentile), RNF-04 (300), RNF-05; scenarios from docs/tech/backend.md L10. Everything else (settle 3000ms, lag 250ms, join concurrency 25, +200 fds) is instrument parameter. Consumption never gates.
- macOS Docker Desktop results are PROVISIONAL (notes in report); sampler yields only 1-4 samples in short scenarios.
