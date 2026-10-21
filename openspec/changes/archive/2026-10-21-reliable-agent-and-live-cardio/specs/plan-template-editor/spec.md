## ADDED Requirements

### Requirement: Progressive editor hierarchy
The editor SHALL expose plan overview, selected day and selected exercise as separate navigable levels sharing one persistent draft. Advanced progression fields SHALL be collapsed by default, errors SHALL identify and navigate to their owning entity, and periodized editing SHALL retain selected week/day scope.

#### Scenario: Edit and navigate back
- **WHEN** the user edits a set, returns to day overview, and reopens the exercise
- **THEN** the unsaved change remains and other days are not expanded into the same form
