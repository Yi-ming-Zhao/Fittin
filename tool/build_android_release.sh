#!/usr/bin/env bash

set -euo pipefail

export PATH="$HOME/.local/bin:$HOME/.local/lib/flutter/bin:$PATH"

if [[ $# -lt 1 || $# -gt 2 ]]; then
  cat <<'EOF'
Usage:
  tool/build_android_release.sh <BACKEND_URL> [BACKEND_API_KEY]

Example:
  tool/build_android_release.sh https://api.yimelo.cc

The Android app cannot use the repository-local 127.0.0.1 backend fallback.
Release APK/AAB builds must include BACKEND_URL through dart-define.
EOF
  exit 1
fi

BACKEND_URL="$1"
BACKEND_API_KEY="${2:-}"

echo "==> Resolving Flutter dependencies"
flutter pub get

echo "==> Building Android APK"
flutter build apk --release \
  --dart-define=BACKEND_URL="$BACKEND_URL" \
  --dart-define=BACKEND_API_KEY="$BACKEND_API_KEY"

echo "==> Building Android App Bundle"
flutter build appbundle --release \
  --dart-define=BACKEND_URL="$BACKEND_URL" \
  --dart-define=BACKEND_API_KEY="$BACKEND_API_KEY"

cat <<'EOF'

Build complete.
Outputs:
- build/app/outputs/flutter-apk/app-release.apk
- build/app/outputs/bundle/release/app-release.aab
EOF
