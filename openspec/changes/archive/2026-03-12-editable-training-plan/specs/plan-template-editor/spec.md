## ADDED Requirements

### Requirement: Template Editing Surface
The system MUST provide an in-app editing flow for training templates that allows users to update plan metadata, workout metadata, and ordered workout composition without editing raw JSON.

#### Scenario: User edits plan metadata
- **WHEN** a user opens the plan editor for a template
- **THEN** they can modify the template name, description, workout names, day labels, and estimated duration values and save those changes as a template document.

#### Scenario: User reorders workouts
- **WHEN** a user reorders workouts within a template
- **THEN** the saved template preserves the new workout order and uses that order for future scheduling.

### Requirement: Exercise and Set Customization
The system MUST allow users to create, edit, duplicate, reorder, and delete exercises, stages, and sets within a workout template, including all core runtime fields.

#### Scenario: User customizes exercise prescription
- **WHEN** a user edits an exercise
- **THEN** they can modify the exercise name, tier, rest time, starting weight, stage names, set count, target reps, AMRAP flags, and warmup vs working set roles before saving.

#### Scenario: User adds a custom accessory movement
- **WHEN** a user adds a new exercise to a workout
- **THEN** the editor creates a new ordered exercise entry with editable stages and sets that becomes part of the saved template.

### Requirement: Structured Progression Editing
The system MUST let users edit progression behavior through structured stage and action controls that remain compatible with the rule engine.

#### Scenario: User changes failure progression
- **WHEN** a user edits a stage's failure behavior
- **THEN** they can choose the next stage target and configure supported rule actions such as stay, add weight, or multiply weight without entering raw rule JSON.

### Requirement: Save Validation
The system MUST prevent saving templates that are structurally incomplete for runtime use.

#### Scenario: User tries to save an invalid template
- **WHEN** a template has an empty workout, an exercise with no stages, or a stage with no working sets
- **THEN** the editor blocks save and surfaces a validation message identifying the missing required structure.
