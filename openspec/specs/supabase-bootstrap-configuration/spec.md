# supabase-bootstrap-configuration Specification

## Purpose
Define how the app resolves its authenticated backend runtime configuration while preserving a local development fallback for non-Android runtimes.

## Requirements
### Requirement: Backend Bootstrap Resolution
The system MUST resolve backend runtime configuration by preferring explicit `BACKEND_URL` and optional `BACKEND_API_KEY` values first, and it MUST only fall back to the repository's local backend development endpoint after confirming that the local endpoint is reachable.

#### Scenario: Explicit runtime configuration is provided
- **WHEN** `BACKEND_URL` is supplied to the app
- **THEN** the app uses that explicit backend URL for authentication and sync
- **AND** it includes `BACKEND_API_KEY` when that optional value is supplied
- **AND** it does not switch to the local development endpoint instead

#### Scenario: Local development backend is reachable
- **WHEN** explicit backend runtime configuration is absent
- **AND** the runtime is not an Android APK build
- **AND** the repository's local backend endpoint responds to the bootstrap reachability check
- **THEN** the app initializes authentication and sync against that local development endpoint

#### Scenario: No usable backend configuration is available
- **WHEN** explicit backend runtime configuration is absent
- **AND** the runtime is not an Android APK build
- **AND** the local development backend does not respond to the bootstrap reachability check
- **THEN** the app keeps account authentication unavailable
- **AND** it returns an unavailable reason that identifies the missing explicit config and unreachable local fallback

#### Scenario: Android APK runtime requires explicit configuration
- **WHEN** explicit backend runtime configuration is absent
- **AND** the app is running as an Android APK runtime
- **THEN** the app keeps account authentication unavailable
- **AND** it returns an unavailable reason that tells the user Android builds need explicit backend config instead of repo-local localhost fallback
