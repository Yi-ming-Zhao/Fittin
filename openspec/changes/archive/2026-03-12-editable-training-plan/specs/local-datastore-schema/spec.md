## MODIFIED Requirements

### Requirement: Database Instance Separation
The system MUST persist training templates separately from instances, linking instances to templates by a template ID, and it MUST support seeded templates plus user-authored editable template documents without mutating an existing instance's source template unexpectedly.

#### Scenario: User starts a new plan
- **WHEN** a user selects a template to begin training
- **THEN** a new instance document is created with the user's initial 1RM or starting weights, without modifying the template.

#### Scenario: User saves changes to a template with active instances
- **WHEN** a user edits and saves a template that has already been used to create an instance
- **THEN** the saved template changes do not silently rewrite the existing instance's in-progress workout structure or progression state.

### Requirement: Isar Offline Integration
The database MUST use Isar as its underlying engine, requiring all schema objects to be correctly mapped into Isar collections with appropriate indices and enough metadata to distinguish built-in templates from user-authored editable copies.

#### Scenario: Rapid offline read and write
- **WHEN** the user saves a set completion with no internet connection
- **THEN** it instantly persists into the Isar local database with asynchronous transaction operations completing successfully.

#### Scenario: User browses editable templates offline
- **WHEN** the user opens the plan management flow with no internet connection
- **THEN** the app can list built-in and user-saved templates locally and load any chosen template into the editor.
