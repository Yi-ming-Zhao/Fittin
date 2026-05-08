## MODIFIED Requirements

### Requirement: User-Scoped API Enforcement
The backend MUST enforce user ownership for all synchronized entities in application logic. The backend MUST reject cross-user sync writes with an explicit ownership-conflict response instead of exposing a database driver no-rows error.

#### Scenario: Authenticated user fetches records
- **WHEN** an authenticated user requests synchronized plans, instances, workout logs, body metrics, or progress photo metadata
- **THEN** the backend only returns rows owned by that authenticated user
- **AND** it MUST reject attempts to access another user's rows

#### Scenario: Authenticated user upserts another user's record ID
- **WHEN** an authenticated user submits a sync upsert whose record ID already exists under a different user
- **THEN** the backend rejects the write with a conflict response
- **AND** the error message identifies the ownership conflict rather than returning `no rows in result set`.
