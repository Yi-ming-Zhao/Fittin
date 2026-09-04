## ADDED Requirements

### Requirement: Versioned user-content persistence
Native Isar and Web IndexedDB SHALL add an owner-scoped, versioned user-content collection for custom exercises, cardio activity definitions, cardio records, import fingerprints, and custom palettes without rewriting existing stores.

#### Scenario: Existing v1.2.1 installation upgrades
- **WHEN** the upgraded app opens a database containing plans, instances, drafts, logs, body metrics, Agent history, and settings
- **THEN** all existing records remain byte-equivalent in meaning and the new collection begins empty

### Requirement: IndexedDB additive upgrade
Web storage SHALL increment its schema version additively, create only missing object stores, close stale connections on version change, and provide a bounded blocked-upgrade recovery message.

#### Scenario: Older tab blocks the upgrade
- **WHEN** an open v3 tab prevents creation of the new store
- **THEN** startup asks the user to close the old tab and retry rather than deleting or recreating the database
