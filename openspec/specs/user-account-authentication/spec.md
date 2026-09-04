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
The account surface MUST reflect the real backend bootstrap state so a local-first user can distinguish between missing explicit configuration, unreachable local fallback, and a usable authenticated backend.

#### Scenario: Backend bootstrap is unavailable
- **WHEN** the account surface opens while backend bootstrap could not resolve a usable backend
- **THEN** the app shows that account authentication is unavailable
- **AND** the message matches the actual bootstrap failure reason rather than a generic placeholder

#### Scenario: Android APK is missing explicit backend config
- **WHEN** the account surface opens on an Android APK build without explicit `BACKEND_URL`
- **THEN** the app shows that account authentication is unavailable
- **AND** the message explains that repo-local localhost fallback is not used for Android device builds

### Requirement: Normalized and Failure-Aware Authentication
Authentication MUST normalize email identity consistently, enforce bounded password policy, protect session tokens in platform-appropriate secure storage, and distinguish invalid credentials from unavailable backend or database responses.

#### Scenario: Database is unavailable during sign-in
- **WHEN** credential lookup fails because the database is unavailable
- **THEN** the backend returns a service error rather than an invalid-credentials response.

#### Scenario: Equivalent email casing is used
- **WHEN** a user signs in with different email casing or surrounding whitespace
- **THEN** the normalized identity resolves to the same account.

### Requirement: Durable rotating authenticated session
After a successful login, the system SHALL keep the account signed in across normal restarts by refreshing a revocable session and SHALL not require credentials again solely because the access token expired.

#### Scenario: Access token expires
- **WHEN** a stored refresh session remains valid and the access token is expired or receives an authenticated 401
- **THEN** the client rotates the session, retries the request once, and keeps the same user signed in.

#### Scenario: App starts offline
- **WHEN** the app cannot reach the authentication service but has a cached user and refresh credentials
- **THEN** it keeps the cached account active for local use and retries validation later without clearing tokens.

### Requirement: Explicit credential clearing
The system MUST clear persisted login credentials only after explicit sign-out, account deletion, or a definitive refresh-session rejection; transient timeouts, rate limits, server errors, malformed gateway responses, and offline startup MUST NOT clear them.

#### Scenario: Authentication gateway returns an HTML 502
- **WHEN** session restoration receives a transient non-JSON gateway response
- **THEN** the cached user remains signed in and local training features remain available.

#### Scenario: Refresh token is revoked
- **WHEN** refresh responds with a definitive revoked or invalid status
- **THEN** the system clears the session and presents the login action once.
