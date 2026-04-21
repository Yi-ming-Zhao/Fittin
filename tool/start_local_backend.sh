#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_ROOT/.local/env.sh"
source "$REPO_ROOT/.local/backend.env"

mkdir -p "$FITTIN_FILE_STORAGE_ROOT" "$REPO_ROOT/.local/var/log"

cd "$REPO_ROOT/backend"
exec go run ./cmd/fittin-backend
