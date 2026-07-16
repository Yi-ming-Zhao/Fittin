## ADDED Requirements

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
