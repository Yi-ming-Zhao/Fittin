#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
backup="$(mktemp -d)"
cp lib/src/data/models/*.g.dart "$backup/"
restore() { cp "$backup/"*.g.dart lib/src/data/models/; rm -rf "$backup"; }
trap restore EXIT
dart run tool/fix_isar_web_schema_ids.dart --web-safe
flutter build web --release --no-pub --no-web-resources-cdn --target tool/agent_review_app.dart --output build/agent-review
