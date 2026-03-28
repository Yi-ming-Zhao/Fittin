## Context

The analytics area currently has a premium visual shell, but the training consistency module inside advanced analytics is still placeholder-driven and limited to a static 90-day heatmap metaphor. It does not let users inspect consistency in the ways they actually review training history: recent weeks, calendar-month context, and week-by-week progress since the current plan began. The progress analytics page also still contains hard-coded English strings in several premium cards and drilldown surfaces, so the analytics flow does not fully honor the app-level language toggle.

This change spans provider logic, screen composition, localization strings, and navigation from analytics into concrete historical training records. It is worth designing up front because the same source session data needs to feed multiple consistency ranges and the new drilldown should avoid inventing a second record-detail surface.

## Goals / Non-Goals

**Goals:**
- Build a real training consistency explorer backed by completed workout records.
- Support three consistency ranges: recent weeks, calendar month, and plan-relative weeks from the active plan start.
- Allow tapping a recorded day to jump into the corresponding historical training record.
- Localize the progress analytics and advanced analytics experience in English and Chinese.
- Preserve the premium layout and maintain usable behavior on both mobile and macOS.

**Non-Goals:**
- Redesigning unrelated analytics cards such as muscle load distribution beyond the localization needed for consistency.
- Adding server-side analytics or remote aggregation.
- Supporting arbitrary custom date ranges in this iteration.
- Introducing a brand-new history detail page if an existing record/detail route can be reused.

## Decisions

### 1. Build a single consistency view model with multiple presentation ranges

The provider layer should produce a normalized day-level activity map from completed sessions, then derive week, month, and plan-relative sections from that common source. This keeps aggregation rules in one place and prevents the UI from recomputing grouping logic independently for each tab.

Alternatives considered:
- Compute each range directly in the widget tree: rejected because it would duplicate date logic and make testing range behavior harder.
- Keep the current heatmap-only model and just relabel it: rejected because it would still not satisfy month and plan-relative requirements.

### 2. Treat plan-relative grouping as active-plan-aware, with safe fallback

Plan-relative week grouping should anchor to the active plan start date when one exists. If there is no active plan context, the provider should fall back to the earliest available completed session date so the mode remains usable instead of becoming unavailable.

Alternatives considered:
- Hide plan-relative mode without an active plan: rejected because it creates a dead control state for users with historical data.
- Always anchor to the first historical session: rejected because it is less accurate when an active plan exists.

### 3. Reuse existing historical workout navigation

Tapping a recorded day should route into the existing training record or completed-workout detail flow rather than creating a new analytics-specific detail page. The consistency explorer only needs to resolve the selected date into the relevant completed record(s) and hand off to the existing navigation pattern.

Alternatives considered:
- Show records inline inside the analytics page: rejected because it would overload the consistency surface and weaken the premium hierarchy.
- Build a brand-new record detail screen for analytics: rejected because it duplicates history presentation and raises maintenance cost.

### 4. Localize analytics through AppStrings rather than screen-local constants

All new and existing user-facing analytics copy should move into shared localization accessors so progress analytics and advanced analytics follow the same language switching behavior as the rest of the app. Range labels, empty-state text, section headings, and helper copy should all come from localized strings.

Alternatives considered:
- Localize only the new consistency view: rejected because the broader progress analytics page would remain mixed-language.
- Keep some “design copy” hard-coded for premium screens: rejected because it breaks bilingual consistency and testability.

## Risks / Trade-offs

- [Date grouping ambiguity across time zones] → Normalize completed session timestamps to local calendar days before grouping and test boundary cases.
- [Plan-relative mode can be confusing if plan start metadata is missing] → Use clear localized labels and documented fallback behavior based on earliest completed session.
- [A selected day may contain multiple completed workouts] → Navigate to the most appropriate existing record entry point and expose the date context in the handoff.
- [Localization expansion can change premium layout density] → Prefer concise copy and validate key analytics surfaces in both English and Chinese widget tests.

## Migration Plan

1. Extend analytics provider models to expose normalized day activity and range-specific consistency sections.
2. Replace placeholder consistency UI with a premium segmented/range-controlled explorer.
3. Wire day tap interactions to existing historical workout navigation.
4. Move remaining analytics copy into localization strings and update tests for both locales.

## Open Questions

- Which existing training-record detail route is the cleanest destination when a day contains multiple completed workouts?
- Whether month mode should show a rolling recent month window or a current-calendar-month-first presentation by default.
