## Purpose

Define a shared accessible interaction contract for analytical line charts, including explicit axes and touch-tolerant point inspection.

## Requirements

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

### Requirement: Theme-Coherent Chart Color Roles
Interactive charts MUST resolve axes, grid lines, labels, series, selection, points, and detail surfaces from the active palette's chart roles, and MUST preserve series distinction without relying on cyan or teal.

#### Scenario: User changes palette while viewing a chart
- **WHEN** the active palette changes and a chart rebuilds
- **THEN** all chart chrome and data colors update together
- **AND** selected data remains legible and distinguishable from unselected series.
