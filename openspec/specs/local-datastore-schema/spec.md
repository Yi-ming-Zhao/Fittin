## ADDED Requirements

### Requirement: Engine State Persistence
The system MUST persist the engine-family-specific runtime state needed to reproduce future prescriptions exactly for each active training instance.

#### Scenario: App restarts mid-cycle
- **WHEN** the user closes and reopens the app while in the middle of a GZCLP or Jacked & Tan cycle
- **THEN** the restored instance still knows the engine family, the training-max profile, and the current progression state or week/block cursor needed to regenerate the same next workout prescription.

## MODIFIED Requirements

### Requirement: Database Instance Separation
The system MUST persist training templates separately from instances, linking instances to templates by a template ID, and it MUST support seeded templates plus user-authored editable template documents without mutating an existing instance's source template unexpectedly. Training instances for TM-driven programs MUST also persist the training-max profile that was used to generate their prescriptions.

The local datastore MUST additionally preserve enough metadata to support user ownership, versioned synchronization, and soft-delete propagation with Supabase.

#### Scenario: User starts a new plan
- **WHEN** a user selects a template to begin training
- **THEN** a new instance document is created with the user's training-max profile and engine state, without modifying the template.

#### Scenario: User starts a new plan while signed in
- **WHEN** a signed-in user selects a template to begin training
- **THEN** a new local instance document is created with the user's ownership metadata, training-max profile, and engine state
- **AND** that instance is eligible for later synchronization without modifying the source template.

#### Scenario: User saves changes to a template with active instances
- **WHEN** a user edits and saves a template that has already been used to create an instance
- **THEN** the saved template changes do not silently rewrite the existing instance's in-progress workout structure, progression state, or training-max-derived prescription history.

#### Scenario: Existing local data migrates to sync-aware schema
- **WHEN** an existing installation upgrades to the sync-enabled build
- **THEN** previously stored templates, instances, logs, and progress records are preserved
- **AND** each sync-eligible record receives default ownership and synchronization metadata needed for future cloud sync.

### Requirement: Local Sync Metadata
The local datastore MUST track per-record sync metadata for every entity that can round-trip with Supabase.

#### Scenario: User updates a plan while offline
- **WHEN** a sync-eligible record is created or edited locally without a successful cloud write yet
- **THEN** the record stores a sync status, version, timestamps, and device marker
- **AND** the sync engine can later detect, upload, and reconcile that pending change.

#### Scenario: User deletes a workout log on one device
- **WHEN** a synchronized record is removed by the user
- **THEN** the local datastore marks it as soft-deleted rather than immediately destroying all trace of it
- **AND** the deletion can be propagated safely to Supabase and other devices.
