## ADDED Requirements

### Requirement: Built-in Jacked & Tan 2.0 Template
The system MUST ship with a built-in Jacked & Tan 2.0 template derived from the checked-in workbook `/Users/yzxbb/Desktop/Fittin_v2/jacked_and_tan.xlsx`, seeded alongside the existing GZCLP template as app-owned JSON data.

#### Scenario: Empty database is initialized
- **WHEN** the app boots with no stored templates or with only one built-in template present
- **THEN** it seeds the normalized Jacked & Tan 2.0 template in addition to GZCLP without deleting user-authored templates.

### Requirement: T1 Movement Fidelity
The system MUST preserve the workbook T1 movement lineup exactly when building the Jacked & Tan template.

#### Scenario: User inspects the seeded Jacked & Tan workouts
- **WHEN** the built-in Jacked & Tan template is loaded from the plan library
- **THEN** its T1 movements are `Competition Squat` on Day 1, `Bench Press` on Day 2, `Auxiliary Squat` on Day 3, and both `Standing Barbell Press` plus `Slingshot Bench` on Day 4.

### Requirement: Rebalanced T2/T3 Exercise Selection
The system MUST reduce every Jacked & Tan workout to exactly 2 T2 movements and exactly 2 T3 movements while favoring movements already used in the app’s GZCLP workflow when they satisfy the strength-plus-physique goal.

#### Scenario: Day 1 and Day 2 are previewed
- **WHEN** the user previews the seeded Jacked & Tan template
- **THEN** Day 1 lists `Block Pull` and `Leg Press` as T2 movements plus `Barbell Row` and `Leg Curl` as T3 movements
- **AND** Day 2 lists `Close-Grip Bench Press` and `Incline DB Bench` as T2 movements plus `DB Seated Press` and `Lateral Raises` as T3 movements.

#### Scenario: Day 3 and Day 4 are previewed
- **WHEN** the user previews the seeded Jacked & Tan template
- **THEN** Day 3 lists `Romanian Deadlift` and `Close-Grip Lat Pulldown` as T2 movements plus `Chest-Supported Row` and `Walking Lunge` as T3 movements
- **AND** Day 4 lists `Legless Bench Press` and `Push Press` as T2 movements plus `Wide-Grip Lat Pulldown` and `Face Pull` as T3 movements.

### Requirement: Weekly Muscle Group Volume Budget
The seeded Jacked & Tan template MUST keep each major target area inside a 12 to 20 direct-work-set weekly budget after the T2/T3 reduction is applied.

#### Scenario: Weekly volume is validated
- **WHEN** the seeded Jacked & Tan template is evaluated using its normalized set counts
- **THEN** chest, back, quads, posterior chain, and shoulders each total at least 12 direct work sets and no more than 20 direct work sets per week.
