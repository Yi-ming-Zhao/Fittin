## MODIFIED Requirements

### Requirement: User-Scoped Cloud Synchronization
The system MUST synchronize user-owned training data between the local datastore and the project-owned backend under the authenticated user's identity. Synchronization MUST cover plans, active training instances, workout logs, body metrics, and progress photo metadata so the same signed-in user can recover a consistent state across launches and devices. A signed-in sync run MUST hydrate existing cloud records before claiming local-only records for upload so devices do not create duplicate or conflicting account state before learning the backend state.

#### Scenario: Signed-in user completes a workout
- **WHEN** a signed-in user successfully concludes a workout session
- **THEN** the workout log and updated training instance are saved locally first
- **AND** the app automatically starts a backend sync attempt for that user without requiring a manual tap on the account screen.

#### Scenario: Existing account signs in on a second device
- **WHEN** a user signs in on a device whose local store has no active user-scoped training instance
- **AND** the backend already has synchronized training instances and workout logs for that user
- **THEN** the sync flow hydrates the remote records into local storage
- **AND** the app selects a hydrated non-deleted training instance as the user's active instance
- **AND** training history surfaces can read the hydrated workout logs for that authenticated user.

#### Scenario: Local records exist before account hydration
- **WHEN** a signed-in sync run starts on a device with local-only records
- **AND** the authenticated account already has cloud-backed records
- **THEN** the app pulls the authenticated user's remote records before claiming local-only records for upload
- **AND** it avoids uploading shared default instance IDs over records owned by a different backend user.

### Requirement: First Login Merge
The system MUST merge or attach existing local data into the authenticated user's cloud scope when a local-only user signs in for the first time on a device. The merge flow MUST preserve the local working set and avoid destructive overwrites when equivalent cloud-backed records already exist.

#### Scenario: Local-only user signs in after using the app offline
- **WHEN** a user with existing local plans and workout history signs in on that device for the first time
- **THEN** the app preserves the existing local data
- **AND** it performs a first-login merge into the authenticated user's synchronized dataset instead of deleting or blindly overwriting that data.

#### Scenario: Signed-in user already has cloud-backed data
- **WHEN** the device contains local-only records and the authenticated account also already has synchronized plans or logs
- **THEN** the sync flow reconciles ownership and version metadata for each record type
- **AND** the app keeps conflicting records recoverable instead of silently losing either side.

### Requirement: Web Cloud Hydration
Flutter Web MUST hydrate synchronized user-owned records from the backend back into browser-local storage using the same entity coverage as supported native clients.

#### Scenario: Signed-in web user opens the app on an existing account
- **WHEN** a signed-in user with cloud-backed plans and logs opens the browser client
- **THEN** the web app restores those synchronized records into browser-local storage
- **AND** the browser client can continue from the synchronized local state after hydration completes

#### Scenario: Signed-in web user retries sync after local pending state exists
- **WHEN** the browser client has pending sync queue records for the authenticated user
- **AND** the backend already has records for that account
- **THEN** retrying sync first hydrates backend state into browser storage
- **AND** the retry does not fail with a low-level no-rows result caused by cross-user record ID ownership.
