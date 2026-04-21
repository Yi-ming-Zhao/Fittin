#!/usr/bin/env bash

set -euo pipefail

export PATH="$HOME/.local/bin:$HOME/.local/lib/flutter/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

flutter test \
  test/application \
  test/data \
  test/domain/one_rep_max_test.dart \
  test/domain/program_engine_test.dart \
  test/domain/rule_engine_test.dart \
  test/domain/weight_tools_test.dart
