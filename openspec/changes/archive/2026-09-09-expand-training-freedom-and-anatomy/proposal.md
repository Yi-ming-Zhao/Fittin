## Why

Training should adapt to a user's day without damaging plan progression. The current schedule, history editor, limited catalog and simplified anatomy views make that flexibility and feedback difficult on phones.

## What Changes

- Add explicit skip-day, bring-forward and free-training flows, and distinguish deleting history from releasing a recorded day back into the plan.
- Reuse the active workout recording interaction to edit history while protecting live drafts and progression snapshots.
- Expand the bilingual strength and cardio catalogs with source-traceable classifications and structured exercise variations.
- Replace the anatomy load diagram with interactive front, back and side views.
- Render equipment-appropriate dumbbell weight guidance and refine mobile spacing, hierarchy and deep navigation.
- Validate and release Android and Web; build iOS without signing unless an existing distribution signing path is available.

## Capabilities

### New Capabilities
- `free-training`: Plan-independent sessions and safe history release semantics.

### Modified Capabilities
- `flexible-microcycle-scheduling`: Explicit skip-day operation alongside bring-forward.
- `editable-workout-history`: Recording-style history editing and separate deletion choices.
- `exercise-library`: Expanded catalog and structured special characteristics.
- `cardio-activity-tracking`: Expanded activity types and relevant measurements.
- `advanced-training-analytics`: Three-view interactive anatomical load visualization.
- `weight-unit-and-plate-calculator`: Dumbbell-specific per-hand weight visualization.
- `adaptive-mobile-surfaces`: Consistent phone-first hierarchy and deep-screen spacing.

## Impact

Flutter domain/session and local repositories, exercise assets and Agent DTOs, recording/history/catalog/analytics screens, localized text and tests. Existing IDs, records, account state and theme choices must remain compatible. No unconfirmed Agent writes or change to cloud credential handling.
