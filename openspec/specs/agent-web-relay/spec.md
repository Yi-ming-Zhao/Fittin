# agent-web-relay Specification

## Purpose
Define the authenticated, stateless, and network-safe Web relay for OpenAI-compatible Agent requests.

## Requirements

### Requirement: Authenticated stateless relay
The backend SHALL expose `POST /v1/agent/chat-completions` only to authenticated Fittin users and SHALL neither persist nor log provider credentials, request bodies, or model responses.

#### Scenario: Anonymous relay request
- **WHEN** a request omits a valid Fittin bearer session
- **THEN** the backend returns 401 before resolving or contacting the provider

### Requirement: Public HTTPS target enforcement
The relay SHALL accept only HTTPS provider Base URLs without userinfo, query, or fragment, SHALL resolve and dial only public addresses, and SHALL disable redirects and environment proxies.

#### Scenario: Private target is requested
- **WHEN** a provider hostname or address resolves to a loopback, private, link-local, multicast, documentation, or otherwise reserved network
- **THEN** the relay rejects the request without opening an upstream connection

#### Scenario: Provider redirects
- **WHEN** the upstream provider returns a redirect
- **THEN** the relay refuses the redirect instead of following it

### Requirement: Bounded streaming forwarding
The relay SHALL cap request bytes, streamed response bytes, duration, per-user concurrency, and user/IP request rate while preserving JSON and event-stream response delivery.

#### Scenario: Streaming provider response
- **WHEN** an allowed provider emits multiple SSE chunks
- **THEN** the relay flushes chunks progressively and cancels the upstream request when the client disconnects

### Requirement: Secret-safe errors
Relay error responses SHALL use stable codes and SHALL not contain provider API keys, authorization headers, raw request payloads, or internal network addresses.

#### Scenario: Provider authentication fails
- **WHEN** the provider returns an authentication error
- **THEN** the user receives a bounded sanitized error and the credential is absent from logs and response text
