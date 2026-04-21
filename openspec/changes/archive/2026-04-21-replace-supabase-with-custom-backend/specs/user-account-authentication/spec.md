## MODIFIED Requirements

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
