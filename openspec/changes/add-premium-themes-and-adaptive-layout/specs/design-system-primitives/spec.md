## MODIFIED Requirements

### Requirement: Shared Screen Primitives
The system MUST provide shared design primitives so screens use consistent cards, typography, controls, data displays, overlays, and interaction states. Those primitives MUST consume semantic theme roles and MUST NOT depend on literal black, white, or per-screen accent values for themeable presentation.

#### Scenario: Screen uses shared primitives
- **WHEN** a surface renders cards, headings, controls, deltas, chips, overlays, or charts
- **THEN** those elements use common primitives instead of bespoke per-screen implementations
- **AND** the primitives update coherently when the selected palette changes.

### Requirement: Reusable Navigation And Chart Primitives
The system MUST include reusable primitives for bottom navigation and lightweight progress visualizations, and their normal, selected, pressed, focused, and disabled states MUST resolve from semantic tokens.

#### Scenario: Screen renders navigation and compact charts
- **WHEN** a screen needs tab navigation, sparklines, step charts, or progress rings
- **THEN** it uses shared primitives with consistent motion, spacing, state feedback, and palette-aware visual language.
