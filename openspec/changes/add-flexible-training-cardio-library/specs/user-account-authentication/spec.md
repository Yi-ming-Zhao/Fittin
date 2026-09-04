## ADDED Requirements

### Requirement: Durable rotating authenticated session
After a successful login, the system SHALL keep the account signed in across normal restarts by refreshing a revocable session and SHALL not require credentials again solely because the access token expired.

#### Scenario: Access token expires
- **WHEN** a stored refresh session remains valid and the access token is expired or receives an authenticated 401
- **THEN** the client rotates the session, retries the request once, and keeps the same user signed in

#### Scenario: App starts offline
- **WHEN** the app cannot reach the authentication service but has a cached user and refresh credentials
- **THEN** it keeps the cached account active for local use and retries validation later without clearing tokens

### Requirement: Explicit credential clearing
The system MUST clear persisted login credentials only after explicit sign-out, account deletion, or a definitive refresh-session rejection; transient timeouts, rate limits, server errors, malformed gateway responses, and offline startup MUST NOT clear them.

#### Scenario: Authentication gateway returns an HTML 502
- **WHEN** session restoration receives a transient non-JSON gateway response
- **THEN** the cached user remains signed in and local training features remain available

#### Scenario: Refresh token is revoked
- **WHEN** refresh responds with a definitive revoked or invalid status
- **THEN** the system clears the session and presents the login action once
