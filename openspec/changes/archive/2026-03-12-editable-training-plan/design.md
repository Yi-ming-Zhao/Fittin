## Context

The current app can seed, run, and share training templates, but templates are still treated as static definitions once they are written into local storage. The only first-class plan is the built-in GZCLP JSON asset, and there is no in-app flow for changing workout metadata, exercise composition, set schemes, or progression rules.

This change cuts across multiple layers:
- domain models for plan templates and progression rules
- repository/storage behavior for saving user-authored templates
- application state for editing nested template drafts
- presentation for template management and editing screens

There is one major constraint: active training instances must remain stable. If a user edits the template they started from, existing instances cannot silently change shape underneath logged sessions or upcoming workouts.

## Goals / Non-Goals

**Goals:**
- Allow users to create and edit full training templates in-app, including plan metadata, workout order, exercises, stages, sets, AMRAP flags, warmup/working roles, rest timing, starting weights, and progression actions.
- Let the built-in GZCLP template act as an editable starting point without losing the original seed definition.
- Persist edited templates locally and keep them compatible with the existing JSON export/import flow.
- Preserve active instance integrity when templates are customized.

**Non-Goals:**
- Migrating historical workout logs to match newly edited template structures.
- Building a collaborative/cloud-synced plan editor.
- Supporting arbitrary free-form rule expressions beyond the existing rule-action model in this change.

## Decisions

### 1. Treat template editing as draft editing over the existing JSON-first template model

The editor will operate on `PlanTemplate` data and nested immutable copies rather than introducing a second custom schema for authoring. Any field that can be serialized into the template JSON remains the source of truth for runtime and sharing.

Rationale:
- avoids dual representations for "runtime template" and "editor template"
- keeps QR sharing/export compatible with user-authored plans
- reuses existing parsing and persistence pathways

Alternative considered:
- Introduce a separate editor-only draft schema and compile it into `PlanTemplate` on save. Rejected because it adds conversion complexity for every nested field and duplicates validation logic.

### 2. Save edits as template documents, not in-place mutations of active instances

Editing a template will create or overwrite a template document, but active training instances will continue to point at the template snapshot they were created from unless the user explicitly starts a new instance from the edited template. For seeded templates, the first save should create a user-owned copy rather than mutate the built-in source identity.

Rationale:
- prevents workout schedules, exercise IDs, or progression states from shifting under an existing instance
- makes built-in templates safe to use as editable starters
- aligns with the existing template-instance separation in local storage

Alternative considered:
- Mutate the active template in place and update all linked instances. Rejected because it creates migration hazards for current workout indices, missing exercise states, and historical log interpretation.

### 3. Model editor operations around ordered nested collections with stable IDs

Workouts, exercises, stages, and sets will remain explicitly ordered lists. The editor must support add, duplicate, delete, and reorder operations while preserving stable IDs for saved nodes or regenerating IDs only for newly created items.

Rationale:
- exercise order and stage order directly affect training behavior
- stable IDs reduce accidental breakage when resuming instances or comparing templates
- nested ordered editing matches the current plan JSON structure

Alternative considered:
- Flatten editor records and reconstruct hierarchy on save. Rejected because it complicates UI state and makes validation of set/stage nesting less transparent.

### 4. Constrain progression editing to structured actions instead of raw expression authoring

Users will be able to edit stage names, success/failure transitions, weight deltas, multipliers, and stage targets through structured controls over the existing `RuleAction` model. The change will not add a free-text expression language editor.

Rationale:
- exposes the parameters that actually matter to users
- keeps saved templates valid against the current rule engine
- avoids opening an unbounded rule-authoring surface in one change

Alternative considered:
- Let users directly edit `condition` strings and arbitrary action payloads. Rejected because it increases invalid-template risk and would require a much larger validation and debugging surface.

## Risks / Trade-offs

- [Risk] Deeply nested editing flows become hard to manage in one screen -> Mitigation: split editing into plan/workout/exercise/stage sections with dedicated draft state and scoped controls.
- [Risk] Edited templates diverge from seeded GZCLP IDs and break active instances -> Mitigation: save edits as new template documents by default and keep existing instances pinned to their current template ID.
- [Risk] Users can create invalid plans (empty workouts, no working sets, broken stage transitions) -> Mitigation: enforce save-time validation and disable save until required structural rules pass.
- [Risk] Expanding editability to "everything" can balloon scope -> Mitigation: support all core runtime fields, but keep unsupported free-form logic and history migration out of scope.

## Migration Plan

1. Extend template persistence to distinguish built-in templates from user-owned editable copies and support listing/saving multiple templates.
2. Add editor state and validation helpers over the existing `PlanTemplate` hierarchy.
3. Implement template management and editing UI, starting from built-in template duplication and save flows.
4. Route sharing/export through the saved edited template documents and verify active instance creation still works from chosen templates.

Rollback strategy:
- Keep the built-in seed path intact so the app can fall back to seed-only behavior if the editor path is disabled.
- Isolate editor entry points from the existing workout logging flow so editing can be removed without affecting active session execution.

## Open Questions

- Should the first implementation support editing exercise-specific weight units or remain implicitly in kilograms?
- Should deleting a workout/exercise that is referenced by an inactive draft instance be blocked, warned, or always allowed because instances are snapshot-based?
- Does the first editor need a dedicated template library screen, or is a single "Edit current plan / Save as copy" entry point sufficient for MVP?
