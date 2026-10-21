## Why

Normal Agent tasks currently fail at fixed output, turn, tool and duration ceilings, while streaming layout changes disturb reading. Plan lifecycle controls and day previews are incomplete, the editor exposes too much at once, and cardio is currently a manual/imported summary rather than a live recording experience.

## What Changes

- Replace task ceilings with resumable continuation, provider-aware requests, context compaction and no-progress protection; stabilize streamed reading.
- Add non-destructive stop/resume/restart and executable day previews; progressively disclose plan editing.
- Add phone-first live cardio recording, background location, private route persistence, maps, laps and recovery; preserve manual/imported records.
- Audit every reachable screen and remove decorative explanatory copy while retaining safety information.
- Release v1.5.0+28 after migration, provider, platform and public-deployment gates pass. Under the user's 2026-10-21 trial approval, online AMap stays disabled and Android outdoor validation follows download, with both limitations disclosed.

## Capabilities

### New Capabilities
- `live-cardio-recording`: Location-based sessions, maps, laps, private routes and platform-specific recovery.

### Modified Capabilities
- `in-app-agent-harness`: Continuable tasks without fixed run quotas and stable reading.
- `agent-web-relay`: Active streaming without a fixed total-duration cutoff; preserve security bounds.
- `plan-library-switching`: Stop/resume/restart and concrete day navigation.
- `plan-template-editor`: Overview/day/exercise editing hierarchy.
- `adaptive-mobile-surfaces`: Route-complete concise presentation and interaction verification.

## Impact

Flutter/Riverpod runtime, native and IndexedDB persistence, Kotlin/iOS location adapters, Go relay/nginx, CI and release artifacts. Existing training history and signing identity must remain unchanged. Online AMap is deferred pending authorization; the user will test Android outdoor recording after downloading the trial. Neither is assumed completed by automated checks.
