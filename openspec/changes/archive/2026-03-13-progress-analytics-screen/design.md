## Context

The app already records complete workout logs, active plan context, localized plan content, and computed training prescriptions, but the third bottom-navigation destination is still only a placeholder insight surface. Users now have enough historical data to support a true progress screen centered on exercise-level strength development, especially estimated 1RM and actual 1RM history across all logged lifts.

This change crosses multiple layers: workout-log querying, analytics aggregation, 1RM formula math, localization, and the third-tab presentation shell. It also needs a clear product distinction between formula-derived values and true single-rep achievements so the app does not overstate user performance.

## Goals / Non-Goals

**Goals:**
- Replace the third bottom-navigation page with a real progress analytics destination.
- Aggregate all workout logs into exercise-level progress summaries that support trend views, PR detection, recent change windows, and stagnation hints.
- Support multiple estimated-1RM formulas, including Epley, Brzycki, Landers, Lombardi, Mayhew, O'Conner, and Wathan.
- Distinguish estimated 1RM from actual 1RM and only treat explicit single-rep max efforts as real 1RM records.
- Keep the analytics surface bilingual and compatible with localized built-in plan content.

**Non-Goals:**
- Do not add cloud sync or cross-device analytics storage.
- Do not attempt fatigue/readiness coaching, body-composition analysis, or AI-written performance advice in this change.
- Do not reclassify different exercise variants into one canonical movement family beyond exact logged exercise identity.
- Do not add manual historical data import for legacy workouts outside the app.

## Decisions

### 1. Build analytics from workout logs, not from plan templates
Analytics will be computed from persisted workout-log history instead of plan definitions or in-progress session state. That keeps the source of truth tied to completed work and allows the screen to summarize custom plans, built-in plans, and imported plans uniformly.

Alternative considered:
- Reading from current template or active session state would be simpler, but it would miss historical progress and break once the user switches plans.

### 2. Separate actual 1RM from estimated 1RM in the domain model
The analytics layer will produce two distinct result types:
- `actual1rm`: only from completed single-rep sets marked as successful max attempts or from one-rep completed work sets
- `estimated1rm`: derived from eligible logged sets using the selected formula

The UI will never relabel estimated values as actual maxes. If no true 1RM exists for an exercise, the screen shows that explicitly.

Alternative considered:
- A single “1RM” metric is simpler to render, but it blurs inferred and observed performance and would mislead users.

### 3. Use a formula registry with one global selected formula
Estimated-1RM calculation will be implemented as a registry of named formulas, with one persisted app-wide selection for analytics rendering. The analytics screen can compare formulas in a secondary view, but the primary trend/list UI uses one selected formula at a time for consistency.

Alternative considered:
- Per-exercise formula selection adds flexibility but increases UI complexity and makes cross-exercise comparisons harder.

### 4. Filter e1RM candidates to meaningful strength sets
Estimated-1RM calculations will only consider weighted sets within a bounded rep range, such as 1 to 10 or 1 to 12 reps, and ignore obviously noisy high-rep sets. For each logged exercise encounter, the aggregator will use the strongest eligible set as that session’s representative estimated-1RM point.

Alternative considered:
- Using every set inflates noise and favors high-volume accessory work in ways that do not reflect usable max strength.

### 5. Deliver the screen in three layers
The third-tab analytics page will be structured as:
- summary cards for recent progress context
- exercise list ranked/filterable by progress signals
- exercise detail section or drill-down with trend history and PR events

This avoids overloading the landing page while still making “all exercises” discoverable.

Alternative considered:
- A single dense dashboard would surface more data at once but would be hard to scan on mobile.

### 6. Compute derived analytics in an application service, not directly in widgets
An application-level analytics service/provider will:
- query workout logs
- normalize per-exercise history
- compute actual/e1RM points
- derive PRs, recent change windows, and stagnation flags

Widgets will consume pre-shaped view models rather than implement formulas or log iteration inline.

Alternative considered:
- Widget-level computation is quicker to start but would create duplicated logic and make testing formula math much harder.

## Risks / Trade-offs

- [Sparse history makes charts look empty] → Show explicit empty states and minimum-data thresholds before rendering trends.
- [Different 1RM formulas produce noticeably different numbers] → Persist the chosen formula, label it clearly, and keep comparison formulas as secondary information.
- [Accessory exercise names may fragment history] → Analyze exact exercise identity for now and defer movement-family grouping to a later change.
- [Large workout histories may make the screen expensive to build] → Aggregate in a provider/service and memoize by formula plus log revision instead of recalculating in the widget tree.
- [Users may assume single-rep work always equals a true tested max] → Only classify “actual 1RM” from explicit successful one-rep logged efforts and label the metric accordingly.

## Migration Plan

No data migration is required for existing templates or instances. The change reads from existing workout logs and adds derived analytics on top. If a persisted formula preference is introduced, default it to Epley for users who do not yet have a saved preference.

## Open Questions

- Whether the first version should support line charts only or include additional chart types such as PR timelines and volume overlays.
- Whether stagnation detection should use fixed windows (for example 30/42 days) or exercise-frequency-aware thresholds.
- Whether the analytics screen should show exact exercise IDs only or also surface optional user-facing grouping by lift family in a later iteration.
