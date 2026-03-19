## MODIFIED Requirements

### Requirement: Template Editing Surface
The system MUST provide an in-app editing flow for training templates that allows users to update plan metadata, workout metadata, and ordered workout composition without editing raw JSON.

The editor MUST choose its primary navigation model from template metadata:
- templates with `scheduleMode: linear` MUST expose a direct editor for the reusable workout structure
- templates with `scheduleMode: periodized` MUST let the user choose a concrete week/day slot such as `W1D1` before editing that day's workout

#### Scenario: User edits a linear template
- **WHEN** a user opens the editor for a template whose `scheduleMode` is `linear`
- **THEN** the app presents a direct editing surface for the template's reusable workouts without forcing the user to step through every week in the cycle.

#### Scenario: User edits a periodized template
- **WHEN** a user opens the editor for a template whose `scheduleMode` is `periodized`
- **THEN** the app first lets them choose a concrete week/day slot such as `W1D1`
- **AND** editing that slot only changes the selected day's prescription instead of showing the entire multi-month cycle in one long page.

### Requirement: Exercise and Set Customization
The system MUST allow users to create, edit, duplicate, reorder, and delete exercises, stages, and sets within a workout template, including all core runtime fields.

When editing a set, the system MUST expose a structured set type selector instead of a boolean AMRAP toggle.

When editing an exercise, the system MUST allow selecting a load unit from the supported unit system, including `kg`, `lbs`, `bodyweight`, `cable_stack`, and `%1RM`.

#### Scenario: User customizes exercise prescription
- **WHEN** a user edits an exercise
- **THEN** they can modify the exercise name, tier, rest time, starting weight, stage names, set count, target reps, set types, load unit, and warmup vs working set roles before saving.

#### Scenario: User changes a set from straight work to AMRAP
- **WHEN** a user edits a set inside the plan editor
- **THEN** they choose from supported set types such as `straight_set`, `top_set`, `backoff_set`, or `amrap_set`
- **AND** the editor does not represent AMRAP as a simple on/off switch.

#### Scenario: User adds a custom accessory movement
- **WHEN** a user adds a new exercise to a workout
- **THEN** the editor creates a new ordered exercise entry with editable stages, sets, set types, and unit configuration that becomes part of the saved template.

### Requirement: Structured Progression Editing
The system MUST let users edit progression behavior through structured stage and action controls that remain compatible with the rule engine.

The editor MUST only expose rule controls that are valid for the template's engine family and scheduling mode.

#### Scenario: User edits linear progression behavior
- **WHEN** a user edits a `linear_tm` template
- **THEN** they can choose supported progression actions such as success increments, failure behavior, or reset-oriented transitions without entering raw rule JSON.

#### Scenario: User edits a periodized template
- **WHEN** a user edits a `periodized_tm` template
- **THEN** the editor hides linear-only controls such as `on_success` and `on_failure`
- **AND** instead focuses the user on fixed slot prescriptions, set types, and load formulas for that selected week/day slot.

### Requirement: Save Validation
The system MUST prevent saving templates that are structurally incomplete for runtime use.

The editor MUST also prevent saving a template when required engine-aware metadata is missing, such as absent `scheduleMode`, invalid week/day selection for a periodized edit target, or an unsupported set type/unit combination.

#### Scenario: User tries to save an invalid template
- **WHEN** a template has an empty workout, an exercise with no stages, or a stage with no working sets
- **THEN** the editor blocks save and surfaces a validation message identifying the missing required structure.

#### Scenario: User tries to save a periodized day without slot context
- **WHEN** a user is editing a periodized template and the selected `WnDn` slot is missing or invalid
- **THEN** the editor blocks save and identifies the missing scheduling context.
