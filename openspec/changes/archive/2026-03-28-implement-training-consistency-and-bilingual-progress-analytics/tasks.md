## 1. Analytics Data Model

- [x] 1.1 Audit the current progress and advanced analytics providers to identify available completed-workout and active-plan date sources.
- [x] 1.2 Extend analytics models/providers to expose day-level consistency data for weekly, monthly, and plan-relative weekly groupings.
- [x] 1.3 Define the drilldown mapping from a selected consistency day to the existing historical training record route.

## 2. Advanced Analytics UI

- [x] 2.1 Replace the placeholder consistency heatmap with a premium consistency explorer that supports week, month, and plan-relative range controls.
- [x] 2.2 Surface real recorded-day states, empty states, and localized helper copy in the consistency explorer.
- [x] 2.3 Make recorded days tappable and navigate to the corresponding training record while preserving back navigation to analytics.

## 3. Bilingual Analytics Support

- [x] 3.1 Move hard-coded progress analytics and advanced analytics copy into localized string accessors for English and Chinese.
- [x] 3.2 Update progress analytics, advanced analytics, and related drilldown surfaces to use localized labels consistently.

## 4. Verification

- [x] 4.1 Add or update provider/widget tests covering weekly, monthly, and plan-relative consistency grouping.
- [x] 4.2 Add or update interaction tests covering tapping a recorded day and opening the correct training record flow.
- [x] 4.3 Add or update localization tests verifying analytics copy switches correctly between English and Chinese.
