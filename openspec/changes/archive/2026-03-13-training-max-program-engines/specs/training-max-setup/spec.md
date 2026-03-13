## ADDED Requirements

### Requirement: Program-Specific Training Max Setup
The system MUST require a training-max setup step before creating the first instance of a training-max-driven built-in plan.

#### Scenario: User activates a built-in plan without an instance
- **WHEN** the user selects GZCLP or Jacked & Tan from the plan library and no existing instance is available for that template
- **THEN** the app prompts for the training max values required by that program before creating and activating the instance.

### Requirement: Canonical Lift Mapping
The system MUST store training max values by canonical lift keys and use template-defined mappings to derive exercise prescriptions from those values.

#### Scenario: User enters primary lift training maxes
- **WHEN** the user saves training max values for squat, bench, deadlift, and overhead press
- **THEN** the app stores those values as the instance's training-max profile
- **AND** exercises such as close-grip bench, slingshot bench, auxiliary squat, push press, and deadlift variations resolve their prescribed weights from the mapped primary lift key defined by the template.

### Requirement: Derived Weight Calculation
The system MUST calculate prescribed working weights from training max plus template metadata instead of requiring users to enter fixed per-exercise working weights.

#### Scenario: Session weights are resolved after setup
- **WHEN** the user finishes training-max setup and opens the first scheduled workout
- **THEN** the session shows prescribed set weights that were calculated from the stored training max values, the template's percentage/increment metadata, and the program engine state.
