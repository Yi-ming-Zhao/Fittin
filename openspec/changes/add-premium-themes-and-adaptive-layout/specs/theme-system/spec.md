## MODIFIED Requirements

### Requirement: Theme Token System
The system MUST provide one complete semantic theme token set for canvas and surfaces, content, structure, brand interaction, states, workout feedback, charts, anatomy rendering, typography, and layout density. Material `ThemeData` and custom Fittin components MUST resolve from the same selected palette and MUST NOT use a parallel theme state.

#### Scenario: Screen resolves theme values
- **WHEN** a screen, Material control, painter, or shared primitive requests theme values
- **THEN** it receives roles from the same selected palette for every color-bearing element needed for rendering
- **AND** equivalent Material and Fittin roles resolve to visually coherent values.

### Requirement: Curated Visual Directions
The theme system MUST support complete curated visual directions through stable palette identifiers. Every direction MUST provide all semantic roles, MUST preserve component contracts, and MUST exclude cyan and teal hues from user-facing palette tokens.

#### Scenario: App applies a different visual direction
- **WHEN** the user selects another curated palette
- **THEN** the entire app changes visual character without mixing unresolved values from the previous palette
- **AND** content hierarchy, status meaning, and interaction affordances remain intact.

## ADDED Requirements

### Requirement: Explicit Domain Color Palettes
The system MUST centralize colors whose meaning is fixed by the represented domain, including standardized Olympic plate identification and exported share artwork, separately from user-selectable appearance tokens.

#### Scenario: Theme changes while a barbell is visible
- **WHEN** the user changes the app palette
- **THEN** surrounding surfaces, labels, and lines update
- **AND** standardized equipment identification colors remain recognizable through the named equipment palette.
