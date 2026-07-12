## MODIFIED Requirements

### Requirement: Public Web Release Build
The system MUST provide a repeatable release build flow for the Flutter Web client that is suitable for public serving at the selected production hostname, preferring `https://fittin.yimelo.cc/` and using `https://fittin.hammerscholar.net/` only when the preferred DNS zone cannot be updated.

#### Scenario: Build a public web release
- **WHEN** a maintainer prepares a new public web deployment
- **THEN** the documented build flow produces a Flutter Web release build from the repository
- **AND** the build flow uses an explicit same-origin `/api` `BACKEND_URL` (and optional `BACKEND_API_KEY`) instead of Supabase runtime configuration.

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

### Requirement: Public Backend Endpoint Availability
The system MUST expose the project-owned backend on `241-dhg` through an NPS TCP path terminating at the Alibaba Cloud nginx `/api/` route.

#### Scenario: Validate public backend reachability
- **WHEN** a maintainer completes the 241 NPS mapping and nginx configuration
- **THEN** a public request to `/api/healthz` reaches the Fittin backend on `241-dhg`
- **AND** the response succeeds without a Cloudflare Tunnel hop.

### Requirement: Deployment Verification And Rollback
The system MUST document and support verification and rollback for the Alibaba Cloud deployment.

#### Scenario: Verify a newly published release
- **WHEN** a maintainer publishes a new web release
- **THEN** checks cover first-load rendering, refresh behavior, core asset loading, backend health, and phone-sized interaction
- **AND** nginx configuration is tested before reload.

#### Scenario: Roll back a failed release
- **WHEN** public validation fails after activation
- **THEN** the maintainer can restore the previous versioned Web bundle and nginx configuration without changing backend user data.
