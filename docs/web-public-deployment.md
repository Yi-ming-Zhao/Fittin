# Fittin Web Public Deployment

Fittin Web is published directly through Alibaba Cloud at:

```text
https://fittin.hammerscholar.net/
```

The browser uses the same origin for the backend:

```text
https://fittin.hammerscholar.net/api
```

The production path does not use Cloudflare Tunnel:

```text
Browser
  -> Alibaba Cloud DNS wildcard A record
  -> Alibaba Cloud ECS nginx (HTTPS and Flutter Web)
  -> /api/* on nginx
  -> NPS TCP port 24181
  -> NPS client 19 on 241-dhg
  -> Fittin backend at 127.0.0.1:8081
```

No passwords, NPS verification keys, API keys, or TLS private keys belong in this repository.

## 1. Production Contract

Current production values:

| Item | Value |
|---|---|
| Public origin | `https://fittin.hammerscholar.net` |
| Web root symlink | `/home/wsf/nginx-fittin/current` |
| Versioned releases | `/home/wsf/nginx-fittin/releases/<UTC timestamp>` |
| Backend URL passed to Flutter | `https://fittin.hammerscholar.net/api` |
| NPS client | ID 19 (`10.108.17.241`) |
| NPS public/loopback port | `24181` |
| Backend target | `127.0.0.1:8081` (resolved by NPS client 19 on `241-dhg`) |
| nginx template | `deploy/nginx/fittin.hammerscholar.net.conf` |

The `hammerscholar.net` DNS zone has a wildcard A record that resolves the Fittin hostname directly to the Alibaba Cloud ECS. The Fittin hostname uses its own Let's Encrypt certificate.

## 2. One-Time NPS Setup

Confirm the backend on `241-dhg` first:

```bash
ssh 241-dhg 'curl -fsS http://127.0.0.1:8081/healthz'
```

In the existing NPS administration surface, create one TCP tunnel:

| Field | Value |
|---|---|
| Type | `tcp` |
| Client ID | `19` |
| Remark | `Fittin-backend-241` |
| Server IP | `127.0.0.1` |
| Server port | `24181` |
| Target | `127.0.0.1:8081` |

Validate from the ECS before configuring nginx:

```bash
curl -fsS http://127.0.0.1:24181/healthz
```

## 3. One-Time nginx And TLS Setup

Create the release and ACME directories:

```bash
sudo mkdir -p /home/wsf/nginx-fittin/releases /var/www/letsencrypt
sudo chown -R wsf:wsf /home/wsf/nginx-fittin
```

Before the first certificate exists, serve only the ACME challenge over HTTP for `fittin.hammerscholar.net`.

The current ECS cannot reach the Let's Encrypt API directly, so the production certificate was issued from another certbot host with an HTTP-01 manual auth hook that writes the challenge file to `/var/www/letsencrypt/.well-known/acme-challenge/` on the ECS. The resulting `fullchain.pem` and `privkey.pem` were then copied to `/etc/letsencrypt/live/fittin.hammerscholar.net/` over SSH. Keep the private key out of this repository.

If ECS outbound ACME access becomes available later, the simpler renewal path is:

```bash
sudo certbot certonly \
  --webroot \
  --webroot-path /var/www/letsencrypt \
  --domain fittin.hammerscholar.net
```

The current certificate expires on 2026-10-10. Renew and install its replacement before that date, then run `sudo nginx -t` before reloading nginx.

Install `deploy/nginx/fittin.hammerscholar.net.conf` in the nginx include directory, then validate and reload:

```bash
sudo nginx -t
sudo nginx -s reload
```

Never reload nginx if `nginx -t` fails.

## 4. Build And Publish

The release build must use the same-origin API prefix:

```bash
tool/build_web_release.sh https://fittin.hammerscholar.net/api
```

For a normal update, use:

```bash
tool/update_public_web.sh
```

The update script:

1. pulls with `git pull --ff-only` unless `--no-pull` is supplied;
2. creates the Flutter Web release with an explicit backend URL;
3. uploads a timestamped archive to the ECS;
4. atomically repoints `/home/wsf/nginx-fittin/current`;
5. validates and reloads nginx;
6. checks the public frontend and `/api/healthz`.

Useful variants:

```bash
# Build without uploading
tool/update_public_web.sh --build-only

# Publish a working tree that has already been reviewed
tool/update_public_web.sh --no-pull
```

SSH may prompt interactively. Do not add the ECS password to the script or an environment file tracked by Git.

## 5. Smoke Checks

Run all of these after each activation:

```bash
curl -fsSI https://fittin.hammerscholar.net/
curl -fsS https://fittin.hammerscholar.net/api/healthz
curl -fsSI https://fittin.hammerscholar.net/flutter_bootstrap.js
curl -fsSI https://fittin.hammerscholar.net/main.dart.js
```

Also verify in a phone-sized browser viewport:

1. the first frame renders without console errors;
2. refreshing a nested app state still returns the Flutter shell;
3. home, plans, progress, and profile pages do not overflow horizontally;
4. a workout can start or resume;
5. card mode completes left, skips right, and snaps back below threshold;
6. traditional mode remains selectable in Settings;
7. tapping the current weight opens direct entry and a changed weight carries forward;
8. authentication and sync requests use `/api`, not localhost or an old hostname.

## 6. Rollback

List available releases and point `current` back to the previous directory:

```bash
ls -1dt /home/wsf/nginx-fittin/releases/*
ln -sfn /home/wsf/nginx-fittin/releases/<previous> /home/wsf/nginx-fittin/current
sudo nginx -t
sudo nginx -s reload
```

Rollback changes only the static Web bundle. It does not modify PostgreSQL or backend user data.

If `/api/healthz` fails while `241-dhg` is healthy, test in this order:

```bash
# 241 backend
ssh 241-dhg 'curl -fsS http://127.0.0.1:8081/healthz'

# NPS path from ECS
curl -fsS http://127.0.0.1:24181/healthz

# nginx public path
curl -fsS https://fittin.hammerscholar.net/api/healthz
```

## 7. Retiring The Old Tunnel

Only after the direct Alibaba Cloud frontend and API checks pass, stop and disable the Fittin-specific Cloudflare services on `241-dhg`. Keep their unit files until the rollback window has passed, then revoke the obsolete tunnel token through the provider account. Never commit or share that token.
