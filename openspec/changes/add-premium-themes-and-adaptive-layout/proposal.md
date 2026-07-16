## Why

Fittin currently has two disconnected theme paths, non-persisted appearance state, and scattered literal colors, so changing a palette cannot reliably update text, controls, charts, illustrations, or Material surfaces as one coherent system. The Today and Body tabs also use fixed spacing and dense grids that do not distribute content well across short mobile-web and tall Android viewports.

## What Changes

- Replace the split theme paths with one persisted, semantic theme source that derives both `ThemeData` and Fittin-specific component tokens.
- Inventory every color-bearing UI role, including backgrounds, surfaces, text, icons, borders, dividers, shadows, scrims, controls, charts, anatomy maps, workout gestures, statuses, and equipment illustrations.
- Add five curated, contrast-checked palettes with distinct refined visual directions and no cyan/teal colors.
- Add a bilingual Appearance section under My/Settings with rich palette previews, immediate application, current-selection feedback, and persistence across launches.
- Route reusable primitives and remaining literal UI colors through semantic tokens while retaining meaning for errors, success, heat intensity, and standardized barbell plates.
- Make the Today tab distribute its modules across the available safe height on tall phones while remaining naturally scrollable on short mobile browsers.
- Make the Body tab use a more breathable responsive composition, including an adaptive metric grid and minimum viewport filling for empty, partial, and populated states.
- Add automated theme coverage, persistence, contrast, localization, responsive-layout, and regression checks, followed by visual QA of every palette at tall and short mobile viewports.
- Publish and deploy a new signed Android/web release after CI passes.

## Capabilities

### New Capabilities

- None. This change completes and extends existing theme, settings, and adaptive-surface capabilities.

### Modified Capabilities

- `theme-system`: Define a complete semantic color-token contract and a single resolved source for custom and Material components.
- `multi-theme-system`: Define the curated palette set, instant switching, preview, persistence, and contrast expectations.
- `profile-screen`: Add the bilingual Appearance settings surface under My.
- `design-system-primitives`: Require shared primitives to consume semantic tokens instead of literal UI colors.
- `interactive-charting`: Theme chart series, axes, grid, selection, and tooltip colors coherently.
- `adaptive-mobile-surfaces`: Define content distribution behavior for tall and short safe viewports.
- `home-screen`: Make the Today composition fill tall screens without compacting the modules around the center.
- `body-screen`: Make Body summaries and actions breathe and reflow according to available width and height.
- `body-metrics-tracker`: Refine responsive metric-grid and empty/partial-state composition behavior.

## Impact

The change affects global app bootstrapping, Riverpod appearance state, shared preferences, Material `ThemeData`, Fittin theme tokens, reusable dashboard/chart/navigation primitives, the Profile, Today, and Body screens, localization strings, widget tests, visual-regression tooling, CI release metadata, and web/Android release deployment. It does not change backend APIs or stored training data.
