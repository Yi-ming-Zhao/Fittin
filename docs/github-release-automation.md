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

That tag creates or updates a GitHub Release for the same version and uploads release assets.

## Standard CI

The ordinary CI workflow runs on:

- pull requests
- pushes to normal branches such as `main`, `feature/**`, `fix/**`, `chore/**`, `refactor/**`, and `docs/**`

It does not publish release assets. It only validates the repository before you cut a release tag.

Current CI coverage:

- `tool/run_ci_flutter_tests.sh`
- `cd backend && go test ./...`

The Flutter CI suite is intentionally a curated stable subset of the repository test suite. It currently covers the application layer, data layer, and selected domain tests that pass consistently on Linux GitHub runners. This keeps PR validation green while the remaining widget and template-validation tests are still being repaired.

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
https://api.yimelo.cc
```

The generated GitHub Release notes include the backend URL baked into the web bundle.

## Android Signing Behavior

Current behavior:

- if GitHub secrets for Android signing are configured, the workflow writes `android/key.properties` and uses that keystore for release builds
- if those secrets are absent, Android release builds fall back to the existing debug signing config so the workflow can still publish artifacts

That fallback is useful for internal distribution and validating the pipeline, but it is not the final production signing setup you would want for store submission.

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
3. Create and push the release tag.
4. Wait for the `Publish Release` workflow to finish.
5. Open the GitHub Release page and verify the uploaded assets and release notes.

## Tagged Release Flow

1. Make sure the code on `main` is the version you want to release.
2. Update `pubspec.yaml` version if you want the app metadata to match the tag.
3. Create and push the tag.
4. Wait for the `Publish Release` workflow to finish.
5. Open the GitHub Release page and verify the uploaded assets and release notes.

## Notes

- The workflow uses GitHub-hosted runners. It does not deploy to the public Cloudflare Tunnel host.
- Public deployment of the web app remains the separate flow documented in [docs/web-public-deployment.md](/data/zhaoyiming/Fittin/docs/web-public-deployment.md).
- The release workflow uses `tool/build_web_release.sh` so CI and manual web releases stay aligned.
