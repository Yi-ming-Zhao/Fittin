## ADDED Requirements

### Requirement: Compact plan revisions
The Agent SHALL support bounded paginated plan details and partial JSON-pointer edits against an expected plan digest, validate the complete resulting plan, and show actual changed fields before using the existing confirmation and undo transaction.

#### Scenario: Change one exercise without regenerating a plan
- **WHEN** the model reads a plan page and proposes changing reps or rest on a known path
- **THEN** the preview shows old and new values, retains every unrelated field and stable ID, and no data changes before confirmation

#### Scenario: Stale or invalid patch
- **WHEN** the digest no longer matches, a path is missing, or the resulting plan fails validation
- **THEN** the Agent receives an actionable error and no proposal or write occurs

#### Scenario: Active built-in plan revision
- **WHEN** a user confirms a valid partial revision of the active built-in plan
- **THEN** the coordinator creates a safe custom copy, retains compatible progress, leaves the built-in unchanged, and supports conflict-checked undo
