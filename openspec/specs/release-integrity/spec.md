## Purpose

Define verifiable first-party mobile releases and cache-correct Web update activation.

## Requirements

### Requirement: Verifiable First-Party Releases
The system MUST publish update metadata and artifacts from a first-party HTTPS endpoint and MUST reject activation of a deployment whose readiness, version, bootstrap, or artifact probes fail.

#### Scenario: Deployment probe fails
- **WHEN** a staged release does not return the expected version or required assets
- **THEN** deployment keeps or restores the previous active release.

### Requirement: Cache-Correct Entrypoints
Mutable Web entrypoints and release metadata MUST revalidate, while fingerprinted static assets MAY be cached immutably.

#### Scenario: New Web version is deployed
- **WHEN** the active release symlink changes
- **THEN** a returning browser obtains current bootstrap and version metadata without waiting for an old immutable cache lifetime.

### Requirement: Signed Agent release publication
The Agent release SHALL use version `1.1.0+21`, the stable Android signer, immutable GitHub release assets and checksums, the first-party Android update manifest, and the directly hosted Web deployment.

#### Scenario: Existing Android user upgrades
- **WHEN** a user installs the v1.1.0 APK over v1.0.13
- **THEN** Android accepts the signer, existing Fittin data remains available, and the application reports version 1.1.0

#### Scenario: Release verification fails
- **WHEN** backend, Web, Android upgrade, checksum, or real-provider canary verification fails
- **THEN** first-party `latest.json` is not advanced and the affected deployable is rolled back or superseded
