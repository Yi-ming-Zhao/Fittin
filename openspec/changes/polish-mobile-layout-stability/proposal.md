## Why

The app has strong per-page styling but still needs a release-wide audit against constrained phone heights, large text, keyboard and safe-area changes. This pass should remove reproducible layout and interaction failures without replacing the established visual identity or destabilizing training data.

## What Changes

- Audit every primary tab and major pushed page at representative narrow, long-phone and large-text viewports, then fix only evidence-backed layout defects.
- Keep essential actions reachable when content, system insets, browser chrome or the keyboard reduce the usable height.
- Improve shared spacing, scrolling, semantics and visual hierarchy where repeated patterns cause clipping, dead space or ambiguous interaction.
- Correct audit-confirmed state isolation and commit-order defects that can expose another account's body data, stall Web startup, report unresolved sync conflicts as successful, or split one completed workout across inconsistent records.
- Serialize Agent retry/resume commands so rapid taps cannot start duplicate provider runs.
- Add regression coverage for every corrected condition and release the result as a signed Android/Web patch after focused, platform and public checks pass.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `adaptive-mobile-surfaces`: Extend safe viewport behavior to large text, transient insets and all audited primary/subpage surfaces.
- `minimalist-layout-system`: Require repeated page modules and action areas to retain readable hierarchy under compact reflow.
- `body-metrics-tracker`: Isolate body summaries and destructive actions by authenticated owner while retaining the latest non-null value for each metric.
- `local-datastore-schema`: Make blocked Web upgrades fail recoverably instead of holding the splash indefinitely.
- `today-workout-gateway`: Commit the completed workout log and progressed plan instance atomically and idempotently.
- `user-cloud-sync`: Surface preserved conflicts rather than presenting the last sync as successful.
- `in-app-agent-harness`: Serialize retry and resume commands for one active run.
- `design-system-primitives`: Give shared selectors and compact controls complete selection semantics and 44-pixel targets.
- `plan-template-editor`: Keep translated editor actions named and reachable on narrow phones.
- `release-integrity`: Publish the audited patch as `v1.2.1+25` without advancing first-party metadata before verification.

## Impact

Flutter presentation widgets and screens, owner-bound providers, local transaction coordination, Web IndexedDB opening, sync status reporting, Agent run serialization, responsive/widget/data tests, release metadata, Android/Web build artifacts and public deployment. Persistent schemas, Agent tool permissions and provider credentials remain unchanged.
