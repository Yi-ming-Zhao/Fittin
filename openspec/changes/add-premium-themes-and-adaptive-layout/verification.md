# Verification Evidence

## Production visual matrix

- Build: `tool/build_web_release.sh https://fittin.hammerscholar.net/api`
- Viewports: 390x926 English, 390x568 English, and 390x568 Chinese
- Palettes: Obsidian Brass, Midnight Cobalt, Bordeaux Velvet, Porcelain Ink, and Espresso Ember
- Surfaces: Today, Body, My/Appearance, active workout card stack, interactive body chart, and bottom navigation
- Result: no page exceptions, console errors, horizontal overflow, clipped controls, bottom-navigation overlap, or unreadable palette combinations in the final sequential runs
- Responsive result: Today uses a relaxed top-anchored composition on tall screens and one compact vertical scroll on short screens; Body uses a height-aware trend module and a 2+1 metric composition at 390 px

## Automated verification

- `flutter analyze --no-pub`: no issues
- `tool/run_ci_flutter_tests.sh`: all 290 tests passed with deterministic serial execution
- Palette guards: all custom and Material 3 color roles are complete, meet required contrast checks, and contain no cyan or teal
- Startup host guard: Android, Android 12+, iOS Launch/Main, and web pre-bootstrap surfaces use the expected warm-black or restored Porcelain Ink canvas
- Pre-bootstrap browser probe: Obsidian Brass resolved to `rgb(9, 8, 6)` and Porcelain Ink resolved to `rgb(243, 238, 229)` before Flutter loaded
- `openspec validate add-premium-themes-and-adaptive-layout --strict`: valid
- `git diff --check`: clean
- Production web build: succeeded against `https://fittin.hammerscholar.net/api`
- Exact-SHA GitHub CI: commit `b4f0016a30f63ed6852b7f161df42bd060d3a032`, run [29515570375](https://github.com/Yi-ming-Zhao/Fittin/actions/runs/29515570375); Flutter 3.41 analysis/tests and backend tests all passed

## v1.0.9 release verification

- Annotated tag `v1.0.9` resolves to commit `b4f0016a30f63ed6852b7f161df42bd060d3a032`.
- Release workflow [29515805032](https://github.com/Yi-ming-Zhao/Fittin/actions/runs/29515805032) passed and published the formal [v1.0.9 GitHub Release](https://github.com/Yi-ming-Zhao/Fittin/releases/tag/v1.0.9), which is the current latest non-draft, non-prerelease release.
- The five public assets were unique, complete, and anonymously downloadable: APK (83,580,096 bytes), AAB (64,006,451 bytes), Web ZIP (19,492,000 bytes), SHA-256 manifest, and release notes.
- APK, AAB, and Web ZIP independently matched `fittin-v1.0.9-sha256.txt`.
- APK metadata resolved to package `com.example.fittin_v2`, application label `Fittin`, version name `1.0.9`, and version code `16`; APK Signature Scheme v2 verification passed.
- AAB JAR verification passed. APK and AAB both used certificate DER SHA-256 `0c52c1350c14a360c833422967ac33469572e9acb64a33ddaad1a407532d0671`, matching the stable Fittin release signer.
- The Web ZIP declared version `1.0.9`, build `16`, and contained `web/index.html`, `web/flutter_bootstrap.js`, and `web/main.dart.js`.
- Release notes contained the v1.0.9 theme and adaptive-layout content, the complete asset list, and no missing-asset marker.

Direct Alibaba Cloud deployment remains tracked in task 7.4 until its remote checks complete.
