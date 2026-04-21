## 1. Release Workflow

- [x] 1.1 Add a tag-triggered GitHub Actions workflow that builds Android and web release artifacts
- [x] 1.2 Package versioned release assets and publish them to a GitHub Release
- [x] 1.3 Ensure the workflow records the backend URL used for the web artifact

## 2. Ordinary CI Workflow

- [x] 2.1 Add a pull-request and push-triggered GitHub Actions workflow that runs Flutter and backend tests
- [x] 2.2 Keep CI and release workflows separated so ordinary CI never publishes a GitHub Release

## 3. Android Release Configuration

- [x] 3.1 Update Android Gradle signing configuration to support optional `android/key.properties`
- [x] 3.2 Keep fallback release builds working when production signing secrets are not configured

## 4. Documentation

- [x] 4.1 Document the standard CI workflow and how it relates to tagged release publication
- [x] 4.2 Document the tagging flow, required GitHub variables/secrets, and release asset outputs
- [x] 4.3 Document the current Android signing behavior and how to switch to secret-backed signing

## 5. Verification

- [x] 5.1 Run the Flutter test suite locally to mirror the CI workflow
- [x] 5.2 Run the Go backend test suite locally to mirror the CI workflow
- [x] 5.3 Validate both GitHub Actions workflow YAML files and OpenSpec change consistency
