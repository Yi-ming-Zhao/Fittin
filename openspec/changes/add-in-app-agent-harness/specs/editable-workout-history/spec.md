## ADDED Requirements

### Requirement: Agent workout-log changes use history safeguards
Agent-proposed workout-log creation, editing, and deletion SHALL preserve log identity, snapshots, owner scope, validation, sync tombstones, and the existing latest-log progression-rewrite constraints.

#### Scenario: Confirmed latest-log correction
- **WHEN** the current instance still matches the corrected latest log's post-conclusion snapshot
- **THEN** the log and recomputed instance progression commit together and the action is undoable
