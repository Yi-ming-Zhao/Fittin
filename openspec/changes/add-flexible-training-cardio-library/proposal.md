## Why

Fittin currently treats a plan day as a fixed next step and strength training as the only first-class workout, which makes real-world schedule changes, in-session exercise substitutions, and cardio tracking unnecessarily fragile. The profile information architecture, session persistence, and uneven vertical rhythm also make routine mobile use feel less dependable than the underlying training engine.

## What Changes

- Let users reorder the remaining days inside the current microcycle without changing the plan template, so a later day can be trained today and displaced days remain pending in a deterministic order.
- Let users replace an exercise after a session starts by choosing from a tagged exercise library, while preserving completed work and clearly resetting only incompatible pending set inputs.
- Promote the exercise library to a local, user-editable catalog with normalized tags and expose safe read/write tools to the in-app Agent through the existing proposal, confirmation, conflict, and undo workflow.
- Replace the home “switch plan” shortcut with “record cardio”; add a typed cardio activity library and cardio records whose fields depend on activity type.
- Add import adapters for common running-app exports, beginning with standard GPX, TCX and FIT files plus a generic CSV mapping path suitable for apps such as rqrun; imports are previewed, deduplicated, and confirmed before persistence.
- Split training trends into strength and cardio series with theme-derived, non-cyan semantic colors and accessible non-color markers.
- Persist authenticated sessions across normal app restarts and transient refresh failures; only explicit sign-out or a confirmed unrecoverable credential rejection clears the session.
- Reorganize “My” into coherent second-level pages for account, appearance, training preferences, data and privacy, Agent, and app information.
- Expand the appearance system with additional restrained, high-quality built-in palettes plus a user-editable theme palette library; let the Agent inspect palettes and propose validated custom palette additions or revisions through confirmation and undo.
- Audit all reachable screens and deep subpages, standardizing safe-area use, page gutters, vertical rhythm, section spacing, scroll behavior, and 44 px minimum touch targets across supported phone sizes.
- Publish the completed and verified change as `v1.3.0+26`, including signed Android artifacts, Web deployment, release metadata, and in-place upgrade verification.

## Capabilities

### New Capabilities
- `flexible-microcycle-scheduling`: Reorder pending training days within the active microcycle while preserving progress and deterministic advancement.
- `in-session-exercise-substitution`: Replace pending session exercises from a tagged library without corrupting completed set records.
- `cardio-activity-tracking`: Define typed cardio activities and validate type-specific cardio records.
- `cardio-data-import`: Preview, map, deduplicate, and confirm GPX, TCX, FIT, and generic CSV cardio imports.
- `profile-information-architecture`: Group related profile commands into stable second-level destinations.
- `editable-theme-palette-library`: Store, preview, validate, create, revise, and delete user-defined semantic color palettes.

### Modified Capabilities
- `exercise-library`: Add normalized tags, user-defined entries, editing, filtering, and safe Agent access.
- `agent-data-mutations`: Add versioned exercise-library and theme-palette read tools plus confirmed mutation tools.
- `home-dashboard-command-surface`: Replace the plan-switch shortcut with cardio recording and expose microcycle day selection.
- `multi-exercise-session`: Support safe exercise substitution during an active workout.
- `progress-analytics`: Distinguish strength and cardio workloads with theme-aware visual encoding.
- `user-account-authentication`: Preserve a valid login until explicit sign-out or confirmed credential invalidation.
- `local-datastore-schema`: Persist cardio definitions, cardio records, exercise catalog entries, and import fingerprints additively.
- `user-cloud-sync`: Sync the new user-owned exercise and cardio entities without weakening owner isolation.
- `adaptive-mobile-surfaces`: Apply consistent safe areas, gutters, density, and vertical rhythm to every reachable screen.
- `multi-theme-system`: Add more curated palettes and resolve user-defined semantic palettes without hard-coded screen colors.
- `release-integrity`: Gate and publish the signed Android/Web `v1.3.0+26` release only after migrations, regressions, and public-boundary checks pass.

## Impact

This change affects the training-domain models and active-instance ordering, workout-session state, exercise catalog, theme catalog, analytics providers, authentication bootstrap, local Isar and IndexedDB schemas, cloud serialization/sync, Agent tool contracts, navigation, localization, and most presentation screens. It introduces file parsing for standard fitness exports but does not require server-side credential sharing, background account scraping, or direct integration with proprietary third-party APIs.
