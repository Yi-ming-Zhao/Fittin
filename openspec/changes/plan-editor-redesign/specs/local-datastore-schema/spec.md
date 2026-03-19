## ADDED Requirements

### Requirement: Template Schedule Mode Persistence
The system MUST persist whether an editable training template is a `linear` or `periodized` schedule so the editor can restore the correct navigation model and slot structure.

#### Scenario: User reopens a saved template
- **WHEN** the user later opens an existing editable template
- **THEN** the restored document still declares its scheduling mode
- **AND** the editor reopens in the correct linear or periodized workflow.

### Requirement: Set Type and Load Unit Persistence
The system MUST persist structured set-type metadata and load-unit metadata for editable templates instead of collapsing them into booleans or plain weight numbers.

#### Scenario: User saves a top set with percent-based loading
- **WHEN** a user saves a set whose type is `top_set` and whose load unit is `%1RM`
- **THEN** the stored template preserves both the set type and the `%1RM` load semantics for future editing and runtime evaluation.

## MODIFIED Requirements

### Requirement: Database Instance Separation
The system MUST persist training templates separately from instances, linking instances to templates by a template ID, and it MUST support seeded templates plus user-authored editable template documents without mutating an existing instance's source template unexpectedly. Training instances for TM-driven programs MUST also persist the training-max profile that was used to generate their prescriptions.

Editable template documents MUST preserve schedule mode, slot-specific periodized content, supported set types, and per-exercise load-unit metadata without stripping those fields on save.

#### Scenario: User starts a new plan
- **WHEN** a user selects a template to begin training
- **THEN** a new instance document is created with the user's training-max profile and engine state, without modifying the template.

#### Scenario: User saves changes to a template with active instances
- **WHEN** a user edits and saves a template that has already been used to create an instance
- **THEN** the saved template changes do not silently rewrite the existing instance's in-progress workout structure, progression state, or training-max-derived prescription history.

#### Scenario: User saves engine-aware editor metadata
- **WHEN** a user saves a template after changing schedule mode metadata, set types, or load units
- **THEN** those fields are preserved in the stored editable template document and survive app restart and reload.
