# Deploy and Host

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.com/deploy/nocodb-1?utm_campaign=nocodb-lite)

**NocoDB** — the open-source Airtable alternative. Turn Postgres into smart spreadsheets with grid, kanban, form, gallery and calendar views, plus auto-generated REST and MCP APIs. Deploys with a Postgres companion in one click, zero form fields.

On first boot the app waits for Postgres, runs migrations, and shows the admin signup page. Uploads persist on a Railway volume.

## About Hosting

Two services, deployed together with one click:

- **nocodb** — the NocoDB app (pinned official image `nocodb/nocodb:2026.09.1`), healthcheck `GET /api/v1/health`, honors Railway's injected `PORT`
- **postgres** — PostgreSQL 16 companion for all metadata, reachable only over Railway's private network

The app composes its `NC_DB` connection string at boot from auto-wired single-ref variables (`${{postgres.RAILWAY_PRIVATE_DOMAIN}}`, `${{postgres.POSTGRES_PASSWORD}}`). Telemetry is disabled (`NC_DISABLE_TELE=true`).

## Why Deploy

Self-hosting NocoDB means your data never leaves your infrastructure — no per-seat pricing, no row limits, no vendor lock-in. The app and database talk over Railway's private network, uploads persist on a volume, and the REST/MCP APIs are live the moment the admin account exists.

## Common Use Cases

- An Airtable replacement for teams — database-backed collaboration without per-seat fees
- Internal tools: CRMs, inventory trackers, content pipelines as spreadsheets, forms and kanbans
- A visual frontend for an existing Postgres database — table views generate from the schema
- Backend-as-a-spreadsheet: auto-generated REST and MCP APIs for apps and AI agents

## Configuration

Zero form fields on deploy. After deploy, the knobs in the services' **Variables** panel (all optional):

- **Database (auto-wired):** `PGHOST` (`${{postgres.RAILWAY_PRIVATE_DOMAIN}}`), `PGPASSWORD` (`${{postgres.POSTGRES_PASSWORD}}`), `NC_DB` (composed at boot; set it yourself for an external DB). Postgres companion: `POSTGRES_PASSWORD` (`${{secret(24)}}`).
- **Auth & app:** `NC_AUTH_JWT_SECRET` (`${{secret(64)}}`), `NC_DISABLE_TELE=true` (baked), `NC_INVITE_ONLY_SIGNUP` (set `true` after creating your admin to close sign-ups), `NC_ADMIN_EMAIL`/`NC_ADMIN_PASSWORD` (pre-seed admin, skips signup form).

## Dependencies for

### Deployment Dependencies

Two services, no public exposure for the database. NocoDB needs nothing at runtime beyond its Postgres companion — no external API keys, no third-party services. Create your admin account on the signup page after deploy, then optionally set `NC_INVITE_ONLY_SIGNUP=true` to close registration.
