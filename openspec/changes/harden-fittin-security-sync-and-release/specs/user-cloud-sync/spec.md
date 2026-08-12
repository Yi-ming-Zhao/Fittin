## ADDED Requirements

### Requirement: Conflict-preserving compare-and-set sync
Cloud mutations SHALL be accepted only when they create a row, advance its version, or repeat an identical same-device version; competing equal or stale versions SHALL produce a structured conflict and SHALL remain queued locally.

#### Scenario: Two devices edit the same version
- **WHEN** two devices independently submit different values derived from the same remote version
- **THEN** one mutation succeeds and the other is retained as a user-resolvable conflict without data loss

### Requirement: Bounded resilient transport
Sync requests SHALL have finite timeouts, parse non-JSON failures safely, and pull data in bounded pages or incremental windows without deleting data omitted from a partial response.

#### Scenario: Proxy returns an HTML error
- **WHEN** a sync endpoint returns a non-JSON error or times out
- **THEN** the client reports a retryable sync error and preserves pending mutations
