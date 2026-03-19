## ADDED Requirements

### Requirement: User-Scoped Cloud Synchronization
The system MUST synchronize user-owned training data between the local datastore and Supabase under the authenticated user's identity.

#### Scenario: Signed-in user launches the app on another device
- **WHEN** the same authenticated user opens the app on a different device
- **THEN** the app restores that user's cloud-backed plans, active training instances, workout logs, and progress records into local storage
- **AND** the user can continue from the previously synchronized state.

#### Scenario: User edits a personal plan while signed in
- **WHEN** a signed-in user saves changes to a user-owned training plan
- **THEN** the updated plan persists locally first
- **AND** the change is queued for Supabase synchronization under that user account.

#### Scenario: User completes a workout while offline
- **WHEN** a signed-in user finishes a workout without network access
- **THEN** the workout result is saved locally without blocking the training flow
- **AND** the result is uploaded to Supabase after connectivity and sync are restored.

### Requirement: First Login Merge
The system MUST merge or attach existing local data into the authenticated user's cloud scope when a local-only user signs in for the first time on a device.

#### Scenario: Local-only user signs in after using the app offline
- **WHEN** a user with existing local plans and workout history signs in on that device for the first time
- **THEN** the app preserves the existing local data
- **AND** it performs a first-login merge into the authenticated user's synchronized dataset instead of deleting or blindly overwriting that data.

### Requirement: Progress Photo Cloud Backup
The system MUST back up progress photo metadata and associated files in a way that preserves local viewing while enabling cross-device recovery.

#### Scenario: User backs up a progress photo
- **WHEN** a signed-in user saves a progress photo record
- **THEN** the app keeps a local reference for offline viewing
- **AND** uploads the photo file and metadata to Supabase-backed cloud storage for future restore.
