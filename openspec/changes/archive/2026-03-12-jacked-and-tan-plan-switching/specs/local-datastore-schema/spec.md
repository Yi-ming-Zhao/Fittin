## ADDED Requirements

### Requirement: Multiple Built-in Template Seeding
The system MUST persist more than one built-in template and seed the built-in program catalog idempotently.

#### Scenario: Built-in catalog is initialized
- **WHEN** the app bootstraps local storage
- **THEN** it ensures both GZCLP and Jacked & Tan built-in templates exist
- **AND** does not duplicate or overwrite user-owned templates during reseeding.

### Requirement: Active Instance Selection Persistence
The system MUST persist a durable pointer to the currently active training instance separately from template definitions.

#### Scenario: User changes the current plan
- **WHEN** the user switches plans in the plan library
- **THEN** local storage updates the active-instance selection
- **AND** later app launches restore the same active plan context.
