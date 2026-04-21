## ADDED Requirements

### Requirement: Project-Owned Backend Runtime
The system MUST provide a project-owned backend runtime for authentication, user-scoped sync, and progress photo file storage without requiring Supabase.

#### Scenario: Backend health check succeeds
- **WHEN** the backend process is running correctly
- **THEN** it responds successfully to a documented health endpoint
- **AND** the Flutter client can use the configured backend base URL as its remote origin

#### Scenario: Operator opens the backend hostname in a browser
- **WHEN** an operator opens the configured public backend base URL without an API path
- **THEN** the backend responds successfully instead of returning a generic routing 404
- **AND** the response identifies the service and references the documented health endpoint

### Requirement: User-Scoped API Enforcement
The backend MUST enforce user ownership for all synchronized entities in application logic.

#### Scenario: Authenticated user fetches records
- **WHEN** an authenticated user requests synchronized plans, instances, workout logs, body metrics, or progress photo metadata
- **THEN** the backend only returns rows owned by that authenticated user
- **AND** it MUST reject attempts to access another user's rows
