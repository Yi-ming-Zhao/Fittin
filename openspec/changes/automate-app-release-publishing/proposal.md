## Why

The project can now be built and published manually, but it still lacks a repeatable release pipeline that turns a tagged version into downloadable app artifacts on GitHub. That gap makes versioned distribution brittle, slows releases, and leaves no canonical release record for APK, AAB, and web build outputs.

## What Changes

- Add a GitHub Actions release workflow that triggers from version tags and creates a GitHub Release automatically.
- Add a standard GitHub Actions CI workflow for pull requests and branch pushes so tests run before maintainers cut a release tag.
- Build Android release artifacts in CI and upload them to the GitHub Release as versioned assets.
- Build the Flutter Web release bundle in CI and upload a packaged web artifact to the same GitHub Release.
- Document the required repository secrets, version-tagging flow, and release verification steps.
- Add repository-owned helper scripts/config so the CI release build uses the same backend runtime contract as the manual deployment flow.

## Capabilities

### New Capabilities
- `github-app-release-publishing`: Define the tagged GitHub Actions workflow that builds release artifacts and publishes a GitHub Release for the app.
- `github-ci-validation`: Define the pull-request and push-triggered GitHub Actions workflow that runs the repository test suite before release publication.

### Modified Capabilities
- `web-public-deployment`: Clarify that the public web release build can also be produced in CI as a versioned artifact using the same explicit backend configuration contract.

## Impact

- Affected code: `.github/workflows/`, release helper scripts, and deployment/release documentation.
- Affected systems: GitHub Actions, GitHub Releases, Flutter build toolchain, Android signing inputs, and current web build configuration.
- Dependencies: Flutter SDK in CI, Java/Android toolchain, and GitHub repository secrets for any signed Android release flow.
