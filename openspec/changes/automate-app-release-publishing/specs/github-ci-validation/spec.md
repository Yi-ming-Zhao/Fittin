## ADDED Requirements

### Requirement: Pull Request And Push Test Validation
The system MUST provide a repository-owned GitHub Actions workflow that runs the project's automated tests for pull requests and ordinary branch pushes before release tags are cut.

#### Scenario: Validate a pull request
- **WHEN** a contributor opens or updates a pull request against the repository
- **THEN** GitHub Actions runs the repository's configured CI workflow
- **AND** the workflow executes the documented automated test suites needed to detect application or backend regressions

#### Scenario: Validate a branch push
- **WHEN** a maintainer pushes commits to a non-tag branch
- **THEN** GitHub Actions runs the same repository-owned CI workflow
- **AND** the workflow does not attempt to publish a GitHub Release

### Requirement: CI Covers Flutter And Backend Tests
The system MUST validate both the Flutter application test suite and the Go backend test suite in ordinary CI.

#### Scenario: Execute cross-stack tests in CI
- **WHEN** the repository's CI workflow runs
- **THEN** it executes the Flutter test suite from the repository root
- **AND** it executes the Go backend test suite from the backend module
