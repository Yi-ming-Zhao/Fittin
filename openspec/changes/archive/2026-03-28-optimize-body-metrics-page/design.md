## Context

The current Body Metrics screen already has the core ingredients for a useful progress surface: a page header, a weight chart, summary metric cards, a measurement log, and an add-measurement action. However, the current implementation in `lib/src/presentation/screens/body_metrics_screen.dart` under-delivers on the intended experience:

- the chart disappears entirely when no weight data exists, leaving the page without a clear hero module
- body fat and waist are rendered as large cards even when values are missing, which makes the page feel unfinished
- empty and partial states rely on ambiguous placeholder values such as `—%` and `—cm`
- the measurement log currently emphasizes weight only and functions more like a raw list than contextual support for the summary modules

This is a UI and product-behavior change, not a data-model or backend change. The existing `BodyMetric` model, provider, repository, and sync paths already support the relevant fields. The main design task is to reshape page composition and state presentation so the screen reads as a coherent premium dashboard.

## Goals / Non-Goals

**Goals:**
- Establish a clear screen hierarchy with one primary progress module and lower-priority supporting modules
- Make empty, partial, and populated states explicit and actionable
- Preserve the existing data model and entry flow while improving discoverability of measurement capture
- Keep the page aligned with the app's premium minimal visual language without sacrificing clarity
- Ensure the screen remains usable on mobile and macOS layouts

**Non-Goals:**
- Introducing new body metric fields or changing persistence contracts
- Reworking progress photo storage or comparison flows
- Building new backend APIs, sync logic, or analytics pipelines
- Redesigning unrelated dashboard primitives beyond what is necessary to support this screen

## Decisions

### 1. Treat the screen as a progress dashboard, not a metric form
The Body Metrics page will be organized around a single narrative:

1. primary progress insight
2. current supporting metrics
3. historical review and cleanup

This means the top module should always communicate "where am I in my body-change journey?" rather than immediately dropping the user into a pair of large stat cards. When weight data exists, the chart remains the hero. When it does not, that same area becomes an intentional empty-state module instead of disappearing.

Alternative considered:
- Keep the current layout and only shrink the cards. Rejected because it would improve spacing but would not solve the deeper issue that the page lacks a stable primary focus in empty or partial states.

### 2. Model screen states explicitly from existing metric data
The screen should derive three high-level states from the loaded metric list:

- `empty`: no measurements recorded
- `partial`: measurements exist, but one or more summary metrics or comparisons are unavailable
- `populated`: measurements and comparable trend context exist

This state model should drive copy, module visibility, and captions rather than forcing all modules to render the same placeholders. Existing field-level checks are enough to compute these states; no new persistence is required.

Alternative considered:
- Rely on per-widget null checks only. Rejected because it creates fragmented behavior where the chart, cards, and log each make independent assumptions and the screen loses narrative coherence.

### 3. Keep measurement entry in the existing flow, but reinforce it inline
The current floating action button already provides a measurement-entry path. The redesign should keep that global action while also adding inline call-to-action affordances inside empty and partial hero states so the user always sees the next step in context.

This avoids introducing a second competing entry flow while fixing the discoverability problem for users who land on a sparse or blank page.

Alternative considered:
- Replace the floating action button with only inline action surfaces. Rejected because the page still benefits from a persistent global entry affordance once the user has existing data.

### 4. Reframe metric cards as summary highlights instead of large placeholders
Body fat and waist cards should remain on the page, but as compact, clearly interpretable support modules. Their design should communicate one of three conditions:

- current value plus comparison delta
- current value without comparison yet
- not yet recorded

This lets the cards stay informative without occupying enough space to dominate the entire viewport when data is sparse.

Alternative considered:
- Remove the secondary cards entirely and push everything into the log. Rejected because users still need quick current-value scanning for body fat and waist without opening historical detail.

### 5. Keep the measurement log, but demote it in emphasis
The log remains valuable for recency, review, and deletion. It should stay below the summary modules and provide clear dates and recognizable metric context, but it should not visually compete with the chart and current-value summaries.

Alternative considered:
- Hide the log behind a separate detail page. Rejected because it increases navigation cost for a lightweight review function that fits naturally at the bottom of the dashboard.

## Risks / Trade-offs

- [Risk] The screen may become too copy-heavy if every state adds explanatory text.
  → Mitigation: keep empty and partial-state copy concise and action-oriented; rely on hierarchy and spacing more than paragraphs.

- [Risk] Reworking module hierarchy may require small adjustments to shared dashboard primitives.
  → Mitigation: favor composition changes in `body_metrics_screen.dart` first and only extend primitives where the screen cannot express the required states cleanly.

- [Risk] Users may still interpret missing body fat or waist as a bug if data entry remains weight-first.
  → Mitigation: explicitly label missing values as not yet recorded and point to the measurement-entry action from inline state messaging.

- [Risk] The page could drift away from the premium aesthetic if clarity becomes overly utilitarian.
  → Mitigation: preserve the existing material language, spacing rhythm, and premium surfaces while making state treatments deliberate rather than louder by default.

## Migration Plan

1. Update the `body-metrics-tracker` delta spec and align all implementation tasks to that behavior.
2. Refactor `body_metrics_screen.dart` to compute screen-level view state and reorganize modules accordingly.
3. Introduce any minimal supporting UI treatments needed for hero empty states, compact summary cards, and richer measurement log rows.
4. Verify behavior across no-data, partial-data, and populated-data states.
5. If the new layout underperforms, roll back at the screen-composition level without touching storage or sync layers.

## Open Questions

- Should the hero module prioritize weight trend only, or should it pivot to a more generic body-composition summary when weight is absent but body fat or waist exists?
- Should the measurement log continue to foreground weight in each row, or should it render a more balanced snapshot of whichever fields were recorded?
- Does the existing add-measurement dialog need to evolve from weight-only input into a more complete body-metrics entry flow as part of this change, or should that remain a follow-up change?
