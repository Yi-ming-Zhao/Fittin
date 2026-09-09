## ADDED Requirements

### Requirement: Detailed three view anatomy
The load map SHALL provide selectable front, back and side views with original anatomically recognizable regional geometry, theme-derived intensity, readable legends and muscle selection details. It SHALL explicitly describe set exposure rather than medical recovery.

#### Scenario: View side muscle load
- **WHEN** a user selects the side view and taps a mapped region
- **THEN** the same muscle identity and completed-set count used in front/back and analytics is shown.

#### Scenario: No recorded exposure
- **WHEN** there are no relevant completed sets
- **THEN** all three views remain visible with neutral anatomy and a no-data explanation.
