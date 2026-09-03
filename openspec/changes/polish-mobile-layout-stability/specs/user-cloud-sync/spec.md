## MODIFIED Requirements

### Requirement: Conflict-Preserving Compare-And-Set Sync
Cloud mutations MUST be accepted only when they create a row, advance its version, or repeat an identical same-device version; competing equal or stale versions MUST produce a structured conflict and MUST remain queued locally. A synchronization pass with any preserved conflict MUST expose a conflict result to the application controller and MUST NOT publish the pass as successfully synchronized.

#### Scenario: Two devices edit the same version
- **WHEN** two devices independently submit different values derived from the same remote version
- **THEN** one mutation succeeds and the other is retained as a user-resolvable conflict without data loss.

#### Scenario: Manual synchronization preserves a conflict
- **WHEN** a sync pass receives or encounters a retained conflict
- **THEN** the account UI reports that conflict instead of updating the successful-sync status
- **AND** pending conflicting work remains available for a later resolution flow.
