## Purpose

Define account sign-up, sign-in, session restoration, and sign-out behavior for authenticated users.
## Requirements
### Requirement: User Account Authentication
The system MUST allow a user to create an account, sign in, restore an authenticated session, and sign out by using the project-owned backend instead of Supabase Auth. Authenticated state changes MUST also trigger the correct synchronization lifecycle so the signed-in experience reflects the user's actual cloud-backed dataset and the signed-out experience stops user-scoped sync work safely.

#### Scenario: User creates an account
- **WHEN** a new user submits valid sign-up credentials from the account entry flow
- **THEN** the app creates a backend-authenticated account
- **AND** the app stores that authenticated session for subsequent cloud data access.

#### Scenario: User restores a previous session
- **WHEN** the app launches and the backend validates a previously stored access token
- **THEN** the app restores the signed-in state without forcing the user to log in again
- **AND** the sync system begins hydrating that user's cloud-backed data into local storage before signed-in training surfaces claim sync is ready.

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

### Requirement: Account Surface Reflects Bootstrap Availability
The account surface MUST reflect the real Supabase bootstrap state so a local-first user can distinguish between missing explicit configuration, unreachable local fallback, and a usable authenticated backend.

#### Scenario: Supabase bootstrap is unavailable
- **WHEN** the account surface opens while Supabase bootstrap could not resolve a usable backend
- **THEN** the app shows that account authentication is unavailable
- **AND** the message matches the actual bootstrap failure reason rather than a generic placeholder

#### Scenario: Android APK is missing explicit Supabase config
- **WHEN** the account surface opens on an Android APK build without explicit `SUPABASE_URL` and `SUPABASE_ANON_KEY`
- **THEN** the app shows that account authentication is unavailable
- **AND** the message explains that repo-local localhost fallback is not used for Android device builds

