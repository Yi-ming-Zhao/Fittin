## Context

The current Flutter application already stores an `exerciseId` and display name on plan exercises and workout logs, derives e1RM summaries from completed logs, and has separate custom painters for sparklines, heatmaps, and muscle distribution. In practice, IDs and names are authored independently by each plan, primary lifts are discovered through English substring matching, chart painters do not share interaction or axis logic, the analytics calendar is a fixed recent-range grid, and several screens use fixed heights and trailing spacers that behave differently under Android and browser insets.

This change crosses presentation, localization, plan evaluation, record analytics, settings, bundled data, and persistence. Existing user records and built-in plan JSON must continue to load, and recommendations must be framed as editable starting suggestions rather than medically or scientifically guaranteed prescriptions.

## Goals / Non-Goals

**Goals:**

- Make the affected mobile layouts respond to the actual safe viewport while preserving compact one-screen workflows where requested.
- Establish one canonical, bilingual exercise identity layer without breaking legacy plan or history data.
- Build deterministic per-exercise RM/e1RM profiles and use them to produce conservative, explainable starting-load suggestions.
- Give all full line charts labeled axes, point selection, localized detail, and accessibility semantics through one reusable component.
- Replace calendar and anatomy placeholders with real historical navigation and data-driven front/back muscle regions.
- Keep every changed surface genuinely bilingual and add regression tests at both tall-app and short-browser mobile dimensions.

**Non-Goals:**

- Diagnosing injuries, prescribing maximal attempts, or claiming that an assistance ratio is universally valid.
- Replacing explicit coach-authored or user-authored plan weights.
- Treating cable-stack or selectorized-machine numbers as portable across different equipment.
- Shipping copyrighted exercise photography, scraped proprietary datasets, or a remote exercise-catalog dependency.
- Rebuilding unrelated desktop layouts or changing the existing sync conflict algorithm.

## Decisions

### 1. Bundle a versioned canonical exercise catalog and resolve at boundaries

Add a bundled JSON catalog plus typed domain objects. Each entry uses a stable kebab/snake-safe ID, `en` and `zh_CN` names, normalized aliases, movement pattern, equipment, muscle contribution weights, optional Big Three anchor, recommended ratio range/midpoint, confidence, and source-note identifiers. Plan parsing, log analytics, settings search, anatomy aggregation, and display localization call one resolver instead of implementing name heuristics independently.

Existing `Exercise.exerciseId` and `ExerciseLog.exerciseId` remain the storage boundary. Known legacy IDs/names resolve through aliases; unresolved values receive a deterministic `custom:<normalized-name>` identity and retain the original name. This avoids a breaking database rewrite while allowing future plans to author canonical IDs directly.

Alternative considered: importing a large third-party exercise database. Rejected because license quality, bilingual naming, equipment semantics, and stable identifiers vary, and a runtime dependency would make offline plan loading fragile.

### 2. Derive performance profiles from workout logs and persist only projection metadata/preferences

Completed workout logs remain the authoritative record. A shared `ExercisePerformanceProfileService` groups logs by resolved exercise ID and computes:

- best observed load for each completed-repetition count in the supported range;
- best actual single;
- best estimated 1RM with formula, source set/date/log, and confidence;
- current/recent points used by charts and milestone detection.

The profile is deterministic and can be rebuilt after sync or edits, preventing cache drift. A lightweight versioned projection/cache may be persisted for startup, but is invalidated by workout-log revision; milestone exercise IDs and catalog-version metadata are persisted as settings. This reuses the complete synced logs rather than introducing a second mutable source of truth.

Alternative considered: updating a separate profile collection transactionally on every save. Rejected initially because edited/deleted/synced workout logs would require complex reverse updates and introduce disagreement with the actual record history.

### 3. Use a transparent estimation ladder with conservative bounds

The estimator chooses the first available source:

1. same-exercise observed RM/e1RM profile;
2. the user's canonical anchor lift (Squat, Bench Press, or Deadlift) multiplied by the catalog's exercise-specific ratio;
3. no automatic numeric value when no defensible anchor exists.

For a target repetition count, the service converts estimated 1RM to an RM using the existing selectable formula, applies a confidence/conservatism factor, rounds down to the exercise increment, and returns a structured recommendation containing value, formula, anchor, ratio/range, catalog version, confidence, and warnings. Explicit `initialBaseWeight`, `%1RM`, bodyweight, and user-confirmed values win. Machine/cable values are always low-confidence local suggestions.

Ratios are product defaults, not scientific constants. Catalog entries store ranges and evidence categories; the UI shows the midpoint recommendation and lets the user edit before the plan instance begins. Formula-based e1RM is limited to supported, completed, positive-load sets (normally 1-10 reps); higher-repetition results remain observed RMs without being promoted to high-confidence 1RM.

Alternative considered: one global percentage per muscle group. Rejected because exercise mechanics and equipment differ too much and the result would appear falsely precise.

### 4. Introduce one interactive line-chart component

