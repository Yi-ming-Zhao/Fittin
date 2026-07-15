#!/usr/bin/env bash

set -euo pipefail

export PATH="$HOME/.local/bin:$HOME/.local/lib/flutter/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EXPECTED_ANDROID_SIGNER_SHA256="0c52c1350c14a360c833422967ac33469572e9acb64a33ddaad1a407532d0671"

cd "$REPO_ROOT"

if [[ $# -lt 1 || $# -gt 2 ]]; then
  cat <<'EOF'
Usage:
  tool/build_android_release.sh <BACKEND_URL> [BACKEND_API_KEY]

Example:
  tool/build_android_release.sh https://fittin.hammerscholar.net/api

The Android app cannot use the repository-local 127.0.0.1 backend fallback.
Release APK/AAB builds must include BACKEND_URL through dart-define.
EOF
  exit 1
fi

BACKEND_URL="$1"
BACKEND_API_KEY="${2:-}"

if [[ ! -f android/key.properties ]]; then
  echo "android/key.properties is required for a signed release build."
  exit 1
fi

echo "==> Resolving Flutter dependencies"
flutter pub get

echo "==> Building Android APK"
flutter build apk --release \
  --dart-define=BACKEND_URL="$BACKEND_URL" \
  --dart-define=BACKEND_API_KEY="$BACKEND_API_KEY"

ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$HOME/Library/Android/sdk}}"
APKSIGNER="$(
  find "$ANDROID_SDK_ROOT/build-tools" -type f -name apksigner -print 2>/dev/null \
    | sort \
    | tail -n 1
)"
if [[ -z "$APKSIGNER" ]]; then
  echo "Android apksigner was not found under $ANDROID_SDK_ROOT/build-tools."
  exit 1
fi

ACTUAL_ANDROID_SIGNER_SHA256="$(
  "$APKSIGNER" verify --print-certs-pem \
    build/app/outputs/flutter-apk/app-release.apk \
    | openssl x509 -outform DER \
    | openssl dgst -sha256 \
    | awk '{print $2}'
)"
if [[ ! "$ACTUAL_ANDROID_SIGNER_SHA256" =~ ^[0-9a-f]{64}$ ]]; then
  echo "Unable to read a valid SHA-256 signer digest from the APK."
  exit 1
fi
if [[ "$ACTUAL_ANDROID_SIGNER_SHA256" != "$EXPECTED_ANDROID_SIGNER_SHA256" ]]; then
  echo "Built APK does not match the stable Fittin signer."
  exit 1
fi

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
