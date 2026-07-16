## ADDED Requirements

### Requirement: Theme-Coherent Chart Color Roles
Interactive charts MUST resolve axes, grid lines, labels, series, selection, points, and detail surfaces from the active palette's chart roles, and MUST preserve series distinction without relying on cyan or teal.

#### Scenario: User changes palette while viewing a chart
- **WHEN** the active palette changes and a chart rebuilds
- **THEN** all chart chrome and data colors update together
- **AND** selected data remains legible and distinguishable from unselected series.
