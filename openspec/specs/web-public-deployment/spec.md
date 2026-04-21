## Purpose

Define how the Flutter Web client is published to a stable public subdomain using a repeatable release build flow, local static hosting, and Cloudflare Tunnel routing.
## Requirements
### Requirement: Public Web Release Build
The system MUST provide a repeatable release build flow for the Flutter Web client that is suitable for public serving at `https://fittin.yimelo.cc/`.

#### Scenario: Build a public web release
- **WHEN** a maintainer prepares a new public web deployment
- **THEN** the documented build flow produces a Flutter Web release build from the repository
- **AND** the build flow uses explicit `BACKEND_URL` (and optional `BACKEND_API_KEY`) `dart-define` values instead of Supabase runtime configuration.

### Requirement: Local Static Hosting Contract
The system MUST define a project-owned local static hosting contract for serving the generated `build/web` output on the same machine that runs the Cloudflare Tunnel.

#### Scenario: Serve build output locally
- **WHEN** a maintainer follows the deployment instructions on the host machine
- **THEN** the generated `build/web` output is served by a documented local static server configuration
- **AND** the documented local origin is stable enough for Cloudflare Tunnel to target without ad hoc command discovery

### Requirement: Public Subdomain Routing
The system MUST define how `fittin.yimelo.cc` routes through Cloudflare Tunnel to the local static hosting origin.

#### Scenario: Reach the published web app from the public subdomain
- **WHEN** the deployment is active and a user opens `https://fittin.yimelo.cc/`
- **THEN** Cloudflare Tunnel forwards the request to the documented local static hosting origin
- **AND** the user reaches the Flutter Web app over HTTPS on the subdomain

### Requirement: Deployment Verification And Rollback
The system MUST document verification and rollback steps for the public web deployment so updates can be shipped and reverted predictably.

#### Scenario: Verify a newly published release
- **WHEN** a maintainer publishes a new web release
- **THEN** the deployment documentation lists concrete smoke checks for first-load rendering, refresh behavior, and backend-backed runtime configuration
- **AND** the documentation lists how to restore the previous published build or service state if the new release is not acceptable

### Requirement: Public Backend Endpoint Availability
The system MUST document and support a stable public backend endpoint that can be reached through a dedicated tunnel-backed hostname during web deployment and validation.

#### Scenario: Validate public backend reachability
- **WHEN** a maintainer completes backend tunnel and DNS configuration for the public environment
- **THEN** the configured public backend hostname reaches the local backend origin instead of an unrelated service
- **AND** a public request to `/healthz` succeeds through the tunnel

