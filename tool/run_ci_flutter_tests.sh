#!/usr/bin/env bash

set -euo pipefail

export PATH="$HOME/.local/bin:$HOME/.local/lib/flutter/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

# Native Isar tests share process-level resources. Serial execution keeps the
# complete suite deterministic on local machines and GitHub runners.
flutter test --no-pub --concurrency=1
