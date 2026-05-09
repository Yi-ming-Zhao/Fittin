## MODIFIED Requirements

### Requirement: Shared Screen Primitives
The system MUST provide prototype-matched shared primitives for cards, typography, controls, buttons, dividers, charts, and tab navigation.

#### Scenario: Redesigned surface renders repeated UI
- **WHEN** a redesigned surface renders cards, headings, controls, deltas, chips, buttons, dividers, charts, or tab navigation
- **THEN** those elements use shared primitives whose spacing, radius, glass treatment, typography, and active states match the prototype.

### Requirement: Reusable Navigation And Chart Primitives
The system MUST render bottom navigation and progress charts in the prototype style.

#### Scenario: Navigation and compact charts render
- **WHEN** the app renders bottom navigation or chart primitives
- **THEN** navigation appears as a 5-tab glass pill with a single accent-filled active state
- **AND** charts default to subtle stepped lines with restrained grid/dot treatment.
