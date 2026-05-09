## Why

The current Flutter frontend is close to the archived redesign, but still diverges from the full Claude Fittin prototype in spacing, card treatment, typography, chart presentation, and several main-tab layouts. This change makes the app visually match the prototype as the design source of truth.

## What Changes

- Align shared theme tokens, cards, typography, segmented controls, buttons, bottom navigation, and chart primitives with the local `Fittin-design.zip` prototype.
- Update the Today, Plans, PR/Progress, Body, and Profile surfaces so their visible hierarchy, spacing, and repeated UI patterns match the prototype.
- Preserve current navigation, data providers, persistence, sync, and training behavior.
- Keep the redesign dark-only and restrained, with a single accent at a time.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `theme-system`: Theme tokens must resolve to the prototype's dark visual directions, density, accent, typography, and chart/card defaults.
- `design-system-primitives`: Shared primitives must match the prototype's cards, typography, controls, buttons, dividers, charts, and bottom tab bar.
- `home-screen`: Today must match the prototype's at-a-glance session, stat, activity, and quick-action layout.
- `plans-screen`: Plan library and related plan surfaces must match prototype filtering, cards, active state, stats, and editor density.
- `progress-screen`: PR dashboard and progress detail surfaces must use prototype segmented controls, stepped charts, PR cards, and milestone lists.
- `body-screen`: Body metrics must match the prototype's weight hero, metric row, check-in CTA, and measurement log layout.
- `profile-screen`: Profile/settings surfaces must match the prototype's account, language, weight tools, reference, and visual settings sections.

## Impact

- Affected code is limited to Flutter presentation/theme/widgets and OpenSpec artifacts.
- No public API, backend, database schema, sync contract, or training engine behavior changes are intended.
- Verification requires Flutter static/tests plus iterative visual comparison against the local/Claude prototype.
