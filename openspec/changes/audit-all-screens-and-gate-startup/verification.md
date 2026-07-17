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
- Full deterministic Flutter suite after the final visual and race-condition iteration: 314 tests passed serially.
- Palette guards: five complete palettes meet contrast requirements and contain no cyan or teal theme colors.
- Production Web build: succeeded against `https://fittin.hammerscholar.net/api`.
- Android resource build: debug APK compiled successfully with the native launch mark.

CI, signed artifacts, checksums, signer verification, public deployment, and exact release URLs are appended after the exact-SHA release workflow completes.
