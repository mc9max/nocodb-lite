# NocoDB

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.com/deploy/nocodb-3?utm_campaign=nocodb-lite)

**NocoDB** is the open-source Airtable alternative — turn any Postgres database into a smart spreadsheet with grid, kanban, form, gallery and calendar views, plus auto-generated REST and MCP APIs. This template deploys NocoDB with a Postgres companion on Railway in one click, zero form fields.

Upstream: [nocodb/nocodb](https://github.com/nocodb/nocodb) (AGPL-3.0, ~65k stars).

## Deploy and Host

Click **Deploy on Railway** — zero form fields. The template provisions two services:

- **nocodb** (this repo) — the NocoDB app, wrapping the pinned official image `nocodb/nocodb:2026.09.1`
- **postgres** — PostgreSQL 16 companion holding all NocoDB metadata, wired over Railway's private network

On first boot the app waits for Postgres, runs its migrations, and shows the admin signup page. Uploads and attachments persist on a Railway volume at `/usr/app/data`.

## Configuration

The deploy form has zero fields — the template wires everything. These are the knobs, only if you want to tune. Set them in the service's **Variables** panel after deploy (all optional; defaults are baked into the images).

**Database — auto-wired, leave alone unless you know why:**

| Variable | Default | What it does |
|---|---|---|
| `PGHOST` | `${{postgres.RAILWAY_PRIVATE_DOMAIN}}` (auto) | Postgres host over the private network |
| `PGPASSWORD` | `${{postgres.POSTGRES_PASSWORD}}` (auto) | Postgres password from the companion |
| `NC_DB` | composed at boot: `pg://<PGHOST>:5432?u=nocodb&p=<PGPASSWORD>&d=nocodb` | NocoDB metadata database URL; set it yourself to use an external database instead |

**Auth & app:**

| Variable | Default | What it does |
|---|---|---|
| `NC_AUTH_JWT_SECRET` | `${{secret(64)}}` (auto-generated) | Signs NocoDB auth tokens |
| `NC_DISABLE_TELE` | `true` (baked) | Disables upstream telemetry |
| `NC_INVITE_ONLY_SIGNUP` | _(unset)_ | Set `true` after creating your admin to close open sign-ups |
| `NC_ADMIN_EMAIL` / `NC_ADMIN_PASSWORD` | _(unset)_ | Pre-seed the first admin and skip the signup form |
| `PORT` | Railway injects (NocoDB honors it; upstream default 8080) | HTTP listen port |

**Postgres companion:**

| Variable | Default | What it does |
|---|---|---|
| `POSTGRES_PASSWORD` | `${{secret(24)}}` (auto-generated) | Database password; user `nocodb`, db `nocodb` are baked |

To lock down sign-ups after creating your admin account, set `NC_INVITE_ONLY_SIGNUP=true` in the nocodb service's Variables.

## Why Deploy

Self-hosting NocoDB means your data never leaves your infrastructure — no per-seat pricing, no row limits, no vendor lock-in. Railway keeps the whole stack on your own hardware: the app and Postgres talk over the private network, uploads persist on a volume, and the auto-generated REST/MCP APIs are ready the moment the admin account exists.

## Common Use Cases

- An Airtable replacement for teams that want database-backed collaboration without per-seat fees
- Internal tools: CRMs, inventory trackers, content pipelines built as spreadsheets, forms and kanbans
- A visual frontend for an existing Postgres database — connect it and the table views generate from the schema
- Backend-as-a-spreadsheet: auto-generated REST and MCP APIs for apps and AI agents

## Runtime

- **Port:** honors Railway's injected `PORT` (verified in upstream source); healthcheck `GET /api/v1/health`
- **Memory:** app ~500 MB–1 GB; Postgres light — fits comfortably in Hobby limits
- **Persistence:** Postgres data on its volume (`/var/lib/postgresql/data`, `PGDATA` subdir); app uploads on `/usr/app/data`
- **First run:** admin signup page in the browser (proxy-safe); set `NC_INVITE_ONLY_SIGNUP=true` afterwards to close registration

### Deployment Dependencies

Two services, no public exposure for the database. The nocodb service needs outbound network only for its own boot; all data stays between the two services over Railway's private network. No external API keys required.

## Credits

NocoDB: [nocodb/nocodb](https://github.com/nocodb/nocodb) (AGPL-3.0). This repo is a thin Railway deploy wrapper around the official pinned image.
