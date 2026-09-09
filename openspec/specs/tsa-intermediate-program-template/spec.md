# tsa-intermediate-program-template Specification

## Purpose
TBD - created by archiving change add-tsa-intermediate-built-in-plan. Update Purpose after archive.
## Requirements
### Requirement: Built-in TSA Intermediate Approach 2.0 Template
The system MUST ship with a built-in TSA Intermediate Approach 2.0 template derived from the checked-in workbook `assets/raw_table_plans/TSA Intermediate Approach 2.0 - LiftVault.com.xlsx`, seeded as app-owned JSON data alongside the existing built-in templates.

#### Scenario: Empty database is initialized
- **WHEN** the app boots with no stored templates or with only some built-in templates present
- **THEN** it seeds the normalized TSA Intermediate Approach 2.0 template without deleting user-authored templates
- **AND** the seeded template is available through the same built-in plan library flow as GZCLP and Jacked & Tan.

### Requirement: Eight-Week Main Block Normalization
The built-in TSA Intermediate template MUST preserve the workbook's main 4-day weekly training structure as an 8-week periodized block and MUST NOT encode the workbook's separate test week as part of the shipped fixed-workout template.

#### Scenario: User previews the seeded TSA template
- **WHEN** the built-in TSA Intermediate template is loaded from storage or shown in the plan library
- **THEN** it exposes 4 workouts labeled Day 1 through Day 4
- **AND** each seeded exercise includes 8 ordered stages representing the normalized main training block.

### Requirement: Training-Max-Driven Main Prescriptions
The built-in TSA Intermediate template MUST resolve its main barbell prescriptions from stored training max values using the existing `periodized_tm` runtime path.

#### Scenario: User activates TSA Intermediate for the first time
- **WHEN** the user creates the first TSA Intermediate instance after entering the required training max values
- **THEN** the app calculates prescribed weighted sets from the instance's squat, bench, and deadlift training maxes plus the template's staged percentage metadata
- **AND** accessory rows that are not tied to a canonical lift remain normalized as fixed template prescriptions.

### Requirement: Seeded Workbook Exercise Lineup
The built-in TSA Intermediate template MUST preserve the normalized workout lineup represented by the shipped JSON asset for the main block.

#### Scenario: User inspects the four seeded workouts
- **WHEN** the user previews the seeded TSA Intermediate template
- **THEN** Day 1 includes `Competition Squat`, `Bench Press`, `Close Grip Bench Press`, `Chest Supported Row`, and `Band Pull-Aparts`
- **AND** Day 2 includes `Deadlift`, `Bench Press`, `Pendlay Row`, `Weighted Back Extension`, and `Pull-ups`
- **AND** Day 3 includes `Competition Squat`, `SELECT`, `Leg Press or Hack Squat`, `Chest-supported Row`, and `Athlete Movement of Choice`
- **AND** Day 4 includes `Bench Press`, `Feet-up Bench Press`, `Paused Deadlift`, `Barbell Row`, and `Neutral/Underhand Lat Pulldown`.
