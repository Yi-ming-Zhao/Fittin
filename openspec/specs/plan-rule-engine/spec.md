## Purpose

Define how the training rule engine parses templates, resolves prescriptions, and advances engine-specific progression across supported program families.

## Requirements

### Requirement: Engine-Aware Prescription Resolution
The system MUST resolve workout prescriptions through an engine-family-specific evaluator instead of one shared progression path.

#### Scenario: Built-in plan template is loaded
- **WHEN** the app loads a plan template whose engine family is `linear_tm` or `periodized_tm`
- **THEN** it routes prescription resolution and post-workout state updates through the evaluator registered for that engine family.

### Requirement: Training-Max-Based Set Weight Calculation
The system MUST calculate scheduled set weights from training max values and template metadata at runtime.

#### Scenario: Session is created from a TM-driven template
- **WHEN** the app builds an active workout session for a training-max-driven instance
- **THEN** every prescribed weighted set resolves its target load from the instance training-max profile, the exercise's lift mapping, the template's load formula, and the current engine state.

### Requirement: Periodized Schedule Advancement
The system MUST support fixed weekly/block progression where completing a workout advances a schedule cursor without rewriting future weekly prescriptions.

#### Scenario: Jacked & Tan week advances
- **WHEN** the user completes a Jacked & Tan workout
- **THEN** the engine advances the instance to the next scheduled workout/week slot
- **AND** the next session's prescribed weights remain the ones defined for that slot by the template's periodized metadata.

### Requirement: JSON Schema Parsing
The system MUST parse training plan templates from a predefined JSON schema into internal Dart objects, preserving the hierarchy of phases, workouts, exercises, and sets, while also parsing engine-family metadata, training-max lift mappings, and engine-specific prescription payloads required for runtime evaluation.

#### Scenario: Valid JSON parsing
- **WHEN** a valid JSON template string is provided
- **THEN** the engine parses it into a strongly-typed `PlanTemplate` object without errors
- **AND** the resulting object preserves the declared engine family and any engine-specific prescription metadata required to calculate future workouts.

### Requirement: Progression Outcome Evaluation
The system MUST evaluate the log of a completed exercise session against the rules defined in the active program engine so it can determine the next instance state for that exercise or schedule slot.

#### Scenario: Successful linear completion leads to progression
- **WHEN** the user meets or exceeds the target reps for all required sets in a `linear_tm` exercise and the engine metadata dictates adding load on success
- **THEN** the engine returns a new state with the configured increment applied and the appropriate next scheme or same scheme retained for the next encounter of that exercise.

#### Scenario: Linear failure leads to regression or reset
- **WHEN** the user fails to meet the target reps for a `linear_tm` exercise and the engine metadata dictates changing scheme or resetting load
- **THEN** the engine returns a new state that applies the configured fallback behavior, such as moving from `5x3` to `6x2`, moving from `6x2` to `10x1`, or resetting the working load according to the template's reset policy.

### Requirement: Engine-Aware Editor Rule Surface
The system MUST expose rule-editing controls according to the selected template's engine family and scheduling mode instead of showing one universal rule form.

#### Scenario: User edits a linear template
- **WHEN** a user opens the editor for a `linear_tm` template
- **THEN** the available rule fields include linear progression concepts such as success behavior, failure behavior, and reset-oriented actions.

#### Scenario: User edits a periodized template
- **WHEN** a user opens the editor for a `periodized_tm` template
- **THEN** the available rule fields exclude linear-only controls such as `on_success` and `on_failure`
- **AND** the editor only exposes rule inputs that make sense for fixed-slot periodized prescriptions.

### Requirement: Set Type Compatibility Enforcement
The system MUST reject or normalize unsupported combinations of set type, engine family, and load-expression metadata before a template can be saved.

#### Scenario: Unsupported set behavior is chosen
- **WHEN** a user selects a set type or rule combination that the target engine family cannot execute
- **THEN** the editor prevents save and surfaces a validation message describing the incompatible combination.

### Requirement: Canonical Exercise Resolution In Plans
The plan parser and runtime MUST resolve every exercise to a canonical or stable custom exercise identity before prescriptions, training-max mappings, analytics, or localization are applied.

#### Scenario: Built-in bilingual plan is started
- **WHEN** plan content names a known exercise through an English name, Chinese name, or alias
- **THEN** the instance stores the same canonical exercise ID and displays its name in the active locale.

### Requirement: Missing Starting Load Estimation
When a plan intentionally omits a starting load, instance creation MUST calculate a conservative suggested load from the exercise performance profile or canonical Big Three anchor metadata, target reps, equipment increment, and confidence adjustment.

#### Scenario: Starting a plan with an assistance movement
- **WHEN** an assistance movement has no explicit plan load and the user has a valid anchor-lift profile
- **THEN** the engine creates a reviewable estimate with value, unit, formula, anchor, ratio, confidence, and library version
- **AND** user confirmation or editing does not change the underlying recommendation metadata.

#### Scenario: Plan already specifies a load
- **WHEN** an exercise has an explicit plan or user-authored starting load
- **THEN** the engine preserves that load and does not replace it with an automatic estimate.
