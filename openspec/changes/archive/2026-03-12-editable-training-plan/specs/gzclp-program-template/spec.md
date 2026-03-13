## MODIFIED Requirements

### Requirement: Built-in GZCLP 4-Day Template
The system MUST ship with a built-in GZCLP 4-day template derived from the checked-in workbook `2.0_GZCLP 4-Day 12-Week.xlsx`, using the populated Day 1 to Day 4 exercise lineup, set schemes, warm-up weights, and starting work weights from that file, and it MUST allow users to use that seeded template as an editable starting point for a saved custom plan.

#### Scenario: Seed template on empty database
- **WHEN** the app boots with no saved training templates
- **THEN** it creates a default template that includes the populated exercises from the workbook for Day 1 through Day 4 instead of the single-exercise squat demo.

#### Scenario: User customizes the built-in template
- **WHEN** a user opens the built-in GZCLP template in the plan editor and saves changes
- **THEN** the app preserves the original seeded source template and saves the edited result as a user-owned template document that can be started separately.
