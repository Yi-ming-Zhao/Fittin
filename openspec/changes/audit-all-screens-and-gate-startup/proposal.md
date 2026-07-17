## Why

Fittin can briefly render a false plan-loading failure while a stored account and its cloud-backed local state are still being restored. The newly unified visual system also needs a systematic route-by-route audit so secondary screens, dialogs, and transient states meet the same mobile quality bar as the five primary tabs.

## What Changes

- Add a theme-aware animated startup experience that remains visible until authentication restoration and the first user-data hydration attempt have settled.
- Prevent transient pre-hydration plan errors from reaching the visible app shell, while retaining bounded waiting, retry, offline continuation, and genuine-error handling.
- Inventory and visually audit every reachable screen, subpage, sheet, dialog, and loading/empty/error state at tall and short phone viewports, across representative dark/light palettes and both supported languages.
- Apply only evidence-backed spacing, overflow, touch-target, hierarchy, contrast, safe-area, or interaction fixes found by the audit.
- Add startup-race, responsive-geometry, localization, theme, and regression coverage, then publish the next signed Android/web release after CI and visual verification pass.

## Capabilities

### New Capabilities

- `startup-readiness`: Defines the animated application readiness gate, the work it waits for, and its bounded retry/offline behavior.

### Modified Capabilities

- `adaptive-mobile-surfaces`: Extends mobile viewport guarantees from primary tabs to every reachable screen, subpage, sheet, dialog, and significant async state.
- `premium-micro-animations`: Adds a restrained, palette-aware startup transition with reduced-motion behavior.

## Impact

The change affects app startup composition, authentication restoration, initial cloud hydration, plan-provider prewarming, lifecycle synchronization, localization, shared responsive primitives, and any screens identified by the evidence-backed audit. It adds widget/provider regression tests and visual QA evidence, but does not change backend APIs or stored training data.
