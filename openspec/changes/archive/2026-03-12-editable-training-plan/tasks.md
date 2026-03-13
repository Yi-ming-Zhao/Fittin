## 1. Template Persistence and Model Support

- [x] 1.1 Extend template/domain and storage models to support editable user-owned templates, built-in template metadata, and safe save-as-copy behavior.
- [x] 1.2 Add repository APIs for listing templates, loading a template draft, saving a new template, and updating an existing user-owned template without mutating active instances.
- [x] 1.3 Add validation/helpers for nested template editing, including required workout/exercise/stage/set structure and supported progression action shapes.

## 2. Editor State and Application Flows

- [x] 2.1 Implement editor state management for plan metadata, ordered workouts, exercises, stages, sets, and progression actions using immutable nested draft updates.
- [x] 2.2 Add create/duplicate/delete/reorder operations for workouts, exercises, stages, and sets, with stable IDs for saved nodes and generated IDs for new nodes.
- [x] 2.3 Implement save flows for built-in templates and user-owned templates so editing GZCLP produces a separate saved template copy by default.

## 3. Plan Editing UI

- [x] 3.1 Add a plan management entry point and template list flow where users can browse built-in and saved templates and choose one to edit.
- [x] 3.2 Build the plan editor UI for top-level template and workout metadata editing, including rename and duration/day-label controls.
- [x] 3.3 Build exercise, stage, and set editing controls that expose movement name, tier, rest time, starting weight, reps, set roles, and AMRAP toggles.
- [x] 3.4 Add structured progression editing controls for success/failure actions and save-time validation messaging.

## 4. Verification

- [x] 4.1 Add unit tests for template validation, draft save behavior, and repository rules around seeded-template copy-on-edit and active instance safety.
- [x] 4.2 Add widget/provider tests for creating or editing a template, customizing exercises/sets, and blocking invalid saves.
- [x] 4.3 Run the relevant automated tests and verify that edited templates still serialize and remain shareable through the existing JSON/QR export path.
