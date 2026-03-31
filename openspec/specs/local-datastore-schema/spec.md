## Purpose

Define how local training data, sync metadata, generated schema artifacts, and browser persistence behave across supported platforms.
## Requirements
### Requirement: Engine State Persistence
The system MUST persist the engine-family-specific runtime state needed to reproduce future prescriptions exactly for each active training instance.

#### Scenario: App restarts mid-cycle
- **WHEN** the user closes and reopens the app while in the middle of a GZCLP or Jacked & Tan cycle
- **THEN** the restored instance still knows the engine family, the training-max profile, and the current progression state or week/block cursor needed to regenerate the same next workout prescription.

### Requirement: Database Instance Separation
The system MUST persist training templates separately from instances, linking instances to templates by a template ID, and it MUST support seeded templates plus user-authored editable template documents without mutating an existing instance's source template unexpectedly. Training instances for TM-driven programs MUST also persist the training-max profile that was used to generate their prescriptions.

The local datastore MUST additionally preserve enough metadata to support user ownership, versioned synchronization, first-login claiming, conflict detection, and soft-delete propagation with Supabase.

Editable template documents MUST preserve schedule mode, slot-specific periodized content, supported set types, and per-exercise load-unit metadata without stripping those fields on save.

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

#### Scenario: Local-only records are claimed on first login
- **WHEN** a device contains sync-eligible records created before authentication
- **THEN** the datastore can attach those records to the authenticated user without rewriting their business identifiers or losing queue history
- **AND** the claimed records become eligible for upload on the next sync pass.

#### Scenario: User saves engine-aware editor metadata
- **WHEN** a user saves a template after changing schedule mode metadata, set types, or load units
- **THEN** those fields are preserved in the stored editable template document and survive app restart and reload.

### Requirement: Local Sync Metadata
The local datastore MUST track per-record sync metadata for every entity that can round-trip with Supabase. That metadata MUST be sufficient to identify pending uploads, pending deletes, synchronized records, conflicts, last-write timing, and the source device or sync attempt needed for reconciliation.

#### Scenario: User updates a plan while offline
- **WHEN** a sync-eligible record is created or edited locally without a successful cloud write yet
- **THEN** the record stores a sync status, version, timestamps, and device marker
- **AND** the sync engine can later detect, upload, and reconcile that pending change.

#### Scenario: User deletes a workout log on one device
- **WHEN** a synchronized record is removed by the user
- **THEN** the local datastore marks it as soft-deleted rather than immediately destroying all trace of it
- **AND** the deletion can be propagated safely to Supabase and other devices.

#### Scenario: Sync engine detects overlapping local and remote edits
- **WHEN** a local pending change and a newer remote change target the same sync-eligible record
- **THEN** the datastore preserves enough metadata to mark the record as conflicted
- **AND** the record remains inspectable and recoverable until reconciliation finishes.

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

### Requirement: Web-Safe Generated Datastore Metadata
The local datastore MUST keep checked-in generated schema metadata compatible with every supported Flutter target, including JavaScript compilation for Flutter Web. Generated collection and index identifier literals that exceed JavaScript's exact integer range MUST be normalized before Web builds consume those files.

#### Scenario: Flutter Web compiles generated datastore schema
- **WHEN** the app is compiled for Chrome or another Flutter Web target
- **THEN** the generated local datastore schema files contain no identifier literal outside JavaScript's exact integer range
- **AND** compilation does not fail with integer precision errors from Isar-generated schema code

#### Scenario: Developers regenerate datastore schema files
- **WHEN** developers rerun Isar code generation and new `*.g.dart` schema files are produced
- **THEN** the repository provides a repeatable normalization step for unsafe identifier literals
- **AND** the generated files can be brought back to a Web-compatible state before commit or build

### Requirement: Web Datastore Startup Compatibility
The app MUST initialize the local datastore on Flutter Web without requiring native filesystem directory APIs before `runApp()`.

#### Scenario: Browser startup opens the datastore
- **WHEN** the app starts in Chrome or another Flutter Web runtime
- **THEN** datastore initialization avoids native-only local directory lookups
- **AND** the app reaches widget rendering instead of stalling on a blank page before first frame

### Requirement: Browser-Persistent Local Datastore
The system MUST provide a browser-persistent local datastore implementation for Flutter Web instead of falling back to a session-only in-memory repository. The web datastore MUST preserve the same local entity categories required by the current application flow, including templates, active instances, workout logs, body metrics, progress photo metadata, app state, and sync queue records.

#### Scenario: User refreshes the web app
- **WHEN** a user creates or updates supported local records in the browser and then refreshes the page
- **THEN** the web app restores those records from browser-persistent local storage
- **AND** the user does not lose the local working set because of a page reload

#### Scenario: User reopens the web app later
- **WHEN** the same browser opens the web app again after a prior session stored local records
- **THEN** the app restores the prior local templates, instances, progress records, and app state
- **AND** the user can resume from the previously active local context

### Requirement: Active Session Draft Persistence
The local datastore MUST persist the current active workout draft, including exercise order, current exercise selection, recorded set values, and completion flags, so the workout can resume after app restart or browser refresh.

#### Scenario: User resumes a saved workout draft
- **WHEN** the app reloads while an active training instance still has a saved workout draft
- **THEN** the datastore restores that draft payload for the same user and training instance
- **AND** the app can continue the workout without regenerating the session from scratch.

### Requirement: Editable Workout Log Identity
The local datastore MUST assign and preserve a stable identity for each workout log so later edits target the same stored record on every supported platform.

#### Scenario: User saves a workout and later edits it
- **WHEN** the app creates a workout log and the user later reopens that same workout for editing
- **THEN** the datastore identifies the original log by a stable log identifier
- **AND** saving the edit updates that existing record instead of creating a duplicate workout log.

### Requirement: Workout Log Replay Metadata
The local datastore MUST preserve optional replay metadata for workout logs created by the updated conclusion flow so the system can safely decide whether a later edit may rewrite progression.

#### Scenario: User edits the latest replay-capable workout
- **WHEN** a recently saved workout log includes pre-conclusion and post-conclusion progression snapshots
- **THEN** the datastore exposes that metadata to the workout-log update flow
- **AND** the app can use it to recompute the current instance state from the edited workout when allowed.

