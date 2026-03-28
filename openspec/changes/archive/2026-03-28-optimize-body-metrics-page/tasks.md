## 1. Screen State And Hierarchy

- [x] 1.1 Add screen-level derived view-state logic in `body_metrics_screen.dart` for empty, partial, and populated Body Metrics states
- [x] 1.2 Refactor the page composition so the top module always acts as the primary progress surface instead of allowing the hero region to disappear
- [x] 1.3 Rework the body fat and waist summary cards into lower-emphasis supporting highlights with clear treatments for current, comparison-unavailable, and not-yet-recorded states

## 2. Entry Guidance And History Presentation

- [x] 2.1 Add inline empty-state and partial-state guidance that directs users to record their first or more complete measurement while preserving the floating action button flow
- [x] 2.2 Update the measurement log rows to provide clearer recorded-date context and a more coherent relationship to the summary modules
- [x] 2.3 Adjust any supporting dashboard primitives only where necessary to support the revised hero, summary-card, and log treatments without broad unrelated redesign

## 3. Verification

- [x] 3.1 Verify the Body Metrics screen behavior for no-data, partial-data, and populated-data scenarios against the new spec requirements
- [x] 3.2 Verify the revised layout and affordances remain readable and visually coherent on both mobile-sized and macOS-sized layouts
