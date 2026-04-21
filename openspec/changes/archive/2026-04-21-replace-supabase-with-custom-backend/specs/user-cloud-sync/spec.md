## MODIFIED Requirements

### Requirement: User-Scoped Cloud Synchronization
The system MUST synchronize user-owned training data between the local datastore and the project-owned backend under the authenticated user's identity. Synchronization MUST cover plans, active training instances, workout logs, body metrics, and progress photo metadata so the same signed-in user can recover a consistent state across launches and devices.

#### Scenario: Signed-in user completes a workout
- **WHEN** a signed-in user successfully concludes a workout session
- **THEN** the workout log and updated training instance are saved locally first
- **AND** the app automatically starts a backend sync attempt for that user without requiring a manual tap on the account screen.

### Requirement: Progress Photo Cloud Backup
The system MUST back up progress photo metadata and associated files through the project-owned backend in a way that preserves local viewing while enabling cross-device recovery.

#### Scenario: User backs up a progress photo
- **WHEN** a signed-in user saves a progress photo record
- **THEN** the app keeps a local reference for offline viewing
- **AND** uploads the photo file and metadata to the project-owned backend for future restore.
