# Fittin v1.2.1 Release Verification

## Published identity

- Application version: `1.2.1+25`
- Git tag: `v1.2.1`
- Release commit: `0074170349a393074efc7697eb0e2d77059d954f`
- Pull request: [#11](https://github.com/Yi-ming-Zhao/Fittin/pull/11)
- GitHub Release: [v1.2.1](https://github.com/Yi-ming-Zhao/Fittin/releases/tag/v1.2.1)
- Android APK SHA-256: `614f3a3649cefeeaa95646a9b4ab86605271c9920a21fc08cf54b392f45c2b83`
- Stable Android signer SHA-256: `0c52c1350c14a360c833422967ac33469572e9acb64a33ddaad1a407532d0671`

## Verification gates

- PR CI run 89 passed Flutter 3.41 analysis, the complete Flutter suite, Web IndexedDB/transaction tests, Go backend tests, and the unsigned iOS release build.
- Main CI run 90 completed successfully after merge.
- The local full Flutter suite passed 474 tests; 30 opt-in live-provider cases remained skipped by design.
- The focused browser suite passed all 12 IndexedDB migration, recovery, rollback, and atomic-write cases.
- The official DeepSeek `deepseek-v4-flash` canary passed 31 of 31 connection and fitness-task cases with an ephemeral process-only key and synthetic fixtures.
- `openspec validate --all --strict` passed all 68 specifications and active changes.
- The signed APK, AAB, and Web ZIP each match the immutable GitHub checksum manifest. APK and AAB use the same stable signer.

## Android upgrade

The public v1.2.0 APK was installed over the emulator's existing v1.1.0 installation, then the CI-signed v1.2.1 APK was installed with `adb install -r`.

- Android accepted both in-place upgrades.
- `firstInstallTime` remained `2026-08-13 18:31:57`.
- The package reports `versionName=1.2.1` and `versionCode=25`.
- The existing 12-week powerbuilding plan, Week 1 / Day 1 position, and next Squat Strength session remained visible after the upgrade.

## Public deployment

- The 241 repository was fast-forwarded to the release commit and `fittin-backend.service` remained active with a ready local endpoint.
- The CI Web artifact was staged immutably at `/var/www/fittin/releases/v1.2.1/web` on Alibaba Cloud.
- `/home/wsf/nginx-fittin/current` points to that directory; `/var/www/fittin/releases/v1.2.0/web` remains available for rollback.
- Public checks passed for `/`, `/version.json`, `/api/readyz`, `flutter_bootstrap.js`, gzip-compressed `main.dart.js`, and the `application/wasm` CanvasKit response.
- An unauthenticated Agent relay request returns HTTP 401.
- Public 390 by 844 visual checks passed for Today, Plans, and AI without browser warnings or errors.
- The first-party release page and APK are available under `/releases/v1.2.1/`; `/releases/latest.json` was advanced only after every prior gate passed.

The ECS nginx configuration test passed. Its pre-existing empty PID-file state prevents `nginx -s reload`; the attempted activation automatically restored v1.2.0, after which the unchanged static configuration was left running and only the release symlink was atomically switched to v1.2.1.
