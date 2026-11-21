---
name: imowiz-api-http-smoke-local
description: "Use when running a manual HTTP smoke test of imowiz-backend API locally (real Postgres + floci S3, two tenants, JWTs, fixtures via curl)."
---

## Setup recipe (verified 2026-11, imowiz-backend)
1. Use a throwaway worktree: `git worktree add --detach /tmp/imowiz-smoke <sha>`; `dotnet build Imowiz.Erp.Api`.
2. Containers: `imowiz-postgres` (already up, pw Teste@123), start `imowiz-floci` (S3 emulator, :4566, http only), `imowiz-mongodb`, `imowiz-redis`, `imowiz-rabbitmq` (API needs Mongo/Redis/Rabbit to boot). Stop them afterwards if they were stopped before.
3. Isolated DB: `docker exec imowiz-postgres psql -U postgres -c 'CREATE DATABASE imowiz_smoke138'`; drop with `WITH (FORCE)` at the end. Dev env auto-runs migrations + seeders on startup.
4. Run API from `Imowiz.Erp.Api` with `dotnet run --no-build --no-launch-profile` and env: `ASPNETCORE_ENVIRONMENT=Development DOTNET_ENVIRONMENT=Development PORT=5099 Workers__Enabled=false "ConnectionStrings__Default=...Database=<db>" S3__BucketName=<bucket>`.
   - appsettings.Development sets DOTNET_ENVIRONMENT=Local, which makes ClientPhotosService (S3) a silent no-op; override to Development for real storage. Do NOT use other env names (no appsettings -> crash on EvolutionGo:BaseUrl).
   - Readiness log regex may not match; just poll the port with curl.
5. Tenants/admins: `POST /api/tenant/trial` (tenantSlug, clientName, responsibleName, email, phone, document(CNPJ), whatsAppNumber, password, confirmPassword) creates tenant + Admin. Token: `POST /api/user/login` with header `X-TenantId`.
6. Routes are kebab-case: `/api/listing-type`, `/api/rental-contract`, `/api/crm-card`, `/api/crm-funnel` (default funnel exists per tenant). Listing create is multipart and requires `Photos`; listing must go Draft->Active (PATCH /active) before PATCH /sold {clientId}; rent contract POST sets listing Rented.
7. Client create needs `profiles` (non-empty; enum Lead,Buyer,Seller,Landlord,Renter,Investor,Guarantor), valid CPF, unique phone; non-Lead profiles also need `preferredContactChannel` (WhatsApp|Call|Email).
8. Floci S3 supports unsigned path-style list/get/delete via curl (`http://localhost:4566/<bucket>?list-type=2&prefix=...`). Presigned photoUrl is https; rewrite to http to fetch.
9. Known: first upload when bucket doesn't exist => 500 ObjectDisposedException (S3StorageService NoSuchBucket retry, pre-existing); retry works.
10. `maestri ask` blocks until the Maestro replies and may time out at 300s; the message is likely still delivered.
