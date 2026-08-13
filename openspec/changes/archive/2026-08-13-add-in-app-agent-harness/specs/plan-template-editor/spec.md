## ADDED Requirements

### Requirement: Agent plans reuse editor validation
Agent-created and Agent-revised templates SHALL pass the same normalization and validation contract as manually edited templates and SHALL preserve stable identifiers for unchanged nodes.

#### Scenario: Invalid proposed plan
- **WHEN** a proposed plan contains unsupported schedule, load, set, or progression values
- **THEN** the proposal is rejected before approval and validation errors are returned to the Agent
