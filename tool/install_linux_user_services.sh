#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SYSTEMD_USER_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"

mkdir -p "$SYSTEMD_USER_DIR" "$REPO_ROOT/.deploy"

install_unit() {
  local src="$1"
  local dest="$2"
  sed "s|__REPO_ROOT__|$REPO_ROOT|g" "$src" > "$dest"
}

install_unit \
  "$REPO_ROOT/deploy/systemd-user/fittin-web.service" \
  "$SYSTEMD_USER_DIR/fittin-web.service"

install_unit \
  "$REPO_ROOT/deploy/systemd-user/fittin-cloudflared.service" \
  "$SYSTEMD_USER_DIR/fittin-cloudflared.service"

systemctl --user daemon-reload

cat <<EOF
Installed user services:
  $SYSTEMD_USER_DIR/fittin-web.service
  $SYSTEMD_USER_DIR/fittin-cloudflared.service

Next steps:
1. Enable the static web server:
   systemctl --user enable --now fittin-web.service
2. Enable the Cloudflare tunnel after ~/.cloudflared/config.yml and tunnel credentials exist:
   systemctl --user enable --now fittin-cloudflared.service
EOF
