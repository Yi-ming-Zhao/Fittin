## ADDED Requirements

### Requirement: Body Composition Overview
The system MUST provide a body screen that summarizes body weight and key body-composition metrics in a single scan-friendly view.

#### Scenario: User views the body screen
- **WHEN** the user opens the body screen
- **THEN** the screen shows a primary body-weight card with the current value, unit selector, delta, and trend visualization
- **AND** it shows supporting body-composition metrics such as body fat and measurements alongside recent change values.

### Requirement: Body Check-In Logging Surface
The system MUST provide a clear entry point for logging a new body check-in and reviewing recent measurements.

#### Scenario: User reviews and logs body metrics
- **WHEN** the user is on the body screen
- **THEN** the screen presents a call to action for adding a new check-in
- **AND** it shows a recent measurement log with date-ordered historical entries.
