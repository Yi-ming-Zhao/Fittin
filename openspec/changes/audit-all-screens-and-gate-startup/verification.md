# Verification Evidence

## Agent audit and accepted fixes

- Three independent UI agents audited the five primary tabs, training/card/traditional flows, plans/edit/share utilities, analytics/history, account/settings, and significant loading, empty, and error states.
- Accepted P1/P2 findings were fixed: startup owner-scope race, offline auth-scope retention, single-flight generation-safe hydration, sign-in scope gating, no-plan error state, Body async hierarchy, unresolved account status, QR overflow, plan-editor cursor resets, invalid weight/history values, traditional skip, skipped-history loss, small touch targets, and bottom-navigation semantics.
- Passing surfaces were preserved without visual churn. A standalone rest-timer prototype and denser conclusion statistics remain intentionally deferred because they are separate product features rather than regressions in reachable flows.

## Production visual matrix

- Build: `tool/build_web_release.sh https://fittin.hammerscholar.net/api`
- Core viewports: 390x926 and 390x568.
- Representative combinations: English/Obsidian Brass and Chinese/Porcelain Ink, plus reduced motion and system-English/app-Chinese launch handoff. Automated guards cover all five palettes.
- Routes/states: startup animation, startup 503 recovery, no active plan, Today with an active plan, all five main tabs, plan list/detail/switch/training-max validation, Body empty state, Profile/Appearance, oversized share fallback, and active workout at both heights.
- Result: no Flutter overflow, page exception, unexpected failed request, horizontal viewport overflow, clipped primary action, or cyan/teal theme residue in accepted surfaces.
- Startup sequence: Porcelain Ink retained `#F3EEE5` from the animated HTML barbell preload through the Flutter barbell gate and ready shell; Android resource compilation also verified the native barbell launch mark, and no false plan-loading copy appeared.
- Recovery sequence: simulated session HTTP 503 retained the stored token and showed Retry plus Continue locally at 390x568.
- Interaction sequence: GZCLP activation, Today card entry, and active-session rendering completed end to end; share and workout-card semantics remained separate and enabled.

## Automated verification

- `flutter analyze --no-pub`: no issues.
- Full deterministic Flutter suite after the final visual, startup, and race-condition iteration: 318 tests passed serially.
- Palette guards: five complete palettes meet contrast requirements and contain no cyan or teal theme colors.
- Production Web build: succeeded against `https://fittin.hammerscholar.net/api`.
- Android resource build: debug APK compiled successfully with the native launch mark.

## Public mobile startup iteration

- Real mobile emulation exposed a missing viewport declaration that desktop-sized browser emulation did not reproduce. The production document now resolves to a true 390px CSS viewport at both 390x926 and 390x568.
- The HTML barbell remains until the real Flutter first-frame signal. Initial preference restoration is bounded to two seconds so a stalled browser store cannot prevent Flutter from rendering its own recovery surface.
- The bundled first-party CJK fallback was reduced from 10,540,376 bytes to a 265,832-byte app-copy subset; uncommon user-entered glyphs retain platform/Flutter fallback.
- Alibaba Cloud nginx now serves precompressed static assets: the observed JavaScript response fell from 3,883,583 bytes to about 1.09 MB, and CanvasKit WASM from 5,678,018 bytes to about 2.14 MB.
- Final fresh-context checks against the v1.0.11 deployment completed the first Flutter frame at 56.9s and 37.9s while the local proxy delivered the 1.09 MB main bundle unusually slowly. Both scenarios retained the barbell gate until readiness, resolved to a 390px viewport, removed the HTML gate only after a Flutter view existed, and had no console errors, page errors, failed requests, HTTP error responses, horizontal overflow, or false plan-loading failure copy.
- The Flutter readiness composition was visually rechecked after its centering fix and remained centered at both target heights; automated geometry tests guard the same relationship. A follow-up viewport-only capture confirmed that an apparent top alignment was a Playwright `fullPage` capture relayout artifact rather than the rendered mobile layout.

## Exact release evidence

- Release commit: `2e4a24df4c1139ab40798eca4e50efceac90ab9a` (`fix: harden mobile startup delivery`).
- Exact-SHA CI: [run 29591527466](https://github.com/Yi-ming-Zhao/Fittin/actions/runs/29591527466), successful backend tests, Flutter analysis, and Flutter tests.
- Signed release workflow: [run 29591787140](https://github.com/Yi-ming-Zhao/Fittin/actions/runs/29591787140), completed successfully for tag `v1.0.11` at the release commit.
- Release: [v1.0.11](https://github.com/Yi-ming-Zhao/Fittin/releases/tag/v1.0.11); direct Android update: [fittin-v1.0.11-android.apk](https://github.com/Yi-ming-Zhao/Fittin/releases/download/v1.0.11/fittin-v1.0.11-android.apk).
- APK: 77,836,678 bytes, SHA-256 `c6af526657e94c2e42d460f18c0e98db49b39d5f078acc0aa3e55638462b3480`, package `com.example.fittin_v2`, version `1.0.11`, versionCode `18`, APK Signature Scheme v2, one signer.
- AAB: 58,034,119 bytes, SHA-256 `e603cb444c9118e3851cb22b55ded3dd1095f750795fddbf1ada2631ac1910e9`; `jarsigner` verified the archive. Its warnings were limited to the expected self-signed certificate, missing timestamp, and unsigned POSIX metadata.
- APK and AAB certificate SHA-256: `0c52c1350c14a360c833422967ac33469572e9acb64a33ddaad1a407532d0671`, matching the established update signer.
- Web ZIP: 24,858,130 bytes, SHA-256 `4aa6c45fafceb4075b0e8dfb3ebb1864a6d5717c2d1a97827e3729635123420b`; independent extraction on 241 confirmed `1.0.11+18`, the mobile viewport, the 265,832-byte font subset, and 21 precompressed assets.

## Deployment evidence

- 241 repository: clean and fast-forwarded to `2e4a24df4c1139ab40798eca4e50efceac90ab9a`; backend health remained `{"ok":true}` and no backend restart was required because this release changed no backend source.
- Alibaba Cloud release: `/var/www/fittin/releases/20260717T152254Z`; stable nginx link `/home/wsf/nginx-fittin/current` resolves to that immutable directory.
- Rollback release: `/var/www/fittin/releases/20260717T150546Z`.
- Public `version.json` and a direct `--resolve` request to `39.103.152.153` both report `{"version":"1.0.11","build_number":"18"}`; `/api/healthz` returns `{"ok":true}`. The deployment uses the Alibaba Cloud A record directly and does not use Cloudflare Tunnel.
- `main.dart.js` returns `Content-Encoding: gzip`, `Vary: Accept-Encoding`, and a 1,094,209-byte compressed response. Final tall/short mobile checks and visual inspection passed as recorded above.
