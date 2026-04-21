## Context

The repository already has a working manual build and deployment flow for the custom backend and Flutter Web frontend, but releases are not versioned or published automatically on GitHub. The current Android Gradle configuration still falls back to the debug signing config for release builds, and the current web release flow depends on the project wrapper script so the build gets the correct `BACKEND_URL` and Isar web schema normalization.

This change needs a release pipeline that is independent from the self-hosted deployment machine. GitHub-hosted runners are a better fit than the current deployment host because GitHub Releases are produced in GitHub, while the deployed public web and backend remain on the existing machine behind Cloudflare Tunnel.

## Goals / Non-Goals

**Goals:**
- Run repository tests automatically on pull requests and ordinary pushes.
- Trigger a release workflow from version tags.
- Build versioned Android and web artifacts in GitHub Actions.
- Publish those artifacts to a GitHub Release automatically.
- Keep the CI web build aligned with the existing `BACKEND_URL`-based runtime contract.
- Allow future migration from debug signing to production signing without redesigning the workflow.

**Non-Goals:**
- Automatically deploy newly built artifacts to the public server.
- Introduce iOS/macOS/Windows/Linux desktop release automation in this change.
- Change the current public hosting topology for `fittin.yimelo.cc` or `api.yimelo.cc`.
- Fully solve production Android keystore management beyond defining the repository contract and workflow hooks.

## Decisions

### Use tag-triggered GitHub Actions releases

The workflow will run on pushes of tags matching `v*`. The tag is the stable release intent, avoids publishing a GitHub Release on every `main` push, and gives the project an explicit version boundary.

Alternative considered:
- Trigger on every push to `main`: rejected because it would spam releases and blur the difference between CI validation and actual versioned publication.

### Separate ordinary CI from release publication

The repository will use a separate `ci.yml` workflow for `pull_request` and non-tag `push` events. That workflow will run the Flutter and backend test suites without attempting release packaging or GitHub Release publication. This keeps fast feedback on code quality while keeping versioned artifact publication intentionally tied to tags.

Alternative considered:
- Fold tests into `release.yml` only: rejected because it would delay feedback until tag creation and would not protect ordinary pull requests.

### Build on GitHub-hosted runners, not the deployment machine

The release workflow will use GitHub-hosted Ubuntu runners with Flutter and Java installed during the job. This keeps release publication reproducible even if the deployment host is unavailable, and it avoids coupling GitHub Releases to local systemd/cloudflared state.

Alternative considered:
- Self-hosted runner on the deployment machine: rejected for release publication because it would couple release creation to the uptime and local state of the public hosting machine.

### Reuse repository-owned build entrypoints where that preserves runtime parity

The web artifact will be built through `tool/build_web_release.sh` so CI and manual public deployment share the same `BACKEND_URL` contract and Isar web-safe normalization. Android artifacts will be built in CI with explicit version metadata derived from the Git tag.

Alternative considered:
- Re-implement the web build inline inside the workflow: rejected because it would duplicate repo logic and increase drift risk.

### Make Android release signing configurable, with safe fallback behavior

The Android project will support a repository-local `android/key.properties` contract when CI secrets are provided, but it will continue to fall back to the existing debug signing config when those secrets are absent. This preserves immediate automation while making room for future production signing without changing the workflow shape.

Alternative considered:
- Block all release publication until production signing secrets exist: rejected because it would delay release automation entirely even though APK/AAB generation already works with the current release config.

### Publish release assets directly from the workflow

The workflow will package and upload:
- release APK
- release AAB
- zipped `build/web`

The GitHub Release body should summarize the tag, artifact list, and the backend URL baked into the web bundle.

Alternative considered:
- Store only Actions artifacts and require manual release creation: rejected because the user explicitly wants automated GitHub Releases.

## Risks / Trade-offs

- [Debug-signed Android release fallback is not store-ready] → Document the current signing behavior clearly and make secret-backed signing easy to enable later.
- [GitHub-hosted runner upgrades can break Flutter/Android builds] → Pin major action versions, set the Flutter channel/version explicitly, and reuse repo scripts where possible.
- [Release tags could point at broken code] → Keep ordinary test/verification workflows separate and document that release tags should be created only after validation.
- [Wrong backend URL baked into web artifact] → Require `BACKEND_URL` from repository variables or secrets and print the chosen value in the release summary.

## Migration Plan

1. Add the OpenSpec change artifacts defining the release behavior.
2. Update Android signing config so CI can optionally use `android/key.properties`.
3. Add a GitHub Actions workflow for tag-triggered builds and release publication.
4. Add a GitHub Actions CI workflow for pull requests and ordinary pushes.
5. Add documentation for required repository variables/secrets and the tagging flow.
6. Validate the workflow syntax locally as far as practical and verify OpenSpec validation passes.
7. After merge, configure repository variables/secrets in GitHub and create the first test tag.

Rollback:
- Delete or disable the workflow file if release automation misbehaves.
- Remove the new Android signing-property logic if it causes build regressions.
- Fall back to the existing manual build and manual GitHub release process.

## Open Questions

- Whether future releases should attach SHA256 checksums and autogenerated release notes.
- Whether prerelease tags such as `v1.2.0-rc1` should map to GitHub prereleases in a later change.
