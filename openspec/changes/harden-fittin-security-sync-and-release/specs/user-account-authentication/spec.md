## ADDED Requirements

### Requirement: Normalized and failure-aware authentication
Authentication SHALL normalize email identity consistently, enforce bounded password policy, protect session tokens in platform-appropriate secure storage, and distinguish invalid credentials from unavailable backend/database responses.

#### Scenario: Database is unavailable during sign-in
- **WHEN** credential lookup fails because the database is unavailable
- **THEN** the backend returns a service error rather than an invalid-credentials response

#### Scenario: Equivalent email casing is used
- **WHEN** a user signs in with different email casing or surrounding whitespace
- **THEN** the normalized identity resolves to the same account
