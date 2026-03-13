## Why

The current DemoHomeScreen is a basic placeholder with a single functional button. To elevate Fittin v2 into a premium, smart fitness tracking experience, we need a Home Dashboard that conveys crucial information at a glance. It should immerse the user in the app's dark-mode minimal aesthetic using advanced techniques like glassmorphism.

## What Changes

We are redesigning the home screen into a data-rich, visually appealing `HomeDashboardScreen` that features three distinct zones:
1.  **Greeting & Today's Workout**: A prominently elevated card functioning as the main gateway to today's active session.
2.  **At a Glance Data Panel**: Visual, chart-based representations of the user's current progress (e.g., a glowing Strength Level progress ring and a Weekly Volume bar chart).
3.  **Glassmorphism Navigation Bar**: A luxurious, floating frosted glass bottom navigation bar.

## Capabilities

### New Capabilities

- `today-workout-gateway`: A large summary card that launches the active training session seamlessly with shared element-like animations.
- `data-insight-dashboard`: Visual widgets (Progress Rings and Bar Charts) implemented cleanly within the UI using implicit animations or custom painters.
- `glass-bottom-nav`: A persistent floating frosted-glass bottom navigation solution.

### Modified Capabilities

None

## Impact

- Replaces `DemoHomeScreen` with `HomeDashboardScreen`.
- Requires adding layout composition techniques using layers `Stack`/`Positioned`/`BackdropFilter`.
- May introduce simple local state dependencies and UI dummy models for layout testing.
