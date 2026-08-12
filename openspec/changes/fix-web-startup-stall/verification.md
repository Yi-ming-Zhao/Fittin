## Root Cause Evidence

- Public Chromium at 390x844 remained on `#fittin-web-launch` with zero `flutter-view` elements.
- The console reported `Failed to execute 'compile' on 'WebAssembly': Incorrect response MIME type. Expected 'application/wasm'.`
- Alibaba Cloud nginx 1.14 originally returned CanvasKit WASM as `application/octet-stream`.
- After the server correction, an already affected browser still failed because the unchanged full and Chromium CanvasKit binaries retained the old response header in Service Worker and HTTP caches.

## Implementation Verification

- `flutter analyze`: passed with no issues.
- Full `flutter test`: passed, including the new Web runtime contract tests.
- `tool/build_web_release.sh https://fittin.hammerscholar.net/api`: passed repeatedly with the production backend URL and cache-busted bootstrap.
- `openspec validate fix-web-startup-stall --strict`: passed.
- `git diff --check`: passed.
- Exact code SHA `61a8b2a6cd850eb1c2559c833b373046e03edb02`: GitHub CI succeeded at `https://github.com/Yi-ming-Zhao/Fittin/actions/runs/31584442915`.

## Production Verification

- nginx configuration backup: `/etc/nginx/conf.d/fittin.hammerscholar.net.conf.pre-wasm-20260812T092342Z`.
- `sudo nginx -t`: passed before reload.
- Active verified Web release: `/home/wsf/nginx-fittin/releases/20260812T094701Z`.
- Rollback release: `/home/wsf/nginx-fittin/releases/20260812T094252Z`.
- Public full and gzip-compressed CanvasKit responses return `Content-Type: application/wasm`; deployment smoke checks enforce this contract.
- `https://fittin.hammerscholar.net/api/readyz`: returned `{"ok":true,"ready":true}`.
- The originally affected browser session recovered after the targeted cache migration.
- A subsequent 390x844 reload rendered one `flutter-view` within the normal startup window, removed the static launch layer, had no horizontal overflow, and showed no new startup warning or error logs.
- The static launch surface now exposes localized Reload recovery if no first frame is produced.
