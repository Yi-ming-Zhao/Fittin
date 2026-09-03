# design-system-primitives Specification

## Purpose
TBD - created by archiving change fittin-redesign. Update Purpose after archive.
## Requirements
### Requirement: Shared Screen Primitives
The system MUST provide shared design primitives so screens use consistent cards, typography, controls, data displays, overlays, and interaction states. Those primitives MUST consume semantic theme roles and MUST NOT depend on literal black, white, or per-screen accent values for themeable presentation. Interactive selectors MUST expose their role, selected state and mutually exclusive relationship to assistive technology, while preserving a minimum 44 by 44 logical-pixel hit target.

#### Scenario: Screen uses shared primitives
- **WHEN** a surface renders cards, headings, controls, deltas, chips, overlays, or charts
- **THEN** those elements use common primitives instead of bespoke per-screen implementations
- **AND** the primitives update coherently when the selected palette changes.

#### Scenario: User navigates a selector with assistive technology
- **WHEN** a segmented item, locale option, record-mode option or compact chip receives accessibility focus
- **THEN** it announces a unique label and whether it is selected
- **AND** its interactive target remains at least 44 logical pixels in both dimensions.

### Requirement: Reusable Navigation And Chart Primitives
The system MUST include reusable primitives for bottom navigation and lightweight progress visualizations, and their normal, selected, pressed, focused, and disabled states MUST resolve from semantic tokens.

#### Scenario: Screen renders navigation and compact charts
- **WHEN** a screen needs tab navigation, sparklines, step charts, or progress rings
- **THEN** it uses shared primitives with consistent motion, spacing, state feedback, and palette-aware visual language.
