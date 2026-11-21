---
name: imowiz-client-http-smoke
description: "Use when running a manual HTTP smoke of imowiz-backend (clients/photo/listings/CRM) with real Kestrel API, Postgres and floci S3 in a throwaway worktree."
---

## Setup
- `git worktree add --detach /tmp/imowiz-smoke <sha>`; `docker start imowiz-floci imowiz-mongodb imowiz-redis imowiz-rabbitmq`; `CREATE DATABASE imowiz_smoke138` in `imowiz-postgres` (user postgres / Teste@123).
- Build `dotnet build Imowiz.Erp.Api`, run as named service from `Imowiz.Erp.Api` with env: ASPNETCORE_ENVIRONMENT=Development, **DOTNET_ENVIRONMENT=Development** (appsettings sets `Local`, which makes ClientPhotosService a storage no-op; `Production`-ish values break EvolutionGo config), PORT=5099, Workers__Enabled=false, ConnectionStrings__Default=..., S3__BucketName=imowiz-smoke-138. Migrations run on startup.
- Pre-create bucket: `curl -X PUT localhost:4566/imowiz-smoke-138` (first upload to missing bucket 500s: ObjectDisposedException in S3StorageService, pre-existing).
- Floci presigned photoUrl is https://localhost:4566 but serves http only: replace scheme to open. Unsigned bucket listing `GET :4566/bucket?list-type=2&prefix=` works.

## Auth/fixtures (all via HTTP)
- `POST /api/tenant/trial` (slug, clientName, responsibleName, email, phone, document CNPJ, whatsAppNumber, password, confirmPassword) creates tenant + Admin. Login: `POST /api/user/login` with header `X-TenantId`; token in `.token`.
- Client: `POST /api/client/natural-person` needs profiles (e.g. ["Lead"]), preferredContactChannel "WhatsApp", valid CPF, unique phone `+55119xxxxxxxx`.
- Listing type: `POST /api/listing-type`. Listing: multipart `POST /api/listing` (ListingTypeId, ClientOwnerId, Purpose, Title, Street, City, State, Neighborhood, Photos file required; Rent needs RentPrice). Sold requires Draft->active first: `PATCH /api/listing/{id}/active` then `/sold` body {clientId}.
- Rental contract `POST /api/rental-contract`; CRM: default funnel from `GET /api/crm-funnel`, `POST /api/crm-card`, `POST /api/crm-card/{id}/listings`, `PATCH /api/crm-card/{id}/close` {result: Won|Lost}.
- Test files: sips converts png->jpg; pad jpg with zero bytes to exact sizes (magic bytes still valid).

## Cleanup
Kill API, delete bucket objects+bucket, DROP DATABASE ... WITH (FORCE), stop the 4 containers, `git worktree remove --force`. `maestri ask` can hang >300s: wrap in `timeout 60`.
