## 1. Template Metadata and Persistence

- [x] 1.1 Extend the editable template schema/models with `scheduleMode`, structured `setType`, and `loadUnit` fields plus backward-compatible defaults for legacy templates.
- [x] 1.2 Persist and reload the new editor metadata for user-authored templates without mutating active instances.
- [x] 1.3 Update import/export or serialization helpers so the richer template metadata survives save, reload, and sharing flows.

## 2. Engine-Aware Editor Flow

- [x] 2.1 Refactor the plan editor entry flow to branch between `linear` and `periodized` editing modes.
- [x] 2.2 Implement a week/day slot selector for periodized templates that opens a focused editor for a chosen slot such as `W1D1`.
- [x] 2.3 Keep linear templates in a direct reusable-workout editing flow instead of rendering the entire cycle week-by-week.

## 3. Set Type and Unit Editing

- [x] 3.1 Replace the AMRAP boolean control with a structured set-type picker supporting at least `straight_set`, `top_set`, `backoff_set`, `amrap_set`, and `warmup_set`.
- [x] 3.2 Add per-exercise or per-set unit controls for `kg`, `lbs`, `bodyweight`, `cable_stack`, and `%1RM`.
- [x] 3.3 Add validation for incompatible set type, load unit, and engine-family combinations before save.

## 4. Rule Surface Restrictions

- [x] 4.1 Gate visible progression controls by engine family so `linear_tm` templates can edit success/failure/reset behavior.
- [x] 4.2 Remove or hide linear-only controls such as `on_success` and `on_failure` when editing `periodized_tm` templates.
- [x] 4.3 Ensure periodized templates still allow slot-specific prescription editing without exposing unsupported progression actions.

## 5. Guide and Premium UI

- [x] 5.1 Bundle a bilingual markdown set-type guide asset that explains what each supported set category means and when to use it.
- [x] 5.2 Add a profile/settings entry point that opens the guide in the currently selected app language.
- [x] 5.3 Redesign the plan editor UI so the premium/minimal visual system covers the new mode selector, set-type picker, and slot-focused periodized editor.

## 6. Verification

- [x] 6.1 Add model and repository tests covering `scheduleMode`, `setType`, and `loadUnit` persistence.
- [ ] 6.2 Add widget tests for linear editor flow, periodized `WnDn` slot editing, and engine-aware rule visibility.
- [x] 6.3 Add coverage for the bilingual set-type guide entry and rendering behavior.
