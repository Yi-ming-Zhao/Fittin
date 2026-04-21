## ADDED Requirements

### Requirement: Tag-Triggered GitHub Release Publication
The system MUST provide a repository-owned GitHub Actions workflow that creates a GitHub Release when a maintainer pushes a version tag for the app.

#### Scenario: Publish a tagged release
- **WHEN** a maintainer pushes a Git tag matching the repository's release tag pattern
- **THEN** GitHub Actions starts a release workflow for that tag
- **AND** the workflow creates or updates a GitHub Release associated with the same tag

### Requirement: Release Artifacts Are Built And Uploaded
The system MUST build versioned release artifacts for the app and upload them to the GitHub Release created by the workflow.

#### Scenario: Build and attach release assets
- **WHEN** the tagged release workflow runs successfully
- **THEN** it produces an Android APK artifact, an Android app bundle artifact, and a packaged Flutter Web artifact from the tagged source
- **AND** the workflow uploads those build outputs to the GitHub Release as downloadable assets

### Requirement: Release Builds Use Explicit Runtime Configuration
The system MUST build release artifacts with explicit repository-owned runtime configuration instead of depending on ad hoc local machine state.

#### Scenario: Build the web artifact in CI
- **WHEN** the release workflow builds the Flutter Web artifact
- **THEN** it uses explicit `BACKEND_URL` configuration for the build
- **AND** the release summary records which backend URL was baked into the web artifact

### Requirement: Android Release Signing Contract Is Documented
The system MUST define how Android release signing is resolved during automated publication so maintainers can understand whether the resulting artifacts use fallback signing or repository-provided signing material.

#### Scenario: Release build runs with current signing configuration
- **WHEN** the release workflow builds Android artifacts
- **THEN** it follows the repository's documented Android signing configuration contract
- **AND** the documentation explains how to switch from fallback signing to repository-secret-backed signing
