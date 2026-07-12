## Why

The active workout logger still behaves like a compact form: its exact-weight editor is hidden behind a long press, progress is visually flat, and the next set reverts to the original prescription after a weight adjustment. The public web deployment also still depends on Cloudflare Tunnel, while the requested production path is a directly addressable Alibaba Cloud HTTPS entrypoint backed by the service on `241-dhg`.

## What Changes

- Redesign the active workout screen around a mobile-first, real-time stack of current and upcoming set cards that matches the app's premium dark dashboard language.
- Complete the current set by swiping its card left, cancel the current set edit by swiping down, and keep an accessible centered completion action as a non-gesture fallback.
- Add an abstract barbell-and-plates visualization to the plate breakdown instead of presenting only numeric plate counts.
- Let users choose between the new card logger and the retained traditional logger from profile settings, with the preference persisted locally.
- Open exact weight entry with a normal tap instead of a long press, and propagate an explicitly changed weight to later incomplete sets of the same exercise.
- Replace the Cloudflare Tunnel deployment contract with a direct Alibaba Cloud nginx/NPS path for the frontend and backend, preferring `fittin.yimelo.cc` and falling back to `fittin.hammerscholar.net` only if the preferred DNS zone cannot be updated.
- Update deployment scripts and documentation so builds, HTTPS smoke checks, rollback, and future updates use the direct public path.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `training-log-screen-refactor`: Add the card stack recording mode, directional set-card gestures, centered completion fallback, tap-to-edit weight, and graphical plate visualization.
- `zero-typing-ui`: Define the gesture behavior and accessible fallback for completing or cancelling a current set card.
- `multi-exercise-session`: Make an explicit weight edit seed later incomplete sets of the same exercise while preserving completed sets and other exercises.
- `profile-screen`: Add a locally persisted card-versus-traditional workout recording preference to settings.
- `web-public-deployment`: Replace Cloudflare Tunnel routing with an Alibaba Cloud public HTTPS reverse-proxy deployment for the frontend and backend on `241-dhg`.

## Impact

- Flutter active-session presentation, UI settings persistence, localization copy, and active-session state transitions.
- Widget and provider tests for both recording modes, swipe behavior, tap editing, and weight propagation.
- Public deployment scripts, service configuration, nginx/NPS setup documentation, DNS/HTTPS validation, and CI-driven release verification.
- The existing local Cloudflare token/config is no longer part of the supported production path and must never be committed.
