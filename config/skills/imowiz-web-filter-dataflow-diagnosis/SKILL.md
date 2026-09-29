---
name: imowiz-web-filter-dataflow-diagnosis
description: "Diagnose filter and data-flow bugs in the Imowiz web portal (apps/web) — nuqs defaults, buildSearchParams mapping, DTO/mapper casing fragility, and PascalCase API contract"
---

# Diagnosing Filter & Data-Flow Bugs in apps/web (Imowiz Portal)

Use when investigating bugs in `/properties` or `/` (home) involving filters, card clicks, detail navigation, or stale/incorrect listings in the `apps/web` app of the imowiz-frontend monorepo.

## Data flow (the golden path — trace bugs along this chain)

```
FilterSidebar (filter-sidebar.tsx, nuqs setFilters)
  → use-property-filters.ts (useQueryStates parsers + defaults)
  → URL query string (?purpose=1&type=...&beds=...)
  → app/(public)/properties/page.tsx (reads searchParams)
  → modules/properties/screens/properties-list-screen.tsx (converts to GetPropertiesParams)
  → modules/properties/actions/get-properties-action.ts (server action)
  → modules/properties/http/get-properties.ts → buildSearchParams()
  → @imowiz/infra HttpApiClient (ky, no casing normalization)
  → C# backend API (PascalCase query params)
```

## Key files and their roles

| File | Role |
|---|---|
| `apps/web/src/modules/properties/hooks/use-property-filters.ts` | nuqs parsers + defaults. Check `withDefault()` — shadow defaults fabricate active filters silently. |
| `apps/web/src/modules/properties/components/filter-sidebar.tsx` | UI labels (e.g. `${num}+`) vs values sent. Check if label promises range but value is exact. |
| `apps/web/src/modules/properties/http/get-properties.ts` | `buildSearchParams()` maps frontend → PascalCase API params. Check for exact-vs-range semantics here. |
| `apps/web/src/modules/properties/mappers/property-mapper.ts` | Normalizes casing: has fallbacks (`price ?? sellPrice`, `bedrooms ?? bedRooms`, `images ?? photos`) — check `id` which historically has none. |
| `apps/web/src/core/router/routes.ts` | `ROUTES.PROPERTIES.update = { path: "/properties/:id", params: { id: true } }`. |
| `packages/utils/src/create-generate-route-path/create-generate-route-path.ts` | `generateRoutePath()` — does `path.replace(":id", params.id)`. If `params.id` is the string `"undefined"` → `/properties/undefined` (bad). If `""` → `/properties/` (falls to index). |

## Known bug patterns in this codebase

### Pattern 1: `nuqs` `withDefault()` fabricates implicit filters
- `parseAsInteger.withDefault(1)` makes `purpose=1` always present → `buildSearchParams` sends `Purpose=Sale` even when user didn't select it.
- Check: any parser with `withDefault(N)` where N is truthy AND consumed by `buildSearchParams` with a truthy guard (`if (params.X)`) → implicit filter.
- Fix: drop the `withDefault`, allow `null` as neutral state, add a "Qualquer"/"Any" button for null.

### Pattern 2: UI label semantics ≠ value semantics
- Buttons labeled `1+`, `2+`, `3+` (promising "1 or more") send exact values `NumberOfBedrooms=1`, not `>=1`.
- Fix: change param name to `MinNumberOfBedrooms` (confirm with Swagger first) or adjust labels to exact.
- Applies identically to `baths` and `parking`.

### Pattern 3: Mapper casing fragility
- C# API likely returns PascalCase (`Id`, `Price`, `Bedrooms`).
- `mapRawPropertyToSummary` has casing fallbacks for most fields **except** `id` (just `item.id`).
- If `id` comes back as `Id` (PascalCase), cards generate `href="/properties/undefined"` or `href="/properties/"` → 404 or redirects to list.
- Fix: add `item.id ?? item.Id ?? item.ID` fallback pattern, plus `.filter((p) => p.id)` as safety net where mapped.

### Pattern 4: `featured` param silently dropped
- `getPropertiesAction({ featured: true })` passes `featured` but `buildSearchParams` ignores it → home "Destaques" section actually gets first 12 arbitrary properties, not backend-flagged featured ones.

## Verification approach

- No automated tests in this repo (copilot-instructions.md confirms). Verification is manual smoke.
- Must use tenant subdomain in dev (e.g. `imowiz.imowiz.com.br:PORT`, not `localhost`) — host-based tenant resolution.
- `eval` tool is effective for reproducing `buildSearchParams` and `generateRoutePath` behavior with synthetic inputs before committing to a fix.

## API contract reminders (C# backend)

- Query params: PascalCase (`Purpose`, `ListingTypeId`, `City`, `NumberOfBedrooms`, `MinPrice`, `CurrentPage`, `PageSize`).
- `Purpose` values: string enums `"Sale"`, `"Rent"`, `"SaleAndRent"` — confirm exact strings with Swagger.
- Range filter param names (e.g. `MinNumberOfBedrooms` vs `NumberOfBedrooms`) must be confirmed with Swagger before changing `buildSearchParams`.
- Response also PascalCase but mapper handles most casing; the exception is `id`.
