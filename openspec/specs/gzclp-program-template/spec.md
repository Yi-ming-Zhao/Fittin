## ADDED Requirements

### Requirement: Training-Max-Driven GZCLP Activation
The built-in GZCLP template MUST derive initial working prescriptions from user-entered training max values rather than from fixed seeded working weights.

#### Scenario: User starts GZCLP from scratch
- **WHEN** the user creates the first GZCLP instance after entering the required training max values
- **THEN** the app calculates the initial T1 and T2 prescriptions from those training max values and the template's starter percentage and increment metadata.

## MODIFIED Requirements

### Requirement: Built-in GZCLP 4-Day Template
The system MUST ship with a built-in GZCLP 4-day template derived from the checked-in workbook `2.0_GZCLP 4-Day 12-Week.xlsx`, using the populated Day 1 to Day 4 exercise lineup and tier structure from that file, and it MUST treat those workouts as a training-max-driven linear plan rather than a fixed-weight seed.

#### Scenario: Seed template on empty database
- **WHEN** the app boots with no saved training templates
- **THEN** it creates a default GZCLP template that includes the populated exercises from the workbook for Day 1 through Day 4 instead of the single-exercise squat demo
- **AND** the seeded template stores engine metadata needed to derive runtime loads from user-entered training max values.

#### Scenario: User customizes the built-in template
- **WHEN** a user opens the built-in GZCLP template in the plan editor and saves changes
- **THEN** the app preserves the original seeded source template and saves the edited result as a user-owned template document that can be started separately.

### Requirement: Tier-specific Progression Metadata
The system MUST encode the progression metadata needed to reproduce GZCLP's linear tier behavior, including training-max-derived starting prescriptions, tier-specific increments, stage changes for T1 lifts, and reset behavior after repeated failure.

#### Scenario: Bench failure advances the T1 stage
- **WHEN** the seeded Day 2 Bench main lift is logged below target reps while on its entry T1 stage
- **THEN** the next scheduled Bench state keeps the same underlying load state or applies the configured fallback and advances to its configured next T1 stage instead of inventing a periodized week change.

#### Scenario: Squat success increases the next load
- **WHEN** the seeded Day 1 Squat main lift is logged at or above target reps for all prescribed work sets
- **THEN** the next scheduled Squat state increases the working prescription by the configured lower-body increment for the next encounter of that lift.
