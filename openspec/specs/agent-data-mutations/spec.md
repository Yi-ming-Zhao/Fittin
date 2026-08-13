# agent-data-mutations Specification

## Purpose
Define the local read, proposal, confirmation, persistence, and undo boundaries for Agent-driven training data operations.

## Requirements

### Requirement: Owner-scoped bounded read tools
The Agent SHALL expose typed, owner-scoped tools for plans, active plan state, workout history, PRs, progress analytics, muscle load, consistency, and body metrics, and SHALL bound raw rows through date filters and cursors.

#### Scenario: Lifetime progress analysis
- **WHEN** the Agent requests a lifetime training analysis
- **THEN** the application returns deterministic local aggregates and only paginates raw records that are necessary for follow-up

### Requirement: Proposal-only structured writes
The Agent SHALL support validated proposals for plan creation/revision/restricted deletion, historical workout-log creation/edit/deletion, and body-metric creation/edit/deletion, and SHALL exclude photos, accounts, authentication, settings, files, and arbitrary code.

#### Scenario: Model requests a body metric change
- **WHEN** a write tool receives a valid body metric update
- **THEN** the application creates a semantic before/after proposal and does not update storage

#### Scenario: Model requests an excluded operation
- **WHEN** the model requests a progress photo or account operation
- **THEN** the tool registry returns a stable unsupported-operation result without exposing the underlying resource

### Requirement: Confirmed atomic and idempotent mutation
Every proposal SHALL carry an operation ID and target version or canonical digest, SHALL revalidate on confirmation, and SHALL atomically persist business entities, sync-queue operations, and an action record.

#### Scenario: User double taps confirm
- **WHEN** the same operation ID is confirmed more than once
- **THEN** the mutation is committed once and subsequent confirmations return the recorded result

#### Scenario: Target changed after preview
- **WHEN** the target version or digest differs at confirmation time
- **THEN** the application refuses the mutation and asks the user to regenerate the proposal

### Requirement: Safe active plan migration
Revising the active plan SHALL fork the template, map the next workout by stable ID, preserve compatible training max, engine, and exercise state, and list every initialized or removed item before confirmation.

#### Scenario: Compatible active plan revision
- **WHEN** a confirmed revision retains the current workout and exercise IDs
- **THEN** the active instance moves to the new template without resetting its current week or retained exercise progress

### Requirement: Explicit workout progression effects
Historical log creation SHALL not advance plan state, and log edit/deletion SHALL change current progression only when the latest log snapshots exactly match the active instance chain.

#### Scenario: Older log is edited
- **WHEN** an older workout log is edited
- **THEN** analytics update but the current training instance is unchanged and the proposal states that effect

### Requirement: Local audit and conflict-safe undo
Successful Agent actions SHALL retain bounded local before/after snapshots and SHALL offer undo only while targets still match the recorded after-state; inverse writes SHALL use the ordinary sync path.

#### Scenario: Undo after remote change
- **WHEN** synced data changed after the Agent action
- **THEN** undo is blocked as a conflict and no inverse write is queued
