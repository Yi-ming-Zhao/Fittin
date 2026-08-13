## Purpose

Define how the Flutter Web client and project-owned backend are published through a stable Alibaba Cloud HTTPS origin without Cloudflare Tunnel.
## Requirements
### Requirement: Public Web Release Build
The system MUST provide a repeatable release build flow for the Flutter Web client that is suitable for public serving at the selected production hostname, preferring `https://fittin.yimelo.cc/` and using `https://fittin.hammerscholar.net/` when the preferred DNS zone cannot be updated, and for packaging the same build output as a versioned release artifact in CI.

#### Scenario: Build a public web release
- **WHEN** a maintainer prepares a new public web deployment
- **THEN** the documented build flow produces a Flutter Web release build from the repository
- **AND** the build flow uses an explicit same-origin `/api` `BACKEND_URL` (and optional `BACKEND_API_KEY`) instead of Supabase runtime configuration.

#### Scenario: Build a public web release in CI
- **WHEN** the repository's tagged release workflow builds the web client in GitHub Actions
- **THEN** it uses the same repository-owned release build entrypoint and explicit backend configuration contract as the local deployment flow
- **AND** the resulting `build/web` output can be packaged as a downloadable release artifact without requiring the public host machine.

### Requirement: Local Static Hosting Contract
The system MUST define an Alibaba Cloud static hosting contract for serving the generated `build/web` output directly from the public ECS nginx instance.

#### Scenario: Serve build output on Alibaba Cloud
- **WHEN** a maintainer follows the deployment instructions
- **THEN** the generated `build/web` output is uploaded to a versioned ECS directory
- **AND** nginx serves the selected release with single-page application fallback and explicit cache behavior.

### Requirement: Public Subdomain Routing
The system MUST define how the selected Fittin hostname resolves directly to Alibaba Cloud and reaches nginx without Cloudflare Tunnel.

#### Scenario: Reach the published web app from the public subdomain
- **WHEN** the deployment is active and a user opens the selected HTTPS hostname
- **THEN** DNS resolves to the Alibaba Cloud public entrypoint
- **AND** nginx returns the Flutter Web app over a valid HTTPS connection without a Cloudflare Tunnel hop.

### Requirement: Deployment Verification And Rollback
The system MUST document and support verification and rollback for the Alibaba Cloud deployment.

#### Scenario: Verify a newly published release
- **WHEN** a maintainer publishes a new web release
- **THEN** checks cover first-load rendering, refresh behavior, core asset loading, backend health, and phone-sized interaction
- **AND** nginx configuration is tested before reload.

#### Scenario: Roll back a failed release
- **WHEN** public validation fails after activation
- **THEN** the maintainer can restore the previous versioned Web bundle and nginx configuration without changing backend user data.

### Requirement: Public Backend Endpoint Availability
The system MUST expose the project-owned backend on `241-dhg` through an NPS TCP path terminating at the Alibaba Cloud nginx `/api/` route.

#### Scenario: Validate public backend reachability
- **WHEN** a maintainer completes the 241 NPS mapping and nginx configuration
- **THEN** a public request to `/api/healthz` reaches the Fittin backend on `241-dhg`
- **AND** the response succeeds without a Cloudflare Tunnel hop.

### Requirement: Atomic Verified Web Activation
The deployment process MUST stage builds, run same-origin health, version, and asset probes, activate atomically, and restore the prior release if post-activation verification fails.

#### Scenario: Activated build serves stale metadata
- **WHEN** post-activation version metadata does not match the intended release
- **THEN** the script rolls the active symlink back and reports failure.

### Requirement: Browser Security Policy
The public HTTPS service MUST send transport, content, referrer, and permissions policies compatible with the Flutter application.

#### Scenario: Public page is requested
- **WHEN** a browser loads the application over HTTPS
- **THEN** the response includes the configured security headers and excludes obsolete permissive CORS origins.

### Requirement: Public Agent streaming route
The production nginx configuration SHALL give the exact Agent endpoint authenticated API routing, disabled proxy buffering/cache, bounded request size, a dedicated rate limit, and a streaming-compatible read timeout.

#### Scenario: Public streaming response
- **WHEN** the public Web client invokes the Agent endpoint
- **THEN** partial SSE output reaches the browser without waiting for the complete model response and existing static cache rules remain unchanged
