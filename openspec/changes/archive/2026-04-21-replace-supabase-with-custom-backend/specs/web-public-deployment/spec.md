## MODIFIED Requirements

### Requirement: Public Web Release Build
The system MUST provide a repeatable release build flow for the Flutter Web client that is suitable for public serving at `https://fittin.yimelo.cc/`.

#### Scenario: Build a public web release
- **WHEN** a maintainer prepares a new public web deployment
- **THEN** the documented build flow produces a Flutter Web release build from the repository
- **AND** the build flow uses explicit `BACKEND_URL` (and optional `BACKEND_API_KEY`) `dart-define` values instead of Supabase runtime configuration.

## ADDED Requirements

### Requirement: Public Backend Endpoint Availability
The system MUST document and support a stable public backend endpoint that can be reached through a dedicated tunnel-backed hostname during web deployment and validation.

#### Scenario: Validate public backend reachability
- **WHEN** a maintainer completes backend tunnel and DNS configuration for the public environment
- **THEN** the configured public backend hostname reaches the local backend origin instead of an unrelated service
- **AND** a public request to `/healthz` succeeds through the tunnel
