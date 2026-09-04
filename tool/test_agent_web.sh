#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
backup="$(mktemp -d)"
cp lib/src/data/models/*.g.dart "$backup/"
restore() { cp "$backup/"*.g.dart lib/src/data/models/; rm -rf "$backup"; }
trap restore EXIT
dart run tool/fix_isar_web_schema_ids.dart --web-safe
if [[ -z "${CHROME_EXECUTABLE:-}" && -x '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome' ]]; then
  export CHROME_EXECUTABLE='/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
fi
flutter test --no-pub --platform chrome \
  test/data/web_local_store_migration_test.dart \
  test/data/web_agent_v3_test.dart \
  test/data/web_agent_user_content_test.dart \
  test/data/web_workout_conclusion_transaction_test.dart --reporter expanded
