## ADDED Requirements

### Requirement: Theme Token System
The system MUST provide a structured theme system with tokens for surfaces, foregrounds, accents, typography, charts, and layout density.

#### Scenario: Screen resolves theme values
- **WHEN** a screen or primitive requests theme values
- **THEN** it receives a complete token set covering color, typography, chart styling, and spacing decisions needed for rendering.

### Requirement: Curated Visual Directions
The theme system MUST support multiple curated visual directions with predictable overrides.

#### Scenario: App applies a different visual direction
- **WHEN** the app resolves a theme from a different base direction or tweak set
- **THEN** the resulting theme changes the app's visual character while keeping the same token API and component contracts.
