#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PATTERN="${REPO_ROOT}/tool/start_local_backend.sh|${REPO_ROOT}/\\.local/bin/fittin-backend|go run ./cmd/fittin-backend|/tmp/go-build.*/exe/fittin-backend|${REPO_ROOT}/backend/cmd/fittin-backend"

pkill -f "$PATTERN" || true

for _ in {1..20}; do
  if ! pgrep -f "$PATTERN" >/dev/null 2>&1; then
    exit 0
  fi
  sleep 0.25
done

pkill -9 -f "$PATTERN" || true
