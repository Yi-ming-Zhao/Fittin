# configured-map-relay Specification

## Purpose
Provide authenticated, bounded personal map images without distributing provider credentials or retaining positions.

## Requirements

### Requirement: Configured authenticated map relay
The backend SHALL use an environment-only AMap Web Service Key for authenticated single-point static maps. It MUST reject unknown request fields, invalid coordinates, oversized bodies, redirects and non-image responses; fixed provider destinations, timeout, response size, per-user/global rate and concurrency limits SHALL apply. Keys, positions and upstream errors MUST NOT be logged or persisted; responses SHALL be no-store.

#### Scenario: Anonymous request
- **WHEN** an unauthenticated client requests a map
- **THEN** the backend returns 401 without contacting AMap

#### Scenario: Valid request
- **WHEN** a signed-in user requests a valid point within quota
- **THEN** GPS coordinates are converted and a bounded static image is returned without exposing the Key

#### Scenario: Provider failure
- **WHEN** the provider returns a redirect, quota error, timeout or oversized result
- **THEN** the backend returns a constant safe error without Key or coordinate contents

#### Scenario: Abuse limits
- **WHEN** user/global rate or concurrent capacity is exhausted
- **THEN** no further provider request is issued and the client receives 429
