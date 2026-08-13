## Why

Fittin already stores rich training plans, workout history, PRs, and body metrics locally, but users must navigate separate screens and manually interpret or edit that data. An in-app, bring-your-own-key Agent can turn those existing capabilities into a conversational coaching and data-management surface without handing model credentials to Fittin permanently.

## What Changes

- Add a sixth `AI` tab with streaming conversation, tool activity, structured insight cards, mutation previews, confirmation, rejection, action history, and undo.
- Add per-device OpenAI-compatible provider configuration for Base URL, API key, and model ID, with a real tool-calling connection test.
- Add a bounded local Agent harness that exposes read tools for plans, training history, PRs, analytics, and body trends and proposal-only write tools for plans, workout logs, and body metrics.
- Require an explicit semantic diff and confirmation before every write; use version preconditions, idempotency keys, atomic local commits, synced inverse writes, and local audit snapshots.
- Preserve active training progress when revising the current plan by forking the template and migrating compatible instance state.
- Add an authenticated, stateless Web relay for OpenAI-compatible Chat Completions with streaming, SSRF protection, rate limits, and secret redaction; native clients continue to connect directly.
- Persist Agent conversations and action records only on the current device, while keeping API keys out of ordinary preferences, cloud sync, logs, and crash text.
- Publish the compatible Android and Web release as `v1.1.0+21`; validate iOS with an unsigned build.

## Capabilities

### New Capabilities

- `in-app-agent-harness`: Provider configuration, streaming orchestration, tool execution, bounded runs, conversation persistence, and the Agent user experience.
- `agent-data-mutations`: Read tools, proposal-only mutations, active-plan migration, concurrency checks, audit history, and undo for structured training data.
- `agent-web-relay`: Authenticated stateless model forwarding, streaming behavior, SSRF controls, rate limits, and credential handling for Web.

### Modified Capabilities

- `glass-bottom-nav`: Expand the adaptive navigation contract from five tabs to six while preserving usable labels and touch targets on narrow phones.
- `profile-screen`: Add the Agent provider and privacy configuration entry.
- `local-datastore-schema`: Add device-local Agent conversation/action stores and a non-destructive IndexedDB schema upgrade.
- `plan-template-editor`: Reuse template validation and safe fork behavior for Agent-proposed plan revisions.
- `editable-workout-history`: Extend logged-workout editing and deletion through confirmed Agent proposals with explicit progression effects.
- `body-metrics-tracker`: Extend validated body-metric creation, editing, and deletion through confirmed Agent proposals.
- `custom-backend-runtime`: Add the authenticated model relay route and outbound request safety contract.
- `web-public-deployment`: Configure unbuffered, bounded streaming for the Agent relay without weakening existing Web caching and security behavior.
- `release-integrity`: Publish and verify the signed `v1.1.0+21` Android release and public Web build.

## Impact

- Flutter domain/application/data/presentation layers gain Agent models, provider clients, tool registries, mutation coordination, device-local persistence, settings, and the sixth tab.
- Native Isar schemas and Web IndexedDB stores advance additively; structured training mutations continue to use the existing sync queue.
- The Go backend and Alibaba Cloud nginx configuration gain one authenticated streaming relay route with no database migration.
- CI and release verification expand to Agent unit/widget/backend tests, Web phone-size regression, Android upgrade verification, and an unsigned iOS build.
