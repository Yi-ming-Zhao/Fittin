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
- Backend tests, exact-SHA GitHub CI, release signing/assets, and public deployment remain tracked in `tasks.md` until their remote checks complete
