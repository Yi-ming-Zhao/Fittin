## MODIFIED Requirements

### Requirement: Theme Token System
The system MUST resolve Fittin frontend visuals from a structured dark theme token set matching the Claude/Fittin prototype.

#### Scenario: Default design direction renders
- **WHEN** the app resolves the default Fittin theme
- **THEN** it uses the prototype Editorial Mono direction with warm black surfaces, bone foreground/accent, Fraunces display/numeric text, Inter UI text, step charts, comfortable density, and glass cards.
- **AND** redesigned screens do not introduce unrelated saturated accent colors.

### Requirement: Curated Visual Directions
The system MUST preserve curated visual directions while keeping the same component contracts.

#### Scenario: Alternate direction renders
- **WHEN** another Fittin visual direction is selected
- **THEN** the same primitives and screens remain usable with the alternate tokens.
