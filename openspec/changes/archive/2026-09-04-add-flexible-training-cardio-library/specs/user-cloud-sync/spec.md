## ADDED Requirements

### Requirement: User-content synchronization
Signed-in custom exercises, cardio definitions, cardio records, import fingerprints, and custom palettes SHALL use the existing offline queue, owner isolation, soft deletion, version comparison, bounded retry, and conflict presentation rules.

#### Scenario: Cardio is recorded on one device
- **WHEN** the record synchronizes and another device hydrates the same account
- **THEN** the second device receives the same typed metrics and does not create a duplicate import

#### Scenario: Custom palette changes on two devices
- **WHEN** both devices revise the same version before either receives the other change
- **THEN** neither update silently overwrites the other and the sync status reports a conflict

### Requirement: Local content claim
The first-login merge SHALL claim eligible local custom exercises, cardio content, and palettes exactly once without changing stable IDs or source fingerprints.

#### Scenario: Offline user signs in
- **WHEN** the device contains local cardio and custom exercise documents
- **THEN** they become owned by the signed-in account, enter the upload queue once, and remain visible throughout the merge
