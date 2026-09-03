## MODIFIED Requirements

### Requirement: Web Datastore Startup Compatibility
The app MUST initialize the local datastore on Flutter Web without requiring native filesystem directory APIs before `runApp()`. Existing browser database connections MUST close when a newer schema requests `versionchange`; a blocked or timed-out upgrade MUST produce a typed recoverable failure, release the cached open attempt and permit retry instead of waiting indefinitely.

#### Scenario: Browser startup opens the datastore
- **WHEN** the app starts in Chrome or another Flutter Web runtime
- **THEN** datastore initialization avoids native-only local directory lookups
- **AND** the app reaches widget rendering instead of stalling on a blank page before first frame.

#### Scenario: Older tab blocks a database upgrade
- **WHEN** another browser context keeps an older IndexedDB connection open during startup
- **THEN** the opening client exits within a bounded interval with a recoverable storage error
- **AND** after the stale connection closes, retry opens the database without reloading application code.