Create `InteractiveLineChart` with typed series/points and a painter responsible for plot bounds, grid, ticks, axes, lines, dots, and selected-point marker. The widget owns nearest-point hit testing, touch tolerance, selection state, localized date/value formatting, detail panel/tooltip, and semantics. Axis tick generation handles constant, sparse, and negative-delta domains and reserves measured label gutters.

Small decorative sparklines may remain non-interactive because they are not presented as analytical line charts; every analytical chart in PR, Body Metrics, Progress Analytics, and Exercise Deep Dive migrates to the shared component.

Alternative considered: adding a chart package. Rejected for this pass because current custom painters already cover drawing, while the required interaction/semantic surface is small and a new package would increase Web/Android rendering and theming risk.

### 5. Build a real calendar model rather than stretching the heatmap

Add selected-month state and a pure calendar builder that emits complete locale-aware week rows, including leading/trailing dates. Aggregate logs by local calendar date and allow previous/next/today navigation across the min/max record range. A recorded date opens the existing day/workout detail flow. The existing week and plan-relative views may remain as secondary ranges, but month mode becomes a real navigable calendar.

### 6. Render anatomy from owned vector paths and canonical muscle weights

Replace the placeholder distribution painter with an owned front/back vector schematic built from named `Path` regions. Catalog muscle contributions distribute each completed set across primary/secondary muscles; the analytics provider aggregates counts for the selected period and normalizes intensity against the highest region. The widget renders a legend, front/back labels, no-data state, and tap hit testing per region.

Alternative considered: a bitmap anatomy asset. Rejected because it cannot provide responsive theme colors, region hit testing, or accessible semantic labels without maintaining a second coordinate map.

### 7. Use safe-area constraints and bounded flexible regions

Primary shell screens derive usable height through `LayoutBuilder` inside `SafeArea`, remove magic bottom spacers, and use `SliverFillRemaining(hasScrollBody: false)` or a constrained minimum-height content column. The home dashboard uses responsive vertical rhythm; the logger assigns remaining height to a bounded card stack; PR Dashboard compacts header and Big Three summaries before a flexible dominant chart. Short viewports scroll or compact secondary content rather than overflow.

The design keeps the existing dark industrial/premium visual language: near-black surfaces, warm high-contrast accent (never teal), compact numeric typography, precise grid/axis lines, and restrained motion.

### 8. Make lift/exercise selection swipeable without gesture conflict

Home e1RM and PR curve use horizontal `PageView`s with visible indicators and explicit tap controls. The active-session four-way card gesture remains isolated to the workout card and is not nested in those views. Chart point selection uses taps, while horizontal drag remains owned by the surrounding page view; selected point resets when the page/lift changes.

### 9. Centralize bilingual dynamic display

Static copy is added to `AppStrings`; dates use the active locale; canonical exercise and muscle names come from catalog fields. No affected widget embeds an English-only conditional branch. Tests run both locales and search representative screens for known leftover English strings.

## Risks / Trade-offs

- [Legacy names may resolve ambiguously] → Prefer explicit IDs, maintain deterministic aliases, never guess when multiple matches exist, and preserve a custom identity fallback.
- [Assistance ratios can look more authoritative than evidence supports] → Store ranges/confidence/source categories, apply conservative factors, display provenance, and require confirmation for low-confidence suggestions.
- [Profile derivation over a large history may be expensive] → Compute in one pass, memoize by workout-log revision, and optionally persist a versioned rebuildable projection.
- [Custom chart labels may overlap on narrow screens] → Measure gutters, cap tick counts by width, abbreviate axis ticks while keeping full selected-point detail, and test 360 px widths.
- [Anatomical paths are schematic rather than medical illustrations] → Label the view as training-load distribution, keep regions recognizable, and avoid diagnostic claims.
- [One-screen PR layout may be too dense on very short browser windows] → Define a compact breakpoint; preserve primary summaries/chart and allow only secondary milestone content to scroll.
- [Adding catalog metadata to every plan at once is risky] → Resolve through the boundary adapter first, then migrate bundled plans incrementally with tests proving aliases retain history continuity.

## Migration Plan

1. Ship the catalog/resolver and mapping tests without rewriting stored data.
2. Route analytics, PR detection, localization, and anatomy aggregation through canonical IDs; retain original names for audit/display fallback.
3. Add interactive charts, calendar, responsive layouts, and settings preference persistence.
4. Enable estimates only for missing starting loads and place them behind explicit review/confirmation in plan-start flow.
5. Rebuild generated model files only if an existing persisted model changes; otherwise keep catalog/profile projection outside Isar schema to reduce migration risk.
6. Validate legacy plan assets, local/web persistence, both locales, Android/Web builds, and mobile screenshots before release.

Rollback disables recommendation application and returns display to original names while leaving recorded weights untouched; catalog IDs and preferences are additive and safe to ignore by an older build.

## Open Questions

- Final per-exercise ratio ranges and evidence notes will be populated from the research pass; entries without defensible support will remain low-confidence or have no automatic numeric estimate.
- The first catalog release will prioritize all exercises referenced by bundled plans plus a curated bodybuilding/powerlifting set; custom identities preserve everything outside that set until later catalog expansion.
