## Context

Fittin is a local-first Flutter application with Isar on native platforms, IndexedDB on Web, a Go authentication/sync service, a rule-driven strength-program engine, and an application-local Agent runtime. The current training instance advances through a fixed flattened workout index, active sessions preserve a draft keyed to that schedule, the exercise library is a bundled read-only JSON asset, appearance palettes are a fixed enum, and analytics only consume strength logs.

The change must preserve all existing plan instances, drafts, workout logs, body data, Agent history, and authenticated sessions. It must remain responsive on 320 px phones and Web, avoid cyan/teal roles, keep all model writes behind Agent proposal confirmation, and make local interaction independent of network latency.

## Goals / Non-Goals

**Goals:**

- Make the remaining training days in the current microcycle reorderable without mutating the source template or losing progression state.
- Allow a not-yet-completed exercise slot to use another catalog movement during an active session while keeping the slot's prescribed sets and progression identity.
- Add persistent, tagged user exercise definitions and expose them to people and the Agent.
- Add typed cardio definitions, records, import previews, duplicate protection, and mixed strength/cardio trends.
- Keep authentication alive through rotating refresh sessions and tolerate offline/transient startup failures.
- Add curated and custom semantic palettes with validation, preview, Agent proposals, undo, and built-in protection.
- Simplify profile navigation and normalize every reachable mobile screen's spacing and safe-area behavior.
- Publish a signed, verifiable `v1.3.0+26` release only after migration and user-boundary checks pass.

**Non-Goals:**

- Scraping or storing credentials for proprietary running services.
- Reconstructing second-by-second GPS maps or providing medical/cardio coaching.
- Letting an Agent silently alter training data, built-in exercises, or built-in palettes.
- Replacing the existing strength progression engine or retroactively changing completed workout progression when a session exercise was substituted.
- Treating rest days as workouts; a microcycle may declare its cadence, but only training-day positions are reordered.

## Decisions

### Persist a microcycle permutation beside engine state

An active instance stores a normalized `microcycleOrder` object inside its existing `engineState`: a cycle generation, workout IDs in remaining execution order, and the template/workout-count fingerprint. The schedule resolver derives the current workout from this permutation, while `currentWorkoutIndex` continues to represent how many positions have advanced. Completing a workout consumes exactly one position; reaching the cycle boundary resets to template order. Reordering uses a compare-and-set on the instance version and is refused while an active draft exists.

This preserves engine compatibility and avoids mutating templates. Storing arbitrary "next workout" state on the home screen was rejected because it can disagree with session conclusion and other devices.

### Separate progression-slot identity from performed-movement identity

`ExerciseSessionState.id` remains the immutable plan slot used by the progression engine. `exerciseId` and `exerciseName` identify the movement actually performed. Replacing a movement updates only the latter metadata and compatible display/load behavior; completed or skipped sets cannot be replaced, and prescribed set roles, targets, IDs, and the plan-slot progression rule remain unchanged. Logs already contain both fields and therefore record the performed movement without corrupting the plan state.

### Use one versioned user-content store

Native Isar and Web IndexedDB gain one additive `user_content` store for four versioned document kinds: custom exercise, cardio activity type, cardio record, and custom theme palette. Every document carries stable ID, owner, payload, timestamps, soft-delete marker, version, sync status, and device ID. A corresponding backend table and generic sync transport avoid four near-identical persistence stacks while still enforcing a strict per-kind schema in Dart and Go.

Local-only users use an explicit local owner scope. On first login, the existing claim flow assigns these documents to the account. Device-only Agent diagnostics and API keys remain excluded.

### Define cardio fields with semantic keys and typed validation

Built-in cardio definitions describe required/optional metrics rather than rendering arbitrary forms. Running records duration plus distance or pace; incline walking records duration, speed, and incline; cycling, rowing, stair climbing, swimming, elliptical, and generic cardio each receive an appropriate bounded field set. Canonical storage uses SI units and derives pace/speed when possible. User activity types can select from the supported metric vocabulary but cannot invent executable code or unsafe units.

### Import standard files through a preview pipeline

