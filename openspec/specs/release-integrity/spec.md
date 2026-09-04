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

### Requirement: Audited patch release publication
The audited layout and stability patch MUST publish application version `1.2.1+25` and tag `v1.2.1` using the stable Android signer, immutable release checksums, the directly hosted Web deployment and first-party Android update metadata. Public metadata MUST remain on the prior verified version until the signed upgrade, Web bootstrap and public readiness checks pass.

#### Scenario: Existing Android user upgrades from v1.2.0
- **WHEN** the signed v1.2.1 APK is installed over the public v1.2.0 application
- **THEN** Android accepts the signer and preserves existing local data, authentication and configuration
- **AND** the application reports version 1.2.1.

#### Scenario: A release gate fails
- **WHEN** CI, signature, checksum, install-over, Web bootstrap or public readiness verification fails
- **THEN** first-party `latest.json` is not advanced
- **AND** the failed deployable remains staged or the previous Web symlink stays active.

### Requirement: Flexible training and cardio release publication
The `v1.3.0+26` release SHALL be published only after direct domain, storage migration, authentication refresh, Agent mutation, Flutter analyze/test, Android, iOS no-codesign, Web, Go, OpenSpec, and route-complete visual checks pass.

#### Scenario: Existing Android user upgrades from v1.2.1
- **WHEN** the stable signed `v1.3.0` APK is installed over v1.2.1
- **THEN** the package signature and first-install identity remain compatible and plans, progress, logs, body data, Agent history, selected appearance, and authenticated session remain available.

#### Scenario: Public boundary check fails
- **WHEN** Web, ready endpoint, signed APK hash, update manifest, or authenticated refresh smoke testing fails
- **THEN** the corresponding deployment is rolled back and `latest.json` is not advanced.
