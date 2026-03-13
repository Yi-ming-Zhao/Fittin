## Why

Currently, the Fittin v2 app only operates with a hardcoded "Squat Demo" that tracks a single exercise. To become a truly useful workout tracker, it needs to support comprehensive, multi-exercise training plans. The user is actively following a GZCLP 4-Day 12-Week program, which structures workouts into three tiers (T1 heavy, T2 volume, T3 accessories) across multiple lifts in a single session. Adding support for multi-exercise workouts and establishing the GZCLP plan as the default template is the critical next step.

## What Changes

1. **Multi-Exercise Storage & Logic**: The domain models and `ActiveSessionProvider` will be upgraded to support a full workout consisting of a sequence of exercises, rather than a single exercise. 
2. **GZCLP Template Construction**: We will encode the standard GZCLP 4-Day routine (Day 1 to 4) with correct T1, T2, and T3 logic into the app's `TemplateCollection` or database initialization.
3. **Workout Session UI Redesign**: The `ActiveSessionScreen` will be expanded to allow navigating through and recording multiple exercises (e.g., T1 Squat, T2 Bench, T3 Lat Pulldown) within the same session. 

## Capabilities

### New Capabilities
- `multi-exercise-session`: The ability for an active session to manage, display, and record multiple distinct exercises sequentially.
- `gzclp-program-template`: Standard 4-day GZCLP templates built-in to the application's starting data.

### Modified Capabilities
- `today-workout-gateway`: Modified to load the correct day from the GZCLP routine rather than a hardcoded squat demo.

## Impact

- **Domain/State**: Substantial refactoring of `training_state.dart` and `active_session_provider.dart` to maintain an array of `ExerciseSessionState` or similar structure.
- **UI**: `ActiveSessionScreen` must introduce an exercise navigator (e.g., tabs, swipeable PageView, or a single scrollable view with grouped headers) to let users log sets for different exercises.
- **Data**: Data parsing or mock initialization will be populated with GZCLP logic.
