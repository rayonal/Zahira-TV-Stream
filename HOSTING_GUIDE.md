# ZTS-0.2B — Hosting Guide

## Recommended proof-of-concept host: GitHub Pages

This pack is ready for a repository whose Pages source is the `/docs` folder.

Expected layout:

```text
repository/
├─ docs/
│  ├─ .nojekyll
│  ├─ catalog.json
│  ├─ catalog.sha256
│  └─ index.html
├─ schema/
├─ freeze/
└─ scripts/
```

After a repository exists and GitHub Pages is enabled from the `main` branch `/docs` folder,
the catalog URL will have the form:

```text
https://<github-username>.github.io/<repository-name>/catalog.json
```

Do not put that placeholder URL into the APK.

## Production hosting

For production, prefer an HTTPS endpoint or object/CDN host that you control and that can:

- serve `catalog.json` reliably over HTTPS;
- keep a stable URL;
- publish atomically;
- retain release history;
- set appropriate cache headers;
- restrict write access;
- roll back to the previous known-good catalog.

## Zahira TV Stream configuration

Once a real HTTPS URL exists:

```powershell
powershell -ExecutionPolicy Bypass -File .\configure-catalog.ps1 `
  -CatalogUrl "https://REAL-HOST/catalog.json"
```

Then rebuild/reinstall ZTS-0.2 because `CATALOG_URL` is currently a BuildConfig value.

## Publish workflow

1. Edit a working copy, not the frozen file.
2. Increment `catalogVersion`.
3. Update `generatedAt`.
4. Run `scripts\catalog-freeze.ps1`.
5. Review validation output.
6. Publish `docs/catalog.json` and `docs/catalog.sha256` atomically.
7. Run `scripts\verify-remote.ps1 -CatalogUrl <real-url>`.
8. Only then point/build the Android app to that URL.

## Important

The remote catalog is not a substitute for content rights. Do not use scraped/private/tokenized endpoints from commercial OTT services without authorization.
