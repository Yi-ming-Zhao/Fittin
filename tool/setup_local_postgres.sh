#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_ROOT/.local/env.sh"

mkdir -p "$FITTIN_PG_SOCKET_DIR" "$(dirname "$FITTIN_PG_LOG")"

if [[ -f "$FITTIN_PG_DATA/PG_VERSION" ]]; then
  echo "PostgreSQL cluster already exists at $FITTIN_PG_DATA"
  exit 0
fi

mkdir -p "$FITTIN_PG_DATA"
initdb \
  -D "$FITTIN_PG_DATA" \
  -U postgres \
  -A trust \
  --auth-local=trust \
  --auth-host=trust \
  --username=postgres

cat >>"$FITTIN_PG_DATA/postgresql.conf" <<EOF
port = ${FITTIN_PG_PORT}
listen_addresses = '127.0.0.1'
unix_socket_directories = '${FITTIN_PG_SOCKET_DIR}'
shared_preload_libraries = ''
EOF

echo "Initialized PostgreSQL data directory at $FITTIN_PG_DATA"
