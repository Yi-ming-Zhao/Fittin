#!/usr/bin/env bash

set -euo pipefail

export PATH="$HOME/.local/bin:$HOME/.local/lib/flutter/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

BACKEND_URL="${BACKEND_URL:-https://api.yimelo.cc}"
BACKEND_API_KEY="${BACKEND_API_KEY:-}"
FITTIN_SERVICE_LABEL="${FITTIN_SERVICE_LABEL:-com.yimelo.fittin-web}"
CLOUDFLARED_SERVICE_LABEL="${CLOUDFLARED_SERVICE_LABEL:-homebrew.mxcl.cloudflared}"
FITTIN_SYSTEMD_SERVICE="${FITTIN_SYSTEMD_SERVICE:-fittin-web.service}"
CLOUDFLARED_SYSTEMD_SERVICE="${CLOUDFLARED_SYSTEMD_SERVICE:-fittin-cloudflared.service}"
RESTART_CLOUDFLARED=0
UNAME_S="$(uname -s)"

usage() {
  cat <<'EOF'
Usage:
  tool/update_public_web.sh [--restart-cloudflared]

Defaults:
  BACKEND_URL=https://api.yimelo.cc
  BACKEND_API_KEY=<optional api key>
  FITTIN_SERVICE_LABEL=com.yimelo.fittin-web
  CLOUDFLARED_SERVICE_LABEL=homebrew.mxcl.cloudflared
  FITTIN_SYSTEMD_SERVICE=fittin-web.service
  CLOUDFLARED_SYSTEMD_SERVICE=fittin-cloudflared.service

Environment overrides:
  BACKEND_URL
  BACKEND_API_KEY
  FITTIN_SERVICE_LABEL
  CLOUDFLARED_SERVICE_LABEL
  FITTIN_SYSTEMD_SERVICE
  CLOUDFLARED_SYSTEMD_SERVICE
EOF
}

restart_web_service() {
  case "$UNAME_S" in
    Darwin)
      echo "==> Restarting public web service: $FITTIN_SERVICE_LABEL"
      launchctl kickstart -k "gui/$(id -u)/$FITTIN_SERVICE_LABEL"
      ;;
    Linux)
      echo "==> Restarting public web service: $FITTIN_SYSTEMD_SERVICE"
      systemctl --user daemon-reload
      systemctl --user restart "$FITTIN_SYSTEMD_SERVICE"
      ;;
    *)
      echo "Unsupported OS for automatic web service restart: $UNAME_S" >&2
      exit 1
      ;;
  esac
}

restart_cloudflared_service() {
  case "$UNAME_S" in
    Darwin)
      echo "==> Restarting cloudflared: $CLOUDFLARED_SERVICE_LABEL"
      launchctl kickstart -k "gui/$(id -u)/$CLOUDFLARED_SERVICE_LABEL"
      ;;
    Linux)
      echo "==> Restarting cloudflared: $CLOUDFLARED_SYSTEMD_SERVICE"
      systemctl --user daemon-reload
      systemctl --user restart "$CLOUDFLARED_SYSTEMD_SERVICE"
      ;;
    *)
      echo "Unsupported OS for automatic cloudflared restart: $UNAME_S" >&2
      exit 1
      ;;
  esac
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --restart-cloudflared)
      RESTART_CLOUDFLARED=1
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

echo "==> Pulling latest code"
git pull --ff-only

echo "==> Building public web bundle"
"$REPO_ROOT/tool/build_web_release.sh" "$BACKEND_URL" "$BACKEND_API_KEY"

restart_web_service

if [[ "$RESTART_CLOUDFLARED" -eq 1 ]]; then
  restart_cloudflared_service
fi

echo "==> Quick checks"
curl -I --max-time 10 http://127.0.0.1:4173
echo
curl -I --max-time 20 https://fittin.yimelo.cc/

cat <<'EOF'

Done.

Typical usage:
  tool/update_public_web.sh

If you changed cloudflared ingress/config:
  tool/update_public_web.sh --restart-cloudflared
EOF
