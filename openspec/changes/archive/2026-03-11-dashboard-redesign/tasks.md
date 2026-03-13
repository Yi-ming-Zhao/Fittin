## 1. Foundation & Layout

- [x] 1.1 Create `HomeDashboardScreen` file and set up base `Scaffold` structure.
- [x] 1.2 Implement the Greeting Header with dummy user text and icon.

## 2. Component Implementation: At a Glance Charts

- [x] 2.1 Implement `StrengthLevelRing` using a custom `CustomPainter` for the neon progress glow.
- [x] 2.2 Implement `WeeklyProgressBarChart` using relative height `AnimatedContainer` widgets.
- [x] 2.3 Assemble the "At a Glance" section embedding the ring and chart side-by-side.

## 3. Component Implementation: Today's Workout Gateway

- [x] 3.1 Design the `TodayWorkoutHeroCard` widget using theme colors and a subtle background.
- [x] 3.2 Wire up the tap interaction on the hero card to navigate to `ActiveSessionScreen`.
- [x] 3.3 Ensure the transition animation to `ActiveSessionScreen` is smooth.

## 4. Component Implementation: Glass Bottom Navigation

- [x] 4.1 Create `GlassBottomNav` widget utilizing `BackdropFilter` and `ClipRRect`.
- [x] 4.2 Implement internal navigation bar items with glowing indicator for active state.
- [x] 4.3 Lock `extendBody: true` on the `Scaffold` and attach the bottom nav to test the scroll overlay effect.

## 5. Polish and Final Review

- [x] 5.1 Replace `DemoHomeScreen` with `HomeDashboardScreen` in the router or main entry point.
- [x] 5.2 Validate performance and aesthetic glow effects on rendering.
