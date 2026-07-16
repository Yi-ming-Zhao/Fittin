# body-screen Specification

## Purpose
TBD - created by archiving change fittin-redesign. Update Purpose after archive.
## Requirements
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

### Requirement: Adaptive Body Composition Rhythm
The Body screen MUST use the safe viewport and available width to present a breathable top-anchored hierarchy. At narrow mobile widths, body-fat and waist summaries MUST share a row while the Check-ins summary uses the full following row; larger widths MAY use three columns.

#### Scenario: Body opens on a narrow phone
- **WHEN** the Body screen renders at a 390 px viewport width
- **THEN** body-fat and waist cards have readable equal-width columns
- **AND** the Check-ins card spans the content width below them
- **AND** history remains reachable without horizontal overflow.

### Requirement: Height-Aware Body Trend
The Body weight trend and section spacing MUST use bounded relaxed dimensions on tall viewports and bounded compact dimensions on short viewports.

#### Scenario: Body opens on tall and short phones
- **WHEN** the same measurement data renders at 390x926 and 390x568
- **THEN** the tall view has balanced section rhythm and a full trend chart
- **AND** the short view uses a shorter readable chart and one natural vertical scroll.
