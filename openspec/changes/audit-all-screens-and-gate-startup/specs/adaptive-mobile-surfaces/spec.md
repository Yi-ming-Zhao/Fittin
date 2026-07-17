## ADDED Requirements

### Requirement: Complete Reachable Surface Coverage
Every reachable screen, subpage, bottom sheet, dialog, and significant loading, empty, error, and populated state MUST remain readable and operable on the supported tall and short phone viewports. Content MUST respect safe areas, keyboard insets, and persistent navigation without horizontal overflow or unreachable primary actions.

#### Scenario: Full mobile surface audit runs
- **WHEN** the production app is reviewed at 390x926 and 390x568 across supported languages and representative dark and light palettes
- **THEN** every inventoried surface and major async state has recorded pass or actionable evidence
- **AND** confirmed clipping, overflow, unsafe touch targets, navigation overlap, or awkward content distribution is corrected before release.

#### Scenario: Sheet or dialog opens on a short phone
- **WHEN** a keyboard, bottom sheet, or dialog reduces the usable viewport
- **THEN** its title, content, and primary actions remain reachable through bounded layout or one natural scroll
- **AND** the overlay does not conflict with system or app navigation insets.
