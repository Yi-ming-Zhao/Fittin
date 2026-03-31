## ADDED Requirements

### Requirement: Persisted Active Session Draft
The system MUST persist the in-progress active workout session so the same draft can be restored after app relaunch or browser refresh.

#### Scenario: User refreshes during an in-progress workout
- **WHEN** the user has already changed reps, weights, completion state, or exercise selection in an active workout and then refreshes the app
- **THEN** the app restores the same in-progress workout draft on resume
- **AND** it does not rebuild the session from the current training instance as though the workout had never started.

### Requirement: Explicit Workout Conclusion Confirmation
The system MUST require an explicit confirmation step before concluding and persisting the active workout session.

#### Scenario: User taps conclude by mistake
- **WHEN** the user taps the final conclude action from the active workout screen
- **THEN** the app asks for confirmation before saving the workout and advancing progression
- **AND** cancelling that confirmation leaves the active workout draft unchanged.
