## ADDED Requirements

### Requirement: Canonical Exercise Reference Persistence
Persisted plans, active sessions, workout logs, analytics records, and synced payloads MUST support a stable canonical or custom exercise ID while retaining legacy display names needed for migration and audit.

#### Scenario: Existing installation upgrades
- **WHEN** legacy records contain only exercise-name strings
- **THEN** migration resolves known aliases deterministically, assigns stable custom IDs to unresolved names, and preserves every original record and recorded load.

### Requirement: Exercise Performance Profile Restoration
The local and web datastores MUST persist the authoritative completed logs, canonical exercise references, source record IDs, confirmed starting-load provenance, catalog version, and milestone exercise preferences needed to deterministically rebuild per-exercise RM/1RM profiles after reload. A profile cache MAY be persisted, but it MUST remain rebuildable and MUST NOT become a second mutable source of truth.

#### Scenario: App restarts after a new best set
- **WHEN** a completed workout updates an exercise performance profile and the app restarts or browser reloads
- **THEN** the complete persisted record set restores the same bests and provenance deterministically
- **AND** confirmed estimate metadata and milestone selection retain their catalog-version and source information.
