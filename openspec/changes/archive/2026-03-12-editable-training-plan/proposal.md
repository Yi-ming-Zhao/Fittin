## Why

The app can currently run and share plans, but the actual training template is still effectively fixed once seeded. Users need to be able to adapt a plan to their own program instead of being locked to the built-in GZCLP structure or editing JSON by hand.

## What Changes

- Add an in-app training plan editor that lets users customize workout structure and exercise details instead of treating templates as seed-only data.
- Support editing all core template fields that affect training behavior, including workout metadata, exercise selection, set counts, reps, AMRAP flags, warm-up vs working set roles, rest timing, starting weights, and progression/stage definitions.
- Allow users to create, duplicate, rename, and save editable templates without mutating an active training instance unexpectedly.
- Update built-in GZCLP handling so the seeded plan can be used as an editable starting point rather than a read-only special case.

## Capabilities

### New Capabilities
- `plan-template-editor`: Create and edit full training templates, workouts, exercises, sets, and progression settings from the app UI.

### Modified Capabilities
- `gzclp-program-template`: The built-in GZCLP template becomes a customizable source template that users can adapt and save.
- `local-datastore-schema`: Template storage must support user-authored and edited plan definitions in addition to seeded templates and active instances.

## Impact

- Affected code: training plan models, repository/storage layer, plan seeding/bootstrap, application state/providers, and presentation flows for plan management.
- Affected data: template JSON schema, Isar template persistence, and instance/template relationship handling when a template is edited or duplicated.
- Affected UX: dashboard or plan-management entry points, template editing screens/forms, and save/duplicate flows for user-defined plans.
