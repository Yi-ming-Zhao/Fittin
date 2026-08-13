## ADDED Requirements

### Requirement: Device-local Agent stores
Native and Web persistence SHALL add stores for conversations and action records that are partitioned by local owner identity and are not included in cloud sync entity types.

#### Scenario: Existing database opens after upgrade
- **WHEN** an installation with plans, instances, logs, metrics, preferences, and authentication upgrades to v1.1.0
- **THEN** all existing records remain readable and empty Agent stores become available

### Requirement: Atomic Web mutation batches
Web persistence SHALL support one IndexedDB read/write transaction across every business, sync-queue, and Agent-action store touched by a confirmed mutation.

#### Scenario: Web mutation aborts
- **WHEN** any request in a multi-store Agent mutation fails
- **THEN** no affected business record, sync row, or action record is partially committed