The import service detects GPX, TCX, FIT, or CSV, parses summary records locally, normalizes units and time zones, calculates a SHA-256 source fingerprint, and produces a preview containing warnings and field mappings. No write occurs until confirmation. Existing fingerprints and a secondary start-time/duration/distance match prevent duplicates. GPX/TCX/CSV parsing is platform-neutral; the FIT decoder reads session/activity summaries and ignores unknown developer fields. Proprietary account APIs are intentionally excluded; an export from rqrun or another app is accepted when it uses one of these standard formats or a mapped CSV.

### Use rotating refresh sessions for durable login

The backend issues a short-lived access token and a random long-lived refresh token whose hash is stored in `auth_sessions`. `/v1/auth/refresh` rotates the refresh token and extends the session; `/v1/auth/session` may bootstrap a refresh token for a still-valid legacy session. The client stores both tokens in secure storage on native and browser persistence on Web, refreshes before access expiry and once after an authenticated 401, and keeps the cached user visible while offline. Only explicit sign-out, a refresh response that definitively rejects the session, or account deletion clears credentials.

### Derive custom themes from a constrained semantic draft

A custom palette stores its name, base density/typography preset, brightness, and a compact set of opaque semantic anchors. A deterministic builder derives every `FittinTheme` role. Validation rejects malformed colors, cyan/teal hues, insufficient text/surface or accent/ink contrast, indistinguishable strength/cardio colors, and invisible status colors. Built-in palettes are immutable; modifying one creates a custom copy. Agent writes follow the existing proposal, complete-diff, confirmation, conflict, audit, and undo flow.

### Normalize layout through shared page primitives

All full screens use a common page scaffold with one safe-area owner, 20 px phone gutters (16 px at 320 width), 12 px compact and 20 px normal section gaps, 8 px related-content gaps, bounded desktop width, and bottom clearance derived from navigation/keyboard insets. Profile contains only category rows and identity summary; detailed controls move to second-level screens. Tests enumerate every screen route at 320×568, 390×844, and 390×926 with large text.

## Risks / Trade-offs

- **A reordered cycle could diverge across devices** → Store the permutation on the versioned instance, compare-and-set writes, surface sync conflicts, and invalidate stale drafts.
- **Exercise substitution could misrepresent progression** → Keep the progression slot immutable, record the performed catalog ID separately, and never infer a new training max from the substitute.
- **Fitness export files vary across vendors** → Preserve import warnings, expose a generic CSV mapper, ignore unknown fields, and reject previews lacking a trustworthy start time plus duration or distance.
- **Long-lived login increases credential risk** → Store only a refresh-token hash server-side, rotate on every use, revoke the session on sign-out, rate-limit refresh, and keep native tokens in secure storage.
- **A custom palette may look acceptable on one screen but fail elsewhere** → Derive all roles from constrained anchors, run contrast/hue validation before save, and provide whole-app preview plus a one-tap reset.
- **A generic user-content table weakens schema clarity** → Enforce an enum kind and strict per-kind validation at repository and server boundaries; reject unknown kinds and oversized payloads.
- **A whole-app layout sweep can cause regressions** → Centralize spacing changes, preserve semantic keys, and use route-by-route widget plus browser visual checks instead of one broad unverified rewrite.

## Migration Plan

1. Add the native `UserContentCollection`, IndexedDB v4 `user_content` store, and backend `user_content` plus refresh-token columns without rewriting existing stores or rows.
2. Deploy the backward-compatible backend first. Existing access tokens remain valid and receive refresh credentials at the next session check.
3. Ship the client with fallback to legacy fixed workout order, bundled exercise catalog, existing palette key, and cached user records when new fields are absent.
4. Verify upgrade from v1.2.1 with an existing active plan, active draft, workout/body history, Agent history, selected palette, and login.
5. Roll back the client/Web artifacts independently if needed; new additive stores and backend columns remain harmless to v1.2.1. Do not advance `latest.json` until the signed APK and public Web pass smoke checks.

## Open Questions

- Direct proprietary rqrun account import remains dependent on a documented public export or API; v1.3.0 guarantees standards-based file import and generic CSV mapping instead of credential scraping.
