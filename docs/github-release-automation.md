# GitHub Release Automation

This repository can publish versioned app releases from GitHub Actions.

It also uses a separate ordinary CI workflow for pull requests and branch pushes:

- `.github/workflows/ci.yml`

## Trigger

The workflow lives at:

- `.github/workflows/release.yml`

It runs when you push a tag matching:

```text
v*
```

Example:

```bash
git tag v1.2.0
git push origin v1.2.0
```

That tag creates a new GitHub Release for the same version and uploads release assets. Existing releases are never overwritten.

## Standard CI

The ordinary CI workflow runs on:

- pull requests
- pushes to normal branches such as `main`, `feature/**`, `fix/**`, `chore/**`, `refactor/**`, and `docs/**`

It does not publish release assets. It only validates the repository before you cut a release tag.

Current CI coverage:

- `flutter analyze --no-pub`
- `tool/run_ci_flutter_tests.sh`
- `cd backend && go test ./...`

The Flutter CI suite is intentionally a curated stable subset of the repository test suite. It covers the application layer, data layer, selected domain tests, and the About, settings, and theme-palette widget tests that pass consistently on Linux GitHub runners.

## Release Assets

Each tagged release uploads:

- `fittin-vX.Y.Z-android.apk`
- `fittin-vX.Y.Z-android.aab`
- `fittin-vX.Y.Z-web.zip`
- `fittin-vX.Y.Z-sha256.txt`

The web archive contains the built `build/web` directory and uses the same release build entrypoint as the manual public deployment flow.

## Runtime Configuration

The workflow builds the web artifact with:

- repository variable `RELEASE_BACKEND_URL`
- optional repository secret `RELEASE_BACKEND_API_KEY`

If `RELEASE_BACKEND_URL` is not configured, the workflow falls back to:

```text
https://fittin.hammerscholar.net/api
```

The generated GitHub Release notes include the backend URL baked into the web bundle.

## Android Signing Behavior

Current behavior:

- all four Android signing secrets are required; a tagged build fails if any one is absent
- the workflow verifies the keystore and built APK against Fittin's fixed release certificate SHA-256
- there is no debug-signing fallback and an existing GitHub Release cannot be replaced

### Required secrets for repository-backed signing

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

Expected `key.properties` shape:

```properties
storePassword=...
keyPassword=...
keyAlias=...
storeFile=release-keystore.jks
```

To prepare `ANDROID_KEYSTORE_BASE64` locally:

```bash
base64 -w 0 /path/to/your/release-keystore.jks
```

Recommended sequence:

1. Push your branch and let ordinary CI pass.
2. Merge or fast-forward the code you want to release.
3. Increment both parts of `version: X.Y.Z+N` in `pubspec.yaml`; `N` is the Android `versionCode` and must never decrease or be reused.
4. Create and push the matching release tag.
5. Wait for the `Publish Release` workflow to finish.
6. Open the GitHub Release page and verify the uploaded assets and release notes.

Repository administrators should also protect `refs/tags/v*` from updates and deletion with a GitHub ruleset. The workflow re-checks the remote tag before publishing, but repository-level tag protection removes the race entirely.

### One-time migration for older Android installs

`v1.0.6` is the first build using the fixed release certificate. Devices with `v1.0.5` or earlier must first sync or back up their data, uninstall the old app, and install `v1.0.6` once. Releases after that can update in place as long as the signing certificate remains unchanged and the build number increases.

## Tagged Release Flow

1. Make sure the code on `main` is the version you want to release.
2. Increment `pubspec.yaml` to the new version and a larger build number.
3. Create and push the tag.
4. Wait for the `Publish Release` workflow to finish.
5. Open the GitHub Release page and verify the uploaded assets and release notes.

## Notes

- The workflow uses GitHub-hosted runners. It does not deploy to the public Cloudflare Tunnel host.
- Public deployment of the web app remains the separate flow documented in [docs/web-public-deployment.md](web-public-deployment.md).
- The release workflow uses `tool/build_web_release.sh` so CI and manual web releases stay aligned.
