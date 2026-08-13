## ADDED Requirements

### Requirement: Public Agent streaming route
The production nginx configuration SHALL give the exact Agent endpoint authenticated API routing, disabled proxy buffering/cache, bounded request size, a dedicated rate limit, and a streaming-compatible read timeout.

#### Scenario: Public streaming response
- **WHEN** the public Web client invokes the Agent endpoint
- **THEN** partial SSE output reaches the browser without waiting for the complete model response and existing static cache rules remain unchanged
