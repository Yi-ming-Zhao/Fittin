## ADDED Requirements

### Requirement: Authoritative remote hydration
Local persistence SHALL provide an explicit remote-merge path that preserves server version, ownership, timestamps, and sync status rather than incrementing versions as if it were a local edit.

#### Scenario: Remote version is applied
- **WHEN** synchronization hydrates a row at server version 7
- **THEN** the local row remains version 7 and does not become a new outgoing version 8 mutation
