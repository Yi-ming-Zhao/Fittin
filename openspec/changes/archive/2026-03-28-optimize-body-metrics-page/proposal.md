## Why

The current Body Metrics screen feels visually premium but functionally unfinished: large empty cards dominate the page, missing data states are unclear, and users are not guided toward recording or reviewing measurements. This change is needed now because the existing experience does not fulfill the intended value of body metrics tracking as a progress surface tied to training outcomes.

## What Changes

- Restructure the Body Metrics page so it has a clear primary focus instead of two oversized low-information cards.
- Improve empty, partial, and populated states so users can understand whether they have no measurements, incomplete measurements, or recent data to review.
- Add stronger measurement-entry affordances and clearer context around the latest recorded values and measurement history.
- Refine the relationship between current values, historical trend, and measurement log so the page reads as a usable progress dashboard rather than a placeholder layout.
- Align the screen's visual hierarchy with the app's premium minimal design language without sacrificing clarity or discoverability.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `body-metrics-tracker`: Update Body Metrics requirements to cover clearer page hierarchy, actionable empty states, more informative current metric presentation, and a more coherent relationship between trend data and measurement history.

## Impact

- Affected spec: `openspec/specs/body-metrics-tracker/spec.md`
- Likely affected UI: `lib/src/presentation/screens/body_metrics_screen.dart`
- Potentially affected supporting UI primitives for dashboard cards, chart containers, and measurement-entry interactions
- No expected API or backend contract changes; primary impact is on product behavior, page composition, and state presentation
