## Why

Fittin's mobile surfaces currently mix fixed-height layouts, placeholder analytics visuals, duplicated exercise names, and charts that cannot explain individual data points. This makes the Android app and mobile web feel inconsistent, prevents reliable bilingual exercise identity and load estimation, and leaves progress views less useful than the training data already available.

## What Changes

- Make every primary non-settings surface fill the current safe viewport while adapting to both tall Android app windows and shorter mobile browser windows without artificial bottom gaps.
- Rebalance the active-session card stack to use available height and replace the simplified plate strip with a proportioned mirrored Olympic-barbell visualization that keeps an accessible text breakdown.
- Recompose PR Dashboard into a one-screen mobile overview with compact Big Three PRs, one swipe-selectable detailed lift curve, and milestone actions that default to the Big Three but can be customized in settings.
- Introduce one canonical bilingual exercise library for powerlifting, assistance, and bodybuilding movements, with stable IDs, movement/muscle metadata, aliases, main-lift relationships, and conservative initial-load estimation metadata.
- Maintain per-exercise performance profiles from completed records, including best actual/equivalent 1RM and representative RM values, and use those profiles when estimating a new plan's starting loads.
- Replace the recent-month consistency approximation with navigable calendar months and implement a real, data-driven anatomical front/back load map.
- Standardize all line charts on explicit labeled x/y axes, tappable data points, localized detail readouts, and accessible selected-point semantics.
- Add weight-chart axes and point details to Body Metrics, make Home e1RM swipe-selectable across Squat/Bench/Deadlift, and complete Chinese/English coverage on every affected surface.
- Preserve existing local and synchronized records through stable-ID/alias migration rather than rewriting or discarding historical user data.

## Capabilities

### New Capabilities

- `adaptive-mobile-surfaces`: Safe-area-aware, viewport-filling layout rules shared by Android and mobile web surfaces.
- `exercise-library`: Canonical stable exercise identities with confirmed Chinese/English display names, aliases, taxonomy, muscles, equipment, and main-lift relationships.
- `exercise-performance-profile`: Per-exercise RM/1RM bests, provenance, confidence, and conservative starting-load estimates derived from user records and main-lift relationships.
- `interactive-charting`: Shared axis, point-selection, tooltip/detail, localization, and accessibility behavior for line charts.

### Modified Capabilities

- `home-screen`: Fill the mobile viewport and let the e1RM summary swipe between the Big Three.
- `training-log-screen-refactor`: Expand the card logger into available height and render a physically proportioned mirrored barbell and plate stack.
- `pr-dashboard`: Fit the primary overview in one mobile viewport, use a swipe-selectable single-lift curve, and support configurable milestone exercises.
- `advanced-training-analytics`: Provide navigable calendar months and a real front/back anatomical load visualization driven by completed sets.
- `body-metrics-tracker`: Require labeled weight axes and tappable point detail.
- `progress-analytics`: Use canonical exercise identities and shared interactive charts throughout progress analysis.
- `exercise-deep-dive`: Present RM curves with labeled axes and selectable data points backed by canonical performance profiles.
- `app-language-settings`: Persist milestone exercise choices and guarantee complete English/Chinese copy for affected screens and dynamic exercise names.
- `local-datastore-schema`: Persist canonical exercise IDs, performance profiles, estimation provenance, and milestone preferences while migrating legacy names safely.
- `plan-rule-engine`: Resolve plan exercises through the canonical library and estimate missing starting loads conservatively at plan start.

## Impact

- Affects Flutter presentation screens, shared chart/barbell/anatomy painters, localization strings, settings, providers, plan parsing/runtime evaluation, workout conclusion processing, and local/web persistence.
- Adds bundled canonical exercise data and migration/alias logic; existing plan assets and workout history remain readable.
- Requires targeted provider/model/widget tests, generated-model regeneration if persisted models change, mobile viewport golden/screenshot checks, and regression verification on Android and Web.
- External exercise and estimation references will be recorded as product metadata/documentation; ratios remain editable recommendations with visible provenance and are never treated as guaranteed prescriptions.
