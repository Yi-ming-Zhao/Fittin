# supabase-bootstrap-configuration Specification

## Purpose
TBD - created by archiving change fix-supabase-bootstrap-fallback. Update Purpose after archive.
## Requirements
### Requirement: Supabase Bootstrap Resolution
The system MUST resolve Supabase runtime configuration by preferring explicit `SUPABASE_URL` and `SUPABASE_ANON_KEY` values first, and it MUST only fall back to the repository's local Supabase development stack after confirming that the local endpoint is reachable.

#### Scenario: Explicit runtime configuration is provided
- **WHEN** both `SUPABASE_URL` and `SUPABASE_ANON_KEY` are supplied to the app
- **THEN** the app uses those explicit values for Supabase initialization
- **AND** it does not switch to the local development stack instead

#### Scenario: Local development stack is reachable
- **WHEN** explicit Supabase runtime configuration is absent
- **AND** the runtime is not an Android APK build
- **AND** the repository's local Supabase gateway responds to the bootstrap reachability check
- **THEN** the app initializes Supabase against that local development stack

#### Scenario: No usable Supabase configuration is available
- **WHEN** explicit Supabase runtime configuration is absent
- **AND** the runtime is not an Android APK build
- **AND** the local development stack does not respond to the bootstrap reachability check
- **THEN** the app keeps account authentication unavailable
- **AND** it returns an unavailable reason that identifies the missing explicit config and unreachable local fallback

#### Scenario: Android APK runtime requires explicit configuration
- **WHEN** explicit Supabase runtime configuration is absent
- **AND** the app is running as an Android APK runtime
- **THEN** the app keeps account authentication unavailable
- **AND** it returns an unavailable reason that tells the user Android builds need explicit Supabase config instead of repo-local localhost fallback

