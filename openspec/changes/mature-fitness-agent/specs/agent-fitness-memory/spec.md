## ADDED Requirements

### Requirement: Explicit local fitness preferences
The Agent SHALL automatically retain only explicitly stated equipment, schedule, time, units and exercise preferences, with source provenance and owner isolation, at most 50 entries. It SHALL NOT retain credentials, account data, raw measurements, diagnoses or inferred health information.

#### Scenario: Explicit equipment preference
- **WHEN** the user explicitly states an allowed equipment preference
- **THEN** the preference is stored locally, deduplicated and visible in settings

### Requirement: User memory control
Users SHALL be able to disable automatic extraction, view, edit, delete and clear preferences without cloud synchronization.

#### Scenario: Disabled extraction
- **WHEN** automatic memory is disabled
- **THEN** new messages do not create preferences and existing entries remain manageable
