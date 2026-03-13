## ADDED Requirements

### Requirement: Database Instance Separation
The system MUST persist training templates (read-only plan structures) separately from instances (user's ongoing progress), linking instances to templates by a template ID.

#### Scenario: User starts a new plan
- **WHEN** a user selects a template to begin training
- **THEN** a new instance document is created with the user's initial 1RM or starting weights, without modifying the template.

### Requirement: Isar Offline Integration
The database MUST use Isar as its underlying engine, requiring all schema objects to be correctly mapped into Isar collections with appropriate indices.

#### Scenario: Rapid offline read and write
- **WHEN** the user saves a set completion with no internet connection
- **THEN** it instantly persists into the Isar local database with asynchronous transaction operations completing successfully
