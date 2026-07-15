## 1. Canonical Exercise Data And Evidence

- [x] 1.1 Record authoritative exercise-taxonomy, RM-formula, and load-estimation sources with confidence/safety rules for product use.
- [x] 1.2 Add versioned canonical exercise models, bundled catalog data, normalized alias resolution, custom-ID fallback, and resolver tests.
- [x] 1.3 Cover every exercise referenced by bundled plans with stable IDs, verified English/Chinese names, movement/equipment/muscle metadata, and documented aliases.
- [x] 1.4 Fix workout-log creation to store the global canonical exercise ID instead of the plan occurrence ID and add legacy-ID/name normalization tests.
- [x] 1.5 Route plan display, workout analytics, PR primary-lift lookup, milestone labels, and muscle aggregation through the canonical resolver.

## 2. Exercise Performance Profiles And Starting Loads

- [x] 2.1 Implement deterministic per-exercise observed RM, best observed single, estimated 1RM, provenance, formula, and confidence projection from completed logs.
- [x] 2.2 Add conservative same-exercise and Big Three anchor estimation with target-rep conversion, confidence adjustment, rounding, equipment warnings, and unit tests.
- [x] 2.3 Integrate estimates only for missing plan-start loads, preserve explicit/user-confirmed values, and expose editable recommendation provenance in the plan-start flow.
- [x] 2.4 Persist versioned milestone exercise IDs and any rebuildable profile projection metadata across native and web reloads.
- [x] 2.5 Add localized searchable milestone-exercise settings with Big Three defaults and reset behavior.

## 3. Shared Interactive Chart System

- [x] 3.1 Build a reusable multi-series line-chart model/widget/painter with measured x/y axes, localized ticks/units, grid, point hit testing, selection details, and semantics.
- [x] 3.2 Add chart tests for sparse, constant, multiple-series, narrow-width, touch-selection, locale, and active-unit cases.
- [x] 3.3 Replace the Body Metrics weight chart with the shared component and show exact date/value/delta details.
- [x] 3.4 Replace PR progression, Progress Analytics, and Exercise Deep Dive analytical lines with shared interactive charts.
- [x] 3.5 Ensure decorative sparklines are not presented as unlabeled analytical charts and correct any inverted/misleading labels.

## 4. PR Dashboard And Home E1RM

- [x] 4.1 Recompose PR Dashboard into compact Big Three summaries plus one dominant chart that fits the common mobile viewport.
- [x] 4.2 Add horizontal swipe/tap/page-indicator lift selection to the PR chart while preserving range and point details.
- [x] 4.3 Filter milestone generation to configured canonical exercise IDs, defaulting to Squat/Bench/Deadlift, and keep full-history filtering localized.
- [x] 4.4 Make the Home e1RM card swipeable across canonical Squat/Bench/Deadlift with lift-specific value, delta, date, history, and indicator.

## 5. Calendar And Anatomical Analytics

- [x] 5.1 Implement a pure locale-aware calendar-month builder and selected-month state over the full workout history.
- [x] 5.2 Replace the recent-range month approximation with previous/next/today calendar navigation, full week rows, recorded-day states, and day-detail routing.
- [x] 5.3 Derive selected-period muscle volume from actual completed sets and canonical primary/secondary muscle contribution metadata.
- [x] 5.4 Implement owned front/back anatomical vector regions with normalized highlights, legend, no-data state, tap detail, localization, and semantics.
- [x] 5.5 Add provider/widget tests proving historical month navigation and real workout-to-muscle aggregation.

## 6. Responsive Mobile Surfaces And Barbell

- [x] 6.1 Remove fixed trailing gaps from the app shell and primary non-settings screens using safe viewport constraints and bounded fill/scroll behavior.
- [x] 6.2 Make Home fill tall Android and short mobile-browser viewports and fix narrow-width header/localization overflow.
- [x] 6.3 Allocate Active Session's remaining height to a bounded live card stack while preserving gesture thresholds, exactly-once state changes, and short-viewport usability.
- [x] 6.4 Replace the plate strip with a proportioned mirrored Olympic bar, sleeves, collars, ordered plate diameters/widths, exact text breakdown, and accessibility tests.
- [x] 6.5 Add explicit mobile viewport widget tests for Home, Active Session, PR Dashboard, Analytics, and Body Metrics at tall-app and short-browser dimensions.

## 7. Localization, Verification, And Release Readiness

- [x] 7.1 Move all affected static copy into AppStrings and localize canonical exercise/muscle names, dates, axes, calendar, anatomy, estimate, settings, gesture, error, and empty-state text.
- [x] 7.2 Add English/Chinese screen tests that fail on representative leftover wrong-language copy.
- [x] 7.3 Run code generation if required, format, targeted tests, full Flutter tests, Flutter analyze, Web build, and signed/release Android build checks.
- [x] 7.4 Perform iterative visual inspection at Android tall-phone and shorter mobile-browser viewports, capture evidence, and correct overflow, blank space, density, hit targets, and gesture conflicts.
- [x] 7.5 Audit every numbered objective against code, tests, and rendered evidence; then synchronize the 241 checkout, push, and monitor CI before marking the change complete.
