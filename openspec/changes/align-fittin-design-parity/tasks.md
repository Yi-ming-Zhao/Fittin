## Implementation Tasks

- [x] T1: Protect local work, pull `origin/main`, and keep unrelated untracked files out of the redesign change.
- [x] T2: Add OpenSpec proposal, design, delta specs, and this task list for `align-fittin-design-parity`.
- [x] T3: Align `FittinTheme` defaults/tokens with the prototype and remove visual drift from hardcoded fallback styling.
- [x] T4: Align shared cards, page scaffold, typography, chips, segmented controls, buttons, divider, charts, and bottom nav with prototype primitives.
- [x] T5: Align Today/Home visible layout with the prototype's top meta row, session hero, stat cards, activity chart, and quick actions.
- [x] T6: Align Plans library/detail/editor surfaces with prototype filters, plan cards, active state, stats, and stacked editor fields.
- [x] T7: Align PR/Progress dashboard and related progress surfaces with prototype PR cards, segmented controls, stepped charts, and milestone rows.
- [x] T8: Align Body metrics and Profile/settings surfaces with prototype hero cards, logs, language/account/tools/reference/visual sections.
- [x] T9: Run Flutter analysis/tests and fix regressions caused by the design parity work.
- [x] T10: Run local Fittin, compare visually against the prototype with Computer Use, iterate until the main tabs match closely.
- [x] T11: Add a unified prototype-style back control and apply it to every non-root page.
- [x] T12: Use Computer Use to traverse all reachable subpages, dialogs, and sheets, then align them with the prototype primitives.
- [x] T13: Fix auth/backend connection failures so release builds use explicit `BACKEND_URL` and users see friendly errors instead of socket dumps.
- [x] T14: Update release docs to require `--dart-define=BACKEND_URL=https://api.yimelo.cc` for Web and Android.
- [x] T15: Re-run focused and broad verification, then commit and push only after parity and auth checks are complete.
