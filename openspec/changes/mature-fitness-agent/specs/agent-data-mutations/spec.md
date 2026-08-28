## ADDED Requirements

### Requirement: Transaction-local trusted mutation boundary
Confirmation and undo SHALL read preconditions, validate owner and active draft state, write business rows and synchronization changes, and save the audit record inside one transaction. Complete snapshots SHALL preserve explicit nulls. Model input SHALL NOT control internal identity, synchronization or progression snapshots.

#### Scenario: Concurrent update before commit
- **WHEN** another writer changes a target after preview
- **THEN** transaction-local validation refuses the mutation without partial writes

#### Scenario: Undo nullable metric
- **WHEN** a newly populated optional metric is undone
- **THEN** its original null value is restored exactly

#### Scenario: Undo a plan revision with new history or a draft
- **WHEN** the revised plan has acquired a training draft or training history, including soft-deleted logs
- **THEN** undo is refused without changing the active instance, plan, logs, draft or applied audit status

#### Scenario: Safely restore a revised plan
- **WHEN** a revision with no subsequent data changes is undone
- **THEN** the original plan instance and stable progress are restored, the unused copy is soft-deleted, and closing and reopening native storage preserves the result

#### Scenario: Mutation refresh does not start unopened pages
- **WHEN** a mutation commits or is undone
- **THEN** subscribed pages receive a refresh while unopened page providers do not start background database readers or seed writers

### Requirement: Complete semantic mutation previews
Every proposal SHALL contain all changed business fields, including dates and individual sets, SHALL reject no-ops, and SHALL protect active training drafts from plan migration.

#### Scenario: Training draft exists
- **WHEN** the Agent proposes revising the active plan during unfinished training
- **THEN** the proposal is refused without modifying or discarding the draft

### Requirement: Explicit analytics range
Agent aggregates SHALL use one explicit start/end/asOf range and publish timezone, units and source counts.

#### Scenario: Ninety day analysis
- **WHEN** ninety days are requested
- **THEN** volume and training days use that same range rather than dashboard thirty-day defaults
