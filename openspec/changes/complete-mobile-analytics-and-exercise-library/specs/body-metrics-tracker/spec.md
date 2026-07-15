## ADDED Requirements

### Requirement: Interactive Weight Trend Axes
The body-weight trend MUST implement the shared interactive chart contract with explicit localized date and weight axes, active kg/lb units, touch-tolerant point selection, and exact measurement details.

#### Scenario: User inspects a historical body weight
- **WHEN** the user taps a point on the body-weight line
- **THEN** the chart highlights that measurement and shows its full date, exact weight, unit, and change from the previous comparable measurement when available.
