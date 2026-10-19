#!/bin/sh
set -e

# NocoDB app entrypoint for Railway.
#
# 1. Compose NC_DB for the Postgres companion. PGHOST and PGPASSWORD are
#    single-value ${{postgres.*}} template references (the only thing
#    Railway carries into template defaults); user/db are this template's
#    fixed constants (baked PGUSER/PGDATABASE), composed here in shell —
#    never as a multi-reference variable value, which Railway resolves
#    unreliably. A manually-set NC_DB always wins.
# 2. Wait for PostgreSQL before starting — on Railway the app and DB start
#    in parallel, and NocoDB's boot migrations would fail against a
#    not-yet-ready DB.
# 3. Exec the same `node docker/main.js` the upstream image runs
#    (WorkingDir /usr/src/app). NocoDB listens on $PORT (verified in
#    upstream source: server.listen(process.env.PORT || 8080)).

if [ -z "${NC_DB}" ]; then
  PGHOST="${PGHOST:-postgres}"
  : "${PGPASSWORD:?PGPASSWORD is not set — the postgres companion failed to wire}"
  export NC_DB="pg://${PGHOST}:5432?u=${PGUSER:-nocodb}&p=${PGPASSWORD}&d=${PGDATABASE:-nocodb}"
  echo "[nocodb-entrypoint] composed NC_DB (host=${PGHOST})"
fi

# --- Wait for the database (parse host out of the pg:// URL) ---
DB_HOST="$(echo "${NC_DB}" | sed -n 's|^pg://\([^:/?]*\).*|\1|p')"
DB_HOST="${DB_HOST:-${PGHOST:-postgres}}"

echo "[nocodb-entrypoint] waiting for database at ${DB_HOST}:5432 ..."
i=0
while ! node -e "
  const net = require('net');
  const s = net.connect({ host: '${DB_HOST}', port: 5432, timeout: 2000 });
  s.on('connect', () => { s.end(); process.exit(0); });
  s.on('error',   () => process.exit(1));
  s.on('timeout', () => { s.destroy(); process.exit(1); });
"; do
  i=$((i + 1))
  if [ "$i" -gt 60 ]; then echo "[nocodb-entrypoint] database never became ready"; exit 1; fi
  sleep 3
done
echo "[nocodb-entrypoint] database reachable"

echo "[nocodb-entrypoint] starting NocoDB (foreground)"
cd /usr/src/app
exec node docker/main.js
