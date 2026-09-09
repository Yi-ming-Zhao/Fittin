# Fittin v1.4.0 release verification

## Identity

- Version: `1.4.0+27`.
- Release commit: `51f09496d04b88aee1383be0b2d06aec6e1b77db`.
- Pull request: [#13](https://github.com/Yi-ming-Zhao/Fittin/pull/13).
- Release workflow: [34329884147](https://github.com/Yi-ming-Zhao/Fittin/actions/runs/34329884147).
- GitHub Release: [v1.4.0](https://github.com/Yi-ming-Zhao/Fittin/releases/tag/v1.4.0); all seven platform archives/packages and the checksum manifest are uploaded.
- Stable Android certificate SHA-256: `0c52c1350c14a360c833422967ac33469572e9acb64a33ddaad1a407532d0671`.

## Automated and visual evidence

- Final PR CI [34329404325](https://github.com/Yi-ming-Zhao/Fittin/actions/runs/34329404325) passed Flutter, Go, Windows, Linux, macOS and unsigned iOS jobs.
- The tagged source tree is identical to the tested PR head. All five release jobs succeeded, including stable-signed APK/AAB and production Web packaging.
- Flutter analysis reported no issues. The native suite passed 603 tests; 30 opt-in provider tests were skipped, not counted as passes. The Chrome migration/transaction suite passed 19 tests.
- Focused checks cover atomic rollback, stale schedule previews, delete/release, repeat history replay, live-draft isolation, free training, catalog/Agent execution traits, three anatomy views and eight-palette dumbbell rendering.
- Reviewed 28 synthetic Web scenarios across 320px/390px phones, long screens, desktop, nested editors and eight anatomy palettes; keyboard, large-text and bilingual layouts also have widget coverage.
- Real synthetic Web interaction selected an Arnold press, changed weight, recorded three sets and saved free training with an explicit no-plan-progression confirmation.
- Visual review found and corrected full-width filter chips; regression verifies compact wrapping with at least 44px touch targets.
- The eight delta specifications match their synchronized main-spec additions exactly. Strict validation passed 76 items before archival.

## Platform boundaries

- Windows x64 and Linux x64 bundles passed CI builds and packaging.
- macOS archive passed a complete unzip test and original bundle signature verification. Its executable is universal (Intel x86_64 and Apple arm64). A separately re-identified local test copy was started without touching the normal application container; native UI inspection timed out, so this is not claimed as a desktop visual acceptance pass.
- Desktop bundles are not Apple-notarized or commercially Windows-signed.
- User confirmed no Apple Developer distribution configuration. iOS delivery is a successful `--no-codesign` device build and clearly labeled unsigned bundle, not an installable IPA, TestFlight or App Store publication.

## Deployment and signed upgrade

- Local verification matched the official manifest for APK, Web ZIP and macOS ZIP. The Web archive passed complete extraction checks; its uploaded server copy matched the same digest.

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| Android APK | 87,454,262 | `45c26763f15d2f7bc1ce65a9e9a9b6b4b2017f1a5b181a1e9046db6df0526090` |
| Web ZIP | 26,639,576 | `7de9c0f5afc65eb45947d175031a6c50c8603e37554fabf3e48ea7187d49b07b` |
| macOS ZIP | 26,566,568 | `49d87a596123bc00b3fe53777259fea93fb96ac2af9ab2ccaa47fbc4b8ac65c7` |

- APK signature verification passed with the stable certificate. Android accepted `adb install -r` over v1.3.0, now reports `1.4.0+27`, and retained `firstInstallTime=2026-09-05 03:41:31`.
- In the anonymous emulator fixture, Week 1 / Day 1, the in-progress High-Bar Squat draft at 77.5 kg, and the 82.6 kg body metric all survived the upgrade. This is not a new authenticated-account migration canary.
- 241 was fast-forwarded to the release commit. Backend code and database schema did not change in this release, so its healthy service was not restarted.
- Web was activated atomically at `/var/www/fittin/releases/v1.4.0/web`. The v1.3.0 target remains intact for rollback.
- Public version is `1.4.0+27`; `/api/readyz` passed, unauthenticated Agent relay returned 401, main JavaScript is gzip encoded, and WebAssembly has `application/wasm` MIME type.
- The exact production Web archive starts normally on localhost. A secure public-origin browser check at 390×844 displayed the complete Home navigation and free-training entry with no page errors, using the real ECS address and HTTP/1.1.
- Network caveat: the local DNS/proxy route resolved the domain to `198.18.9.152`; repeated default-route cold loads encountered slow transfers and `ERR_CONNECTION_CLOSED` before main JavaScript completed. A 1.48 MB compressed main bundle download took about 26 seconds. This transport issue and the existing 30-second launch warning are not claimed fixed. No global proxy settings, shared nginx transport settings, or paid bandwidth settings were changed.
- First-party APK was uploaded and verified on the server. Its public HEAD reports 87,454,262 bytes. After the upgrade and public-page gates, `/releases/latest.json` was atomically advanced to `1.4.0`, build `27`, with the verified APK digest. The previous manifest is retained server-side as `latest.json.before-v1.4.0`.
- First-party download: [Android v1.4.0](https://fittin.hammerscholar.net/releases/v1.4.0/).
