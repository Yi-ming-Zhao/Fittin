## ADDED Requirements

### Requirement: Recoverable Web Engine Startup
The public Web launch surface MUST be removed when Flutter renders its first frame and MUST provide a visible reload action when an engine or asset failure prevents that handoff within a bounded startup window.

#### Scenario: Flutter cannot render its first frame
- **WHEN** the Web engine raises a bootstrap or WebAssembly error, or no first frame is produced within the bounded startup window
- **THEN** the launch surface stops representing startup as indefinitely in progress
- **AND** it displays a localized failure message and a reload action.

#### Scenario: Flutter finishes after a slow first load
- **WHEN** Flutter emits its first frame after the recovery message has appeared
- **THEN** the launch surface is still removed and the application remains usable.

#### Scenario: Existing browser cached the invalid WebAssembly response
- **WHEN** an existing Service Worker cache contains CanvasKit bytes with the former invalid response media type
- **THEN** the launch loader bypasses stale HTTP and Service Worker entries, validates the corrected media type, and overwrites only the canonical cached CanvasKit full and Chromium responses once before bootstrap
- **AND** authentication, browser-local training data, and user preferences remain intact.

## MODIFIED Requirements

### Requirement: Local Static Hosting Contract
The system MUST define an Alibaba Cloud static hosting contract for serving the generated `build/web` output directly from the public ECS nginx instance, including browser-executable media types for Flutter engine assets.

#### Scenario: Serve build output on Alibaba Cloud
- **WHEN** a maintainer follows the deployment instructions
- **THEN** the generated `build/web` output is uploaded to a versioned ECS directory
- **AND** nginx serves the selected release with single-page application fallback and explicit cache behavior
- **AND** every `.wasm` response uses the `application/wasm` media type while preserving the intended cache and security headers.

### Requirement: Deployment Verification And Rollback
The system MUST document and support verification and rollback for the Alibaba Cloud deployment, including browser-level proof that the Flutter engine renders rather than only asset-level HTTP success.

#### Scenario: Verify a newly published release
- **WHEN** a maintainer publishes a new web release
- **THEN** checks cover first-load rendering, refresh behavior, core asset loading, WebAssembly response media type, backend health, and phone-sized interaction
- **AND** the browser console has no fatal engine or WebAssembly errors
- **AND** nginx configuration is tested before reload.

#### Scenario: Roll back a failed release
- **WHEN** public validation fails after activation
- **THEN** the maintainer can restore the previous versioned Web bundle and nginx configuration without changing backend user data.
