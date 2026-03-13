## ADDED Requirements

### Requirement: Built-in GZCLP 4-Day Template
The system MUST ship with a built-in GZCLP 4-day template derived from the checked-in workbook `2.0_GZCLP 4-Day 12-Week.xlsx`, using the populated Day 1 to Day 4 exercise lineup, set schemes, warm-up weights, and starting work weights from that file.

#### Scenario: Seed template on empty database
- **WHEN** the app boots with no saved training templates
- **THEN** it creates a default template that includes the populated exercises from the workbook for Day 1 through Day 4 instead of the single-exercise squat demo.

### Requirement: Workbook Exercise Fidelity
The system MUST preserve the workbook's exercise ordering and populated accessory selections for each training day.

#### Scenario: Day 4 workout is loaded
- **WHEN** the app loads the seeded GZCLP Day 4 workout
- **THEN** the workout lists OHP, Bench, DB Seated Press, and Lateral Raises in that order, omitting blank optional accessory slots.

### Requirement: Tier-specific Progression Metadata
The system MUST encode the progression metadata needed to reproduce the workbook's tier behavior for the seeded exercises, including stage changes for T1 lifts and load increases for successful sessions.

#### Scenario: Bench failure advances the T1 stage
- **WHEN** the seeded Day 2 Bench main lift is logged below target reps while on its `3x5+` stage
- **THEN** the next scheduled Bench state remains at the same load and advances to its configured `4x3+` stage.

#### Scenario: Squat success increases the next load
- **WHEN** the seeded Day 1 Squat main lift is logged at or above target reps for all prescribed work sets
- **THEN** the next scheduled Squat state increases the working weight by 5 kg.
