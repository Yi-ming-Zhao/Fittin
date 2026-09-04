## ADDED Requirements

### Requirement: Tagged exercise catalog
The exercise library SHALL expose normalized movement, primary muscle, secondary muscle, equipment, load semantics, and user tags for every selectable exercise and SHALL support localized search and multi-tag filtering.

#### Scenario: Filter back dumbbell movements
- **WHEN** the user filters by back and dumbbell
- **THEN** the catalog shows matching exercises with their primary muscle and equipment tags without duplicating aliases

### Requirement: User exercise definitions
The system SHALL let users create, revise, duplicate, and soft-delete owner-scoped custom exercises using the supported tags and load semantics while built-in definitions remain immutable.

#### Scenario: User customizes a built-in exercise
- **WHEN** the user edits a built-in definition
- **THEN** the system saves a custom copy with a stable custom ID and retains the built-in entry

#### Scenario: Custom exercise is referenced by history
- **WHEN** a custom exercise used by a workout log is deleted
- **THEN** existing history keeps its recorded name and ID while the exercise disappears from future selection
