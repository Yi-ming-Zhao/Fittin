## ADDED Requirements

### Requirement: App Shell Readiness Gate
The system MUST keep authenticated training surfaces hidden until stored authentication has resolved, the first signed-in hydration attempt has settled, and the current plan and Today dashboard have been read in the resolved owner scope. A transient pre-hydration plan failure MUST NOT be rendered to the user.

#### Scenario: Stored signed-in session launches
- **WHEN** the app opens with a stored authenticated session and cloud-backed training data
- **THEN** it presents the startup experience while authentication and first hydration settle
- **AND** the first visible app-shell frame uses the restored user's current plan without showing an intermediate load failure.

#### Scenario: Local-only user launches
- **WHEN** the app opens without a stored authenticated session
- **THEN** startup completes from local persistence without requiring network access
- **AND** the local-first plan and training surfaces remain available.

### Requirement: Bounded Startup Recovery
Startup readiness work MUST be bounded and MUST distinguish degraded offline readiness from a genuine blocking failure. A readable local state MUST be allowed to continue after a failed hydration attempt, while a blocking failure MUST offer Retry and Continue locally actions instead of waiting indefinitely.

#### Scenario: Cloud hydration is unavailable but local data is readable
- **WHEN** the initial signed-in synchronization attempt fails and the user's local plan can still be read
- **THEN** the app exits startup using the local state
- **AND** synchronization remains marked for retry without replacing the local plan with a transient error.

#### Scenario: Startup work cannot establish readiness
- **WHEN** authentication restoration or required local prewarming fails or exceeds its bounded wait
- **THEN** the startup surface presents localized Retry and Continue locally actions
- **AND** the animation does not continue indefinitely.

### Requirement: Stable No-Plan Startup
The absence of an active training plan MUST be treated as a valid settled domain state rather than a startup crash.

#### Scenario: User has no active plan
- **WHEN** startup completes and the resolved owner scope has no active plan
- **THEN** the app reveals a stable plan-selection state
- **AND** it does not repeatedly alternate between loading and generic failure content.
