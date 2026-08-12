## ADDED Requirements

### Requirement: Owner-scoped plan mutations
Edited and imported plan templates SHALL be stored for the active account and SHALL remain visible through that account's plan queries.

#### Scenario: Signed-in user imports a plan
- **WHEN** a signed-in user imports or edits a plan template
- **THEN** the saved template is owned by that user and appears in the plan library

### Requirement: Consistent continuation target
Home progress and continue-training navigation SHALL resolve from one authoritative refreshed plan/instance snapshot and SHALL ignore stale asynchronous responses.

#### Scenario: User advances then immediately continues
- **WHEN** a completion advances the active day and the user immediately opens continue training
- **THEN** the session opens the newly active day rather than a stale prior day
