## Why

The dashboard can advance to a newer scheduled workout while the active-session provider restores an older draft for the same plan instance, so a user may see Week 1 Day 3 on Home but enter Week 1 Day 2. Fast card flicks can also be misclassified or ignored while completion animations and asynchronous draft writes are still in flight, making a core workout action feel network-dependent even though it should remain local and immediate.

## What Changes

- Validate a persisted workout draft against the active instance's current instance/template/workout identity and progression token before resuming it, and discard a stale draft instead of presenting conflicting week/day state.
- Deduplicate rapid session-launch taps so one user action produces one coherent session load and one navigation.
- Serialize active-draft writes in mutation order and prevent an older asynchronous save from recreating a draft after workout conclusion clears it.
- Recognize a card action when either displacement or release velocity passes a direction-aware threshold, including short high-velocity flicks.
- Apply set navigation, completion, and skip commands optimistically to local state without waiting for network work, while keeping animation and persistence deterministic under rapid input.
- Add regression coverage for stale-draft restoration, overlapping local writes, repeated launch taps, fast vertical/horizontal flicks, and mobile phone viewports.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `today-workout-gateway`: The Home summary and the session opened or resumed from it must resolve the same active instance and scheduled workout after local progression or cloud hydration.
- `multi-exercise-session`: Active drafts must be identity-validated and persisted in deterministic local mutation order so stale writes cannot overwrite newer state or survive a successful conclusion.
- `training-log-screen-refactor`: Card logging must accept short high-velocity flicks, remain responsive during animation, and apply each accepted command exactly once.
- `zero-typing-ui`: The four-way gesture contract is left/right for next/previous set and up/down for complete/skip, with distance-or-velocity recognition and local-first feedback.

## Impact

- Active session state and persistence coordination in `lib/src/application/active_session_provider.dart`.
- Dashboard launch guarding in `lib/src/presentation/widgets/today_workout_hero_card.dart`.
- Card gesture recognition and completion motion in `lib/src/presentation/screens/active_session_screen.dart`.
- Provider, widget, repository-race, and mobile interaction tests.
- OpenSpec deltas and the deployment checkout on `241-dhg`; no backend API or datastore schema change is required.
