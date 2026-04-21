## MODIFIED Requirements

### Requirement: Public Web Release Build
The system MUST provide a repeatable release build flow for the Flutter Web client that is suitable for public serving at `https://fittin.yimelo.cc/` and for packaging the same build output as a versioned release artifact in CI.

#### Scenario: Build a public web release locally
- **WHEN** a maintainer prepares a new public web deployment on the host machine
- **THEN** the documented build flow produces a Flutter Web release build from the repository
- **AND** the build flow uses explicit `BACKEND_URL` (and optional `BACKEND_API_KEY`) `dart-define` values instead of Supabase runtime configuration

#### Scenario: Build a public web release in CI
- **WHEN** the repository's tagged release workflow builds the web client in GitHub Actions
- **THEN** it uses the same repository-owned release build entrypoint and explicit backend configuration contract as the local deployment flow
- **AND** the resulting `build/web` output can be packaged as a downloadable release artifact without requiring the public host machine
