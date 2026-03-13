## Why

The third bottom-navigation destination is still a placeholder, but the app now stores enough workout history to support meaningful progress analysis. Users need a real analytics surface that shows whether each exercise is improving over time, especially through estimated and actual 1RM trends instead of only per-session logs.

## What Changes

- Add a dedicated progress analytics screen for the third bottom-navigation destination.
- Add exercise-level strength analysis for all logged movements, including estimated 1RM trend, actual 1RM history, PR events, and recent change windows.
- Add configurable estimated-1RM formula support, including common formulas such as Brzycki, Epley, Landers, Lombardi, Mayhew, O'Conner, and Wathan.
- Distinguish estimated 1RM from actual 1RM so the app does not present formula-derived values as true maxes.
- Add supporting analysis summaries such as recent tonnage, training frequency, and stagnation detection where enough history exists.
- Modify the current insights/dashboard capability so the third tab becomes a real analysis surface instead of a static visual demo.

## Capabilities

### New Capabilities
- `progress-analytics`: exercise-level progress analysis, 1RM formula selection, PR history, and trend summaries.

### Modified Capabilities
- `data-insight-dashboard`: replace the existing placeholder third-tab content with a functional progress analysis destination.

## Impact

- Affected code: bottom navigation shell, analytics/insights presentation layer, workout-log aggregation, and history-derived metrics.
- Affected domain logic: estimated 1RM calculation utilities, actual-vs-estimated max classification, aggregation windows, and PR/stagnation detection.
- Affected persistence/read paths: workout log queries and derived analytics view models.
- Affected UX: new charts/cards/list views for exercise progress, formula selection, and bilingual analysis labels.
