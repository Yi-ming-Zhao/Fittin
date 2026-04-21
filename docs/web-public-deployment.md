# Fittin Web Public Deployment

This guide publishes the Flutter Web client to:

```text
https://fittin.yimelo.cc/
```

The deployment model is:

```text
Flutter Web release build
  -> local Caddy static server on 127.0.0.1:4173
  -> Cloudflare Tunnel ingress
  -> https://fittin.yimelo.cc/
```

This repository now publishes a Flutter Web client that talks to the project-owned backend with `BACKEND_URL` (and optional `BACKEND_API_KEY`) passed via `dart-define`.

Current public host split:

```text
https://fittin.yimelo.cc/     -> Flutter Web frontend
https://api.yimelo.cc/        -> project-owned backend API exposed through Cloudflare Tunnel
```

## Prerequisites

- Flutter SDK installed and available in `PATH`
- Caddy installed on the host machine
- An existing Cloudflare Tunnel that can route `fittin.yimelo.cc`
- A reachable project backend URL for the public web client

Do not rely on the app's local backend fallback for public deployment. Release builds should pass explicit `dart-define` values.

## 1. Build The Web App

From the repository root:

```bash
flutter build web --release \
  --dart-define=BACKEND_URL=https://api.yimelo.cc
```

Or use the repo wrapper that pulls, rebuilds, and restarts the public web service:

```bash
tool/update_public_web.sh
```

The build wrapper automatically normalizes checked-in Isar generated schema ids before running the web release build, so it can recover from the JavaScript integer literal issue without a separate manual step.

The same repository-owned build entrypoint is also used by the GitHub release workflow so a tagged GitHub Release packages the same `build/web` output shape without relying on the public host machine. See [docs/github-release-automation.md](/data/zhaoyiming/Fittin/docs/github-release-automation.md).

Expected output:

- Generated files under `build/web/`
- A release-ready static bundle that can be served from the subdomain root

Notes:

- This app is deployed at the domain root, so do not add a subpath `--base-href`.
- If you need to verify the bundle locally before exposing it publicly, finish the Caddy step below first.

## 2. Serve `build/web` Locally With Caddy

This repo includes a Caddy config template at:

- `deploy/caddy/fittin.Caddyfile`
- `deploy/launchd/com.yimelo.fittin-web.plist`
- `deploy/systemd-user/fittin-web.service`
- `tool/run_fittin_caddy.sh`

Run Caddy from the repo root:

```bash
caddy run --config deploy/caddy/fittin.Caddyfile
```

Expected local origin:

```text
http://127.0.0.1:4173
```

Quick local check:

```bash
curl -I http://127.0.0.1:4173
```

You should receive an HTTP success response and be able to open the app in a browser through the local origin.

### Optional: Keep Caddy Resident With `launchd`

On this macOS host, the recommended long-running setup is `launchd`.

Prepare the log directory:

```bash
mkdir -p .deploy
```

Install the user agent:

```bash
REPO_ROOT="$(pwd)"
sed "s|__REPO_ROOT__|$REPO_ROOT|g" deploy/launchd/com.yimelo.fittin-web.plist \
  > ~/Library/LaunchAgents/com.yimelo.fittin-web.plist
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.yimelo.fittin-web.plist 2>/dev/null || true
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.yimelo.fittin-web.plist
launchctl kickstart -k gui/$(id -u)/com.yimelo.fittin-web
```

Check status:

```bash
launchctl list | grep com.yimelo.fittin-web
curl -I http://127.0.0.1:4173
```

Logs:

```text
.deploy/fittin-web.out.log
.deploy/fittin-web.err.log
```

### Optional: Keep Caddy Resident With `systemd --user` On Linux

On this Ubuntu host, the recommended long-running setup is a user service.

Prepare the log directory and install the templated units:

```bash
mkdir -p .deploy
tool/install_linux_user_services.sh
```

Enable the web service:

```bash
systemctl --user enable --now fittin-web.service
systemctl --user status fittin-web.service --no-pager
curl -I http://127.0.0.1:4173
```

If you want the user services to survive logout/reboot, enable lingering once at the system level:

```bash
sudo loginctl enable-linger "$USER"
```

## 3. Route `fittin.yimelo.cc` Through Cloudflare Tunnel

Update the existing tunnel ingress so the frontend and backend hostnames point to the correct local origins.

This repo includes an example config at:

- `deploy/cloudflared/config.yml.example`

Example ingress shape:

```yaml
ingress:
  - hostname: fittin.yimelo.cc
    service: http://127.0.0.1:4173
  - hostname: api.yimelo.cc
    service: http://127.0.0.1:8081
  - service: http_status:404
```

Important:

- The hostname must be `fittin.yimelo.cc`
- The frontend origin must match the Caddy listener exactly: `127.0.0.1:4173`
- The backend hostname must be `api.yimelo.cc`
- The backend origin must match the local API gateway exactly
- Keep the fallback `http_status:404` rule last

After changing the tunnel config, reload or restart the tunnel using your normal Cloudflare Tunnel operational command.

On Linux with the included user service:

```bash
systemctl --user enable --now fittin-cloudflared.service
systemctl --user restart fittin-cloudflared.service
systemctl --user status fittin-cloudflared.service --no-pager
```

If the host already runs `cloudflared` through `launchd`, reload it after updating `~/.cloudflared/config.yml`:

```bash
launchctl kickstart -k gui/$(id -u)/com.yimelo.cloudflared
```

or, if the Homebrew service label is the active one:

```bash
launchctl kickstart -k gui/$(id -u)/homebrew.mxcl.cloudflared
```

## 4. Public Smoke Checks

After the build, Caddy, and Tunnel are active, verify:

1. Open `https://fittin.yimelo.cc/` and confirm the first frame renders.
2. Refresh the page and confirm it does not fail with a blank screen or 404.
3. Open browser dev tools and confirm core assets such as `flutter_bootstrap.js`, `main.dart.js`, icons, and manifest load successfully.
4. Confirm the app reaches the intended backend environment rather than the local debug fallback.
5. If account features are expected to be live, sign in and confirm auth/bootstrap succeeds.
6. Create or edit a small piece of browser-local data and refresh to confirm IndexedDB-backed local persistence still restores state.
7. Confirm the configured backend health/auth endpoint responds publicly and allows requests from `https://fittin.yimelo.cc`.

## 5. Update Procedure

For every new public release:

1. Pull the latest repository changes.
2. Rebuild the web app with the correct public backend `dart-define` values.
3. Restart Caddy if needed so it serves the newly generated `build/web`.
4. Confirm the tunnel is still routing to `127.0.0.1:4173`.
5. Re-run the public smoke checks.

## 6. Rollback Procedure

If the new release is not acceptable:

1. Stop public validation traffic if needed.
2. Restore the previous known-good `build/web` contents from your backup or previous checkout.
3. Re-run Caddy against the restored build.
4. Confirm `https://fittin.yimelo.cc/` is back on the previous known-good version.
5. Record what failed before attempting the next release.

If the issue is Tunnel-related rather than app-related, first verify the local origin at `http://127.0.0.1:4173` before rebuilding the app.

## 7. Common Failure Checks

- `Missing BACKEND_URL`: rebuild with explicit `--dart-define` values.
- Local origin does not respond: confirm Caddy is running and `build/web` exists.
- Public URL fails but local origin works: inspect Cloudflare Tunnel ingress and tunnel process status.
- App boots but auth/sync is unavailable: confirm `BACKEND_URL` points at the intended public backend and that the backend is healthy behind Cloudflare Tunnel.
