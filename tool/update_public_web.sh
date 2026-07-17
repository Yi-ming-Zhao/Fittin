#!/usr/bin/env bash

set -euo pipefail

export PATH="$HOME/.local/bin:$HOME/.local/lib/flutter/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PUBLIC_ORIGIN="${PUBLIC_ORIGIN:-https://fittin.hammerscholar.net}"
BACKEND_URL="${BACKEND_URL:-$PUBLIC_ORIGIN/api}"
BACKEND_API_KEY="${BACKEND_API_KEY:-}"
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
"$REPO_ROOT/tool/build_web_release.sh" "$BACKEND_URL" "$BACKEND_API_KEY"

if [[ "$BUILD_ONLY" -eq 1 ]]; then
  echo "Build complete: $REPO_ROOT/build/web"
  exit 0
fi

release_id="$(date -u +%Y%m%dT%H%M%SZ)"
archive="$(mktemp -t fittin-web.XXXXXX.tar.gz)"
trap 'rm -f "$archive"' EXIT

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
previous_release="$(
  ssh "$ECS_TARGET" \
    "readlink -f '$ECS_CURRENT_LINK' 2>/dev/null || true"
)"
if [[ -n "$previous_release" ]]; then
  echo "Previous release for rollback: $previous_release"
fi
ssh -t "$ECS_TARGET" \
  "sudo nginx -t && sudo ln -sfn '$ECS_RELEASE_ROOT/$release_id' '$ECS_CURRENT_LINK' && sudo nginx -s reload"

echo "==> Public smoke checks"
curl -fsSI --max-time 20 "$PUBLIC_ORIGIN/"
curl -fsS --max-time 20 "$PUBLIC_ORIGIN/api/healthz"

echo "Published release $release_id to $PUBLIC_ORIGIN"
