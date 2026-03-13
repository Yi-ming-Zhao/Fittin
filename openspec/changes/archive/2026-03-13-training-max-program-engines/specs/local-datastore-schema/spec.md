## ADDED Requirements

### Requirement: Engine State Persistence
The system MUST persist the engine-family-specific runtime state needed to reproduce future prescriptions exactly for each active training instance.

#### Scenario: App restarts mid-cycle
- **WHEN** the user closes and reopens the app while in the middle of a GZCLP or Jacked & Tan cycle
- **THEN** the restored instance still knows the engine family, the training-max profile, and the current progression state or week/block cursor needed to regenerate the same next workout prescription.

## MODIFIED Requirements

### Requirement: Database Instance Separation
The system MUST persist training templates separately from instances, linking instances to templates by a template ID, and it MUST support seeded templates plus user-authored editable template documents without mutating an existing instance's source template unexpectedly. Training instances for TM-driven programs MUST also persist the training-max profile that was used to generate their prescriptions.

#### Scenario: User starts a new plan
- **WHEN** a user selects a template to begin training
- **THEN** a new instance document is created with the user's training-max profile and engine state, without modifying the template.

#### Scenario: User saves changes to a template with active instances
- **WHEN** a user edits and saves a template that has already been used to create an instance
- **THEN** the saved template changes do not silently rewrite the existing instance's in-progress workout structure, progression state, or training-max-derived prescription history.
