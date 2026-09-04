# Fittin v1.3.0 Release Verification

## Published identity

- Application version: `1.3.0+26`
- Git tag: `v1.3.0`
- Release commit: `5ba2c80ea9bf8689f956b40f3566ee287dfe1429`
- Pull request: [#12](https://github.com/Yi-ming-Zhao/Fittin/pull/12)
- GitHub Release: [v1.3.0](https://github.com/Yi-ming-Zhao/Fittin/releases/tag/v1.3.0)
- Release workflow: [33910827840](https://github.com/Yi-ming-Zhao/Fittin/actions/runs/33910827840)
- Android package: `com.example.fittin_v2`
- Stable Android signer SHA-256: `0c52c1350c14a360c833422967ac33469572e9acb64a33ddaad1a407532d0671`

## Release assets

The GitHub checksum manifest and independent local verification agreed on all distributable assets:

| Asset | Bytes | SHA-256 |
| --- | ---: | --- |
| `fittin-v1.3.0-android.apk` | 86,893,514 | `55668bc57b7d1c7cff110b9e73700a72ebdf95ce238bcca464b6e2f110bd28d5` |
| `fittin-v1.3.0-android.aab` | 62,727,747 | `8be0e9ee51c50199306173c77fa4dc24b381567f17cb5548c59a0e9319c59333` |
| `fittin-v1.3.0-web.zip` | 26,557,333 | `75f993ff10e7a0beb84807f05930c7b3e0001308da2748963cc08ff6d4f3ae62` |

- APK Signature Scheme verification passed.
- AAB JAR verification passed; its certificate digest is identical to the APK signer.
- The Web ZIP passed a complete archive test and declares version `1.3.0`, build `26`.

## Automated verification

- PR CI run [33909301702](https://github.com/Yi-ming-Zhao/Fittin/actions/runs/33909301702) passed Flutter, Go, and unsigned iOS Release jobs.
- Main CI run [33909756012](https://github.com/Yi-ming-Zhao/Fittin/actions/runs/33909756012) passed on the exact release commit.
- The full Flutter suite passed 570 tests; 30 opt-in live-provider tests remained skipped by design.
- The Chrome IndexedDB migration and transaction suite passed all 18 tests.
- Full Go tests, Flutter analysis, Android APK/AAB builds, Web build, and CI iOS `--no-codesign` build passed.
- The official DeepSeek `deepseek-v4-flash` canary passed 31 of 31 connection and fitness-task cases with an ephemeral key that was not persisted or logged.
- The route-complete visual gate covers 40 screens at 320 and 390 px widths, short and tall phones, English, Chinese, 1.6x text, keyboard, and desktop scenarios.
- `openspec validate --all --strict` passed all 75 specifications and changes.

## Signed Android upgrade

The public v1.2.1 APK (`1.2.1+25`) was installed on an API 36 ARM64 emulator and populated before the CI-signed v1.3.0 APK was installed with `adb install -r`.

- Android accepted the in-place upgrade and retained `firstInstallTime=2026-08-13 18:31:57`.
- The package reports `versionName=1.3.0` and `versionCode=26`.
- The signed-in account remained active before and after a force-stop/relaunch; no login screen appeared.
- Midnight Cobalt remained selected, and the Agent Base URL, model, and secure-key readiness remained available.
- The 12-Week Powerbuilding plan remained at Week 1 / Day 1.
- The active High-Bar Squat draft retained its edited `77.5 kg` value against the prescribed `75 kg x 6` set.
- The existing `82.6 kg` body metric remained visible.
- The startup animation remained visible until restoration completed and did not expose a transient missing-plan screen.
- The new Home cardio command, typed cardio library, adaptive Running fields, reorganized Profile, eight built-in palettes, and deep settings pages were visually checked at the emulator's 1344 by 2992 physical viewport.

After first-party publication, a clean v1.2.1 installation displayed `Version 1.3.0 is available`. Its Android download action opened the exact first-party APK URL, and a second signed in-place installation succeeded.

## Backend and public Web deployment

- The 241 repository was fast-forwarded to the release commit.
- Database migrations `20260904_000003_user_content.sql` and `20260905_000004_refresh_sessions.sql` were applied before service activation.
- `fittin-backend.service` is active and both local and public readiness endpoints return HTTP 200.
- Active backend binary: `.local/bin/fittin-backend-v1.3.0`, SHA-256 `53a6ef3b6ce9470a390de50429dd02f986a6e70a9c74eaf9cfb23ab0450f3825`.
- Rollback backend: `.local/bin/fittin-backend-before-v1.3.0`, SHA-256 `3275cf59747596e7cd3ae72e7ad26c180872f0932c301e52ea8cf7e8e49a16f2`.
- The Web build was staged at `/var/www/fittin/releases/v1.3.0/web`; `/home/wsf/nginx-fittin/current` points there and v1.2.1 remains available for rollback.
- The staged Web archive SHA-256 is `b3ecb741a47c46bffd2bc2002d01cab485e7ed7ca4eb5754a341d06fad7ecd46`.
- Public `/`, `/version.json`, `flutter_bootstrap.js`, `main.dart.js`, and `/api/readyz` return HTTP 200 with the intended cache and security headers.
- The public browser loaded the v1.3.0 Home surface without warnings or errors; its only console messages were normal Flutter service-worker activation events.

## Public authentication, relay, and update checks

- Public sign-up, refresh, session restore, and sign-out returned HTTP 201/200/200/200.
- A refresh outside the 15-second convergence window returned a rotated credential while preserving the same user identity.
- An unauthenticated Agent relay request returns HTTP 401.
- An authenticated relay request reached the upstream provider and returned typed JSON for the intentionally invalid canary credential; the credential marker appeared in neither the response nor 241 service logs.
- `/releases/v1.3.0/`, the first-party APK, and `/releases/latest.json` are public. The manifest advertises `1.3.0+26` and was advanced only after the signed upgrade passed.
- Re-downloading the public first-party APK produced SHA-256 `55668bc57b7d1c7cff110b9e73700a72ebdf95ce238bcca464b6e2f110bd28d5`, identical to GitHub and the local signed artifact.
- When `/home` approached capacity, only failed v1.3.0 upload residue and first-party packages older than the retained v1.2.1 rollback were removed before retrying publication.
