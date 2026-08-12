#!/usr/bin/env bash

set -euo pipefail

export PATH="$HOME/.local/bin:$HOME/.local/lib/flutter/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PUBLIC_ORIGIN="${PUBLIC_ORIGIN:-https://fittin.hammerscholar.net}"
BACKEND_URL="${BACKEND_URL:-$PUBLIC_ORIGIN/api}"
ECS_TARGET="${ECS_TARGET:-wsf@39.103.152.153}"
ECS_RELEASE_ROOT="${ECS_RELEASE_ROOT:-/home/wsf/nginx-fittin/releases}"
ECS_CURRENT_LINK="${ECS_CURRENT_LINK:-${ECS_RELEASE_ROOT%/releases}/current}"
BUILD_ONLY=0
PULL_FIRST=1

usage() {
  cat <<'EOF'
Usage:
  tool/update_public_web.sh [--build-only] [--no-pull]

Defaults:
  PUBLIC_ORIGIN=https://fittin.hammerscholar.net
  BACKEND_URL=<PUBLIC_ORIGIN>/api
  ECS_TARGET=wsf@39.103.152.153
  ECS_RELEASE_ROOT=/home/wsf/nginx-fittin/releases
  ECS_CURRENT_LINK=<ECS_RELEASE_ROOT without /releases>/current

The script never stores SSH or API credentials. SSH may prompt interactively.
The Alibaba Cloud nginx/NPS bootstrap must be completed once before deploying.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --build-only)
      BUILD_ONLY=1
      shift
      ;;
    --no-pull)
      PULL_FIRST=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

cd "$REPO_ROOT"

if [[ "$PULL_FIRST" -eq 1 ]]; then
  echo "==> Pulling latest code"
  git pull --ff-only
fi

echo "==> Building public web bundle for $BACKEND_URL"
"$REPO_ROOT/tool/build_web_release.sh" "$BACKEND_URL"

if [[ "$BUILD_ONLY" -eq 1 ]]; then
  echo "Build complete: $REPO_ROOT/build/web"
  exit 0
fi

release_id="$(date -u +%Y%m%dT%H%M%SZ)"
archive="$(mktemp -t fittin-web.XXXXXX.tar.gz)"
previous_release=""
activated=0

cleanup_and_rollback() {
	status=$?
	rm -f "$archive"
	if [[ "$status" -ne 0 && "$activated" -eq 1 && -n "$previous_release" ]]; then
		echo "Deployment verification failed; restoring $previous_release" >&2
		ssh -t "$ECS_TARGET" \
			"sudo ln -sfn '$previous_release' '$ECS_CURRENT_LINK' && sudo nginx -t && sudo nginx -s reload" || true
	fi
	exit "$status"
}
trap cleanup_and_rollback EXIT

COPYFILE_DISABLE=1 tar --no-xattrs -C "$REPO_ROOT/build/web" -czf "$archive" .

echo "==> Uploading release $release_id to $ECS_TARGET"
ssh -t "$ECS_TARGET" \
  "sudo mkdir -p '$ECS_RELEASE_ROOT/$release_id' && sudo chown \"\$(id -un):\$(id -gn)\" '$ECS_RELEASE_ROOT/$release_id'"
scp "$archive" "$ECS_TARGET:$ECS_RELEASE_ROOT/$release_id/web.tar.gz"
ssh "$ECS_TARGET" bash -s -- "$ECS_RELEASE_ROOT" "$release_id" <<'REMOTE'
set -euo pipefail
release_root="$1"
release_id="$2"
release_dir="$release_root/$release_id"
tar -xzf "$release_dir/web.tar.gz" -C "$release_dir"
rm -f "$release_dir/web.tar.gz"
REMOTE
expected_version="$(sed -n 's/^version: \([^+]*\).*/\1/p' pubspec.yaml)"
ssh "$ECS_TARGET" bash -s -- "$ECS_RELEASE_ROOT" "$release_id" "$expected_version" <<'REMOTE'
set -euo pipefail
release_root="$1"
release_id="$2"
expected_version="$3"
release_dir="$release_root/$release_id"
test -s "$release_dir/index.html"
test -s "$release_dir/flutter_bootstrap.js"
test -s "$release_dir/main.dart.js"
test -s "$release_dir/version.json"
grep -Fq "\"version\":\"$expected_version\"" "$release_dir/version.json"
REMOTE

previous_release="$(
  ssh "$ECS_TARGET" \
    "readlink -f '$ECS_CURRENT_LINK' 2>/dev/null || true"
)"
if [[ -n "$previous_release" ]]; then
  echo "Previous release for rollback: $previous_release"
fi
ssh -t "$ECS_TARGET" \
  "sudo nginx -t && sudo ln -sfn '$ECS_RELEASE_ROOT/$release_id' '$ECS_CURRENT_LINK' && sudo nginx -s reload"
activated=1

echo "==> Public smoke checks"
retry_curl() {
	local attempt
	for attempt in 1 2 3 4 5; do
		if curl "$@"; then
			return 0
		fi
		sleep 2
	done
	return 1
}
curl_timeout=(--connect-timeout 10 --max-time 20)
retry_curl -fsSI "${curl_timeout[@]}" "$PUBLIC_ORIGIN/"
retry_curl -fsS "${curl_timeout[@]}" "$PUBLIC_ORIGIN/api/readyz"
retry_curl -fsS "${curl_timeout[@]}" "$PUBLIC_ORIGIN/version.json" \
  | grep -Fq "\"version\":\"$expected_version\""
retry_curl -fsS "${curl_timeout[@]}" "$PUBLIC_ORIGIN/flutter_bootstrap.js" \
  | grep -Fq "main.dart.js?v="
retry_curl -fsSI "${curl_timeout[@]}" "$PUBLIC_ORIGIN/main.dart.js"
retry_curl -fsSI "${curl_timeout[@]}" "$PUBLIC_ORIGIN/canvaskit/canvaskit.wasm" \
  | grep -Eiq '^content-type: application/wasm\r?$'

activated=0

echo "Published release $release_id to $PUBLIC_ORIGIN"
