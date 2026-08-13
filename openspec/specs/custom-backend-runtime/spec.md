# custom-backend-runtime Specification

## Purpose
TBD - created by archiving change replace-supabase-with-custom-backend. Update Purpose after archive.
## Requirements
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

### Requirement: Dependency-Aware Readiness
The backend MUST expose liveness separately from readiness and readiness MUST fail when required database connectivity is unavailable.

#### Scenario: Process runs without database
- **WHEN** the HTTP process is live but PostgreSQL cannot be pinged
- **THEN** liveness remains available and readiness returns an unavailable status.

### Requirement: Hardened Request Boundary
The backend MUST enforce authenticated ownership, body limits, validation, configurable CORS, and bounded abuse controls at exposed write and authentication endpoints.

#### Scenario: Oversized unauthenticated request burst
- **WHEN** a caller exceeds configured body or request-rate limits
- **THEN** the server rejects requests without performing protected storage mutations.

### Requirement: Agent relay runtime controls
The custom backend SHALL register the authenticated Agent relay behind existing CORS and rate middleware and SHALL expose dedicated configurable upstream timeout, byte, concurrency, and per-minute limits.

#### Scenario: Backend readiness is independent of provider
- **WHEN** a configured model provider is unavailable
- **THEN** `/readyz` continues to report only Fittin database readiness and Agent requests return a bounded provider-unavailable error
