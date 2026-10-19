# NocoDB on Railway — one-click deploy wrapper (app service)
#
# Base is the official prebuilt image (nocodb/nocodb), pinned by digest:
# the NestJS API server and the built Vue frontend are already inside —
# the wrapper only adapts it to Railway, never rebuilds it.
#
# The Postgres companion runs from postgres/Dockerfile in this repo.
# Every constant is baked into the images as ENV because Railway's
# `templates create` only carries ${{...}} expressions into template
# defaults — plain literals would land on the deploy form as required
# fields. The only template variables are ${{...}} expressions, so the
# one-click form is zero fields.
#
# Why each non-default setting exists:
#   USER root ................. The stock image already runs as root; keep it
#                               explicit because Railway mounts persistent
#                               volumes root-owned.
#   NC_DISABLE_TELE=true ...... Opt out of upstream telemetry for deploys.
#   PGUSER/PGDATABASE ......... Fixed constants the entrypoint uses to
#                               compose NC_DB in shell (never compose several
#                               ${{...}} refs inside one variable VALUE —
#                               Railway resolves that unreliably).
#   HEALTHCHECK NONE .......... The stock image has no healthcheck; Railway's
#                               external healthcheckPath ("/api/v1/health")
#                               in railway.json is the readiness gate.
#   ENTRYPOINT override ....... Replaces dumb-init + start.sh with our own
#                               script that composes NC_DB from single-ref
#                               variables, waits for Postgres, then execs
#                               the same `node docker/main.js` upstream runs.
#
# Upstream: https://github.com/nocodb/nocodb (AGPL-3.0, ~65k stars)
# Base image: nocodb/nocodb 2026.09.1

FROM nocodb/nocodb:2026.09.1@sha256:27d2fd14670db892ac721849d4f071edce47e386a1e74c921a0162644b9c213d

USER root

ENV NC_DISABLE_TELE=true
ENV PGUSER=nocodb
ENV PGDATABASE=nocodb

HEALTHCHECK NONE

EXPOSE 8080

LABEL org.opencontainers.image.source="https://github.com/mc9max/nocodb-lite"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
