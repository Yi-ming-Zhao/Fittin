#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_ROOT/.local/env.sh"

if [[ ! -f "$FITTIN_PG_DATA/PG_VERSION" ]]; then
  "$REPO_ROOT/tool/setup_local_postgres.sh"
fi

mkdir -p "$FITTIN_PG_SOCKET_DIR" "$(dirname "$FITTIN_PG_LOG")"

pg_ctl \
  -D "$FITTIN_PG_DATA" \
  -l "$FITTIN_PG_LOG" \
  -o "-p ${FITTIN_PG_PORT} -k ${FITTIN_PG_SOCKET_DIR}" \
  start

echo "PostgreSQL started on 127.0.0.1:${FITTIN_PG_PORT}"
echo "DATABASE_URL=${FITTIN_DATABASE_URL}"
