## ADDED Requirements

### Requirement: Explicit Chart Axes
Every line chart MUST render a readable x-axis and y-axis with localized labels or tick values, units, and sufficient contrast for the current theme.

#### Scenario: User opens a weight trend
- **WHEN** a chart plots dated weight values
- **THEN** the x-axis communicates dates and the y-axis communicates weight with the active unit without requiring the user to infer either scale.

### Requirement: Selectable Data Points
Every plotted line point MUST be selectable by tap or pointer using a touch-tolerant hit target, and selection MUST reveal the series name, full date, exact value, unit, and any relevant context.

#### Scenario: User taps near a chart point
- **WHEN** the tap falls within the point's touch tolerance
- **THEN** the nearest point becomes visibly selected and a localized detail surface shows its exact date and value.

### Requirement: Accessible Chart Semantics
Charts MUST expose a non-visual summary and selected-point semantics, and selection MUST remain stable across harmless repaints until the data, series, or range changes.

#### Scenario: Screen reader focuses an interactive chart
- **WHEN** assistive technology traverses the chart
- **THEN** it can identify the chart purpose, current range, series, and selected point without relying on color alone.
