## Why

The current training consistency experience is still a placeholder and does not let users review their training record in practical time ranges or drill into a specific day. The broader progress analytics page also mixes hard-coded English copy with localized UI, which breaks the bilingual experience and makes the analytics surface feel unfinished.

## What Changes

- Replace the placeholder training consistency section with a real analytics experience that can present completed training activity by week, by month, and by plan-relative week from the start of the active plan.
- Let users tap a specific day in the consistency view to open the concrete training record(s) associated with that date.
- Localize progress analytics and advanced analytics copy so the entire analytics flow respects the app language setting in both English and Chinese.
- Preserve the premium visual direction while making the consistency UI navigable and information-dense on both mobile and macOS layouts.

## Capabilities

### New Capabilities

### Modified Capabilities
- `advanced-training-analytics`: Replace the placeholder consistency heatmap with real week/month/plan-relative views and day-level drilldown into training records.
- `progress-analytics`: Require bilingual/localized copy across the progress analytics and advanced analytics surfaces.

## Impact

- Affected code in analytics providers, analytics screens, localized strings, and navigation into historical workout details.
- May require extending the analytics data model to aggregate sessions by day and by active-plan-relative week.
- Requires widget and interaction coverage for localized labels, period switching, and day drilldown behavior.
