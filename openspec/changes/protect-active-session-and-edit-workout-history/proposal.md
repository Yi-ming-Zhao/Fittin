## Why

The current workout flow has three reliability gaps in the app's core path: a single mistap can conclude a workout immediately, in-progress logging is lost on web refresh because the active session draft is not persisted, and completed workout records cannot be corrected after save. These issues directly affect data safety and trust in the training log, so they need to be fixed before further logger enhancements.

## What Changes

- Add an explicit confirmation step before the final workout conclusion action commits a session.
- Persist the in-progress active workout draft so the app can resume the same session after browser refresh or app relaunch instead of rebuilding today's workout from the current instance state.
- Add editable workout history for individual workout logs, including set values and completion timestamp updates.
- Recompute next-session progression only when the edited workout is the one that directly determines the next prescription; older history edits update logs and analytics only.
- Extend local persistence so workout logs have stable identities, editable payloads, and optional replay metadata needed for safe progression rewrites.

## Capabilities

### New Capabilities
- `editable-workout-history`: Defines how a saved workout log can be reopened, edited, and saved back into local history without corrupting progression state.

### Modified Capabilities
- `multi-exercise-session`: Active workout drafts must survive refresh/relaunch and final conclusion must require explicit confirmation.
- `today-workout-gateway`: Entering the workout logger must resume an existing persisted draft before generating a fresh session.
- `local-datastore-schema`: Local storage must persist active session drafts and editable workout-log metadata across native and web storage backends.
- `advanced-training-analytics`: Drilldown record detail must reflect edited workout logs and continue navigating by recorded day.

## Impact

- Affects workout-session state management, today-workout loading/conclusion flow, and workout record detail UI.
- Adds repository and storage responsibilities for session-draft persistence, workout-log updates, and replay metadata.
- Changes analytics/history refresh behavior after workout-log edits on both Isar-backed and web IndexedDB-backed storage.
