## Context

The active-session screen already owns all set mutations through `ActiveSessionNotifier`, persists drafts, and uses the shared dark dashboard primitives. Its UI is a single vertically composed logger with long-press exact-weight entry and a numeric plate breakdown. UI settings are stored with `SharedPreferences`. Production Web currently builds against `https://api.yimelo.cc`, serves the bundle on the app host, and exposes both origins through Cloudflare Tunnel.

This change crosses Flutter presentation, persisted session state, settings, generated model serialization, deployment scripts, Alibaba Cloud nginx/NPS configuration, DNS, and CI/public validation. The primary viewport is a narrow, tall phone; mouse and keyboard users still need discoverable controls.

## Goals / Non-Goals

**Goals:**

- Make one physical-feeling current-set card the workout's focal point, with a live stack preview of upcoming sets.
- Support left-swipe completion and down-swipe cancellation with clear motion, thresholds, and accessible button fallbacks.
- Preserve the traditional logger behind a persisted settings choice.
- Make exact weight editing discoverable by tap and carry the latest explicit weight choice through later unresolved sets of the same exercise.
- Publish the frontend and backend through Alibaba Cloud nginx/NPS with DNS and HTTPS, without Cloudflare Tunnel.
- Verify behavior with provider/widget tests, phone-sized browser checks, CI, and public smoke checks.

**Non-Goals:**

- Redesign unrelated screens or change workout progression formulas.
- Add a rest timer, social gestures, or a third recording mode.
- Change target prescriptions when the user edits actual working weight.
- Commit passwords, API keys, tunnel tokens, certificates, or generated local credential files.

## Decisions

### Store the recording mode as a small UI preference

Add a `WorkoutRecordingMode` enum and `StateNotifier` backed by `SharedPreferences`, defaulting to card mode for the redesigned experience. The active screen branches only at the current-set interaction body while sharing the header, exercise context, unit tools, progress, and conclude flow. This avoids duplicating session logic or maintaining two screens.

Alternative considered: make the card logger a separate route. Rejected because route duplication would split state restoration, exercise switching, and conclusion behavior.

### Represent cancellation explicitly in the active-session draft

Add a backwards-compatible `isSkipped`/cancelled flag with a default of `false` to session sets. A left swipe marks the card complete; a down swipe marks it skipped and advances to the next unresolved set. Skipped sets remain incomplete in the final workout result and therefore cannot falsely satisfy progression rules. Resolution helpers treat either completed or skipped sets as no longer current.

Alternative considered: reset the card and keep it current. Rejected because that does not match the requested card-deck gesture where a downward-cancelled card leaves the stack.

### Use a custom two-axis gesture card instead of nested dismissibles

A stateful card tracks pointer delta and applies real-time translation, rotation, tint, label opacity, and back-card expansion. On release, horizontal-left and vertical-down thresholds trigger their respective transitions; all other directions spring back. Centered completion and cancellation controls expose the same actions to keyboard, assistive technology, and users who do not prefer gestures.

Alternative considered: Flutter `Dismissible`. Rejected because a single instance cannot cleanly combine only left and down directions with coordinated stack animation and deterministic test hooks.

### Propagate actual weight, not target prescription

Every explicit weight edit path updates the selected set and later unresolved sets in the same exercise to the same canonical kilogram value. Completed or skipped sets, earlier sets, target weights, and other exercises are untouched. This keeps subsequent cards aligned with the user's in-session decision while preserving the program prescription for comparison and progression.

### Draw the plate breakdown with Flutter primitives

The plate module renders a compact abstract bar, collars, and mirrored color-coded plates sized by relative plate value, while retaining a textual accessible summary. No bitmap asset or new dependency is needed, and the graphic scales cleanly across phone widths.

### Serve Web and API on one Alibaba Cloud HTTPS host

Prefer an A record for `fittin.yimelo.cc` pointing to the existing Alibaba Cloud ECS. Nginx serves the Flutter bundle at `/` and proxies `/api/` through an NPS TCP port to the Go backend on `241-dhg`, stripping the `/api` prefix. The release build uses `BACKEND_URL=https://fittin.yimelo.cc/api`, giving same-origin browser requests. If the `yimelo.cc` DNS zone cannot be changed with the available account, use `fittin.hammerscholar.net` with the same path contract and certificate family.

The repository retains only templates and operational instructions; credentials and issued certificate private keys stay on their hosts. Cloudflared units/examples are removed from the supported Fittin production flow.

## Risks / Trade-offs

- [Older persisted drafts do not contain the cancellation flag] → Give the serialized field a `false` default and run model generation plus restore tests.
- [Diagonal gestures could trigger the wrong action] → Require dominant-axis thresholds and show direction-specific feedback before commit.
- [Propagated weight could overwrite a later deliberate edit] → Propagate only at the moment of an explicit edit and only to unresolved later sets; a later edit becomes the new inherited value.
- [NPS or the 241 backend may be unavailable] → Validate backend health locally on 241, through the ECS tunnel port, and through public HTTPS separately.
- [DNS or certificate control for `yimelo.cc` may be unavailable] → Fall back to `fittin.hammerscholar.net` and reuse/issue the matching certificate without changing application behavior.
- [A static build rollout could regress the live site] → Keep a timestamped previous bundle on ECS and make nginx reload conditional on a successful config test.

## Migration Plan

1. Land backwards-compatible model, provider, settings, UI, and tests; build the Web bundle against the selected same-origin `/api` URL.
2. Confirm the Go backend health endpoint on `241-dhg`, then configure or reuse an NPS client mapping to an unused ECS loopback port.
3. Upload the new Web bundle and nginx site config to a staging directory on ECS; test nginx configuration and loopback Host routing.
4. Create/update DNS, obtain or select the matching TLS certificate, atomically activate the site, and run public frontend/API checks.
5. Push the repository change and require GitHub CI to pass, then perform phone-viewport visual and interaction checks against the public URL.

Rollback restores the previous nginx site/bundle, reloads nginx after a successful config test, and leaves the 241 backend data untouched.

## Open Questions

- Whether the available DNS credentials can modify `yimelo.cc`; this is resolved operationally before choosing the documented fallback hostname.
- Which unused NPS server port is available on the ECS; inspect the live NPS/nginx configuration before allocating one.
