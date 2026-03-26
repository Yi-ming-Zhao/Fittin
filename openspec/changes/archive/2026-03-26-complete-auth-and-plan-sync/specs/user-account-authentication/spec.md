## MODIFIED Requirements

### Requirement: User Account Authentication
The system MUST allow a user to create an account, sign in, restore an authenticated session, and sign out by using Supabase Auth. Authenticated state changes MUST also trigger the correct synchronization lifecycle so the signed-in experience reflects the user's actual cloud-backed dataset and the signed-out experience stops user-scoped sync work safely.

#### Scenario: User creates an account
- **WHEN** a new user submits valid sign-up credentials from the account entry flow
- **THEN** the app creates a Supabase-authenticated account
- **AND** the app stores or initializes that user's profile context for subsequent cloud data access.

#### Scenario: User restores a previous session
- **WHEN** the app launches and Supabase reports a valid authenticated session
- **THEN** the app restores the signed-in state without forcing the user to log in again
- **AND** the sync system begins hydrating that user's cloud-backed data into local storage before signed-in training surfaces claim sync is ready.

#### Scenario: User signs out
- **WHEN** the user selects sign out from the profile/settings surface
- **THEN** the app clears the authenticated session
- **AND** user-scoped cloud sync stops until another account is authenticated.

#### Scenario: Signed-in user views account status
- **WHEN** an authenticated user opens the account surface
- **THEN** the app shows whether cloud data is syncing, synchronized, or needs retry
- **AND** the status text MUST match the real state of the sync pipeline rather than a placeholder message.

### Requirement: Local-First Usage Before Authentication
The system MUST continue to support local-first usage when no account is signed in, and it MUST preserve that local data so it can later be attached to an authenticated account without blocking training flows.

#### Scenario: User uses the app without logging in
- **WHEN** the user starts or continues a workout before creating an account
- **THEN** the app still stores plans, active instances, and workout results locally
- **AND** the user can later connect an account to synchronize that local data.

#### Scenario: Local-only user signs in after generating data
- **WHEN** a user with locally stored plans, active instances, workout history, or progress records signs in
- **THEN** the app keeps the local data available on-device
- **AND** the authenticated sync flow claims or merges that data into the signed-in user's scope instead of discarding it.
