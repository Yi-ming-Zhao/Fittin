## ADDED Requirements

### Requirement: Dependency-aware readiness
The backend SHALL expose liveness separately from readiness and readiness SHALL fail when required database connectivity is unavailable.

#### Scenario: Process runs without database
- **WHEN** the HTTP process is live but PostgreSQL cannot be pinged
- **THEN** liveness remains available and readiness returns an unavailable status

### Requirement: Hardened request boundary
The backend SHALL enforce authenticated ownership, body limits, validation, configurable CORS, and bounded abuse controls at exposed write/auth endpoints.

#### Scenario: Oversized unauthenticated request burst
- **WHEN** a caller exceeds configured body or request-rate limits
- **THEN** the server rejects requests without performing protected storage mutations
