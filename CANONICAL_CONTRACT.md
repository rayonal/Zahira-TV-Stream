# ZTS-0.2B — Canonical Remote Catalog Contract v1

Freeze ID: `ZTS-0.2B-CANONICAL-CATALOG-V1`

Canonical file: `docs/catalog.json`  
SHA-256: `bcddf697a88e34226b6ab164e564eed31d6102af75e5e388e0939fc355f36c70`

## Root contract

Required keys:

- `catalogVersion`: integer >= 1. This is the content revision. Increment it for each published catalog revision.
- `generatedAt`: RFC 3339 / ISO-8601 timestamp with timezone.
- `channels`: non-empty array.

No extra root keys are permitted by the canonical schema.

## Channel contract

Every channel has exactly:

- `id`: stable lowercase slug. Treat as immutable identity once published.
- `number`: positive unique channel number.
- `name`: user-visible name.
- `category`: user-visible category.
- `streamUrl`: HTTPS URL. ZTS-0.2 parser requires HTTPS even for disabled/offline entries.
- `logoUrl`: empty string or HTTPS URL.
- `description`: text description.
- `isLive`: boolean.
- `enabled`: boolean. Disabled entries validate but are filtered from the app.
- `status`: `online`, `offline`, or `maintenance`.
- `sortOrder`: integer used before `number` and `name` for display sorting.

## Invariants frozen against the ZTS-0.2 parser

1. Catalog must contain at least one channel.
2. `id` values are unique.
3. `number` values are unique.
4. Every `streamUrl` uses HTTPS.
5. `logoUrl` is empty or HTTPS.
6. Production uses explicit known status values; unknown values are not allowed by this schema.
7. Only `enabled=true` channels become visible in the repository state.
8. `status=online` + `enabled=true` + nonblank stream URL is required for playability.

## Version discipline

- Schema remains **v1** while the field contract remains unchanged.
- `catalogVersion` increments on every remote content release.
- `generatedAt` changes on every release.
- Stable `id` must not be recycled for a different channel.
- Changing a stream URL, logo, status, name, category, number, or ordering counts as a catalog revision.
- Never edit the frozen manifest to make a changed catalog appear unchanged; generate a new freeze.

## Security boundary

ZTS-0.2 authenticates the transport with HTTPS but does **not yet cryptographically sign** catalog payloads.
The SHA-256 freeze is therefore a release/audit control, not an in-app signature check.
A future signed-catalog gate can add detached signatures without changing the v1 payload.

## Rights boundary

This frozen catalog contains test/demo streams only. Production channel endpoints, logos, EPG or copyrighted assets must be included only when Zahira TV Stream has authorization or the source expressly permits the intended distribution/use.
