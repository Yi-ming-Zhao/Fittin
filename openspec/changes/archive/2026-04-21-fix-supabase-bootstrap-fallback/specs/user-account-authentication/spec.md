## ADDED Requirements

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
