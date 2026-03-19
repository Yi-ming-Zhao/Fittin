## ADDED Requirements

### Requirement: User Account Authentication
The system MUST allow a user to create an account, sign in, restore an authenticated session, and sign out by using Supabase Auth.

#### Scenario: User creates an account
- **WHEN** a new user submits valid sign-up credentials from the account entry flow
- **THEN** the app creates a Supabase-authenticated account
- **AND** the app stores or initializes that user's profile context for subsequent cloud data access.

#### Scenario: User restores a previous session
- **WHEN** the app launches and Supabase reports a valid authenticated session
- **THEN** the app restores the signed-in state without forcing the user to log in again
- **AND** the sync system becomes eligible to load that user's cloud-backed data.

#### Scenario: User signs out
- **WHEN** the user selects sign out from the profile/settings surface
- **THEN** the app clears the authenticated session
- **AND** user-scoped cloud sync stops until another account is authenticated.

### Requirement: Local-First Usage Before Authentication
The system MUST continue to support local-first usage when no account is signed in.

#### Scenario: User uses the app without logging in
- **WHEN** the user starts or continues a workout before creating an account
- **THEN** the app still stores plans, active instances, and workout results locally
- **AND** the user can later connect an account to synchronize that local data.
