## Context

The current `DemoHomeScreen` is a functional but aesthetically barren placeholder. As part of the `frontend-redesign` effort to position Fittin v2 as a premium, smart fitness tracking app, we are introducing a sophisticated Home Dashboard (`HomeDashboardScreen`). This dashboard will utilize the newly established deep ocean/minimal dark color palettes and introduce advanced UI techniques like glassmorphism (frosted glass effects) and custom data visualizations (neon progress rings and minimal bar charts).

## Goals / Non-Goals

**Goals:**
*   Implement a high-end, dark-mode `HomeDashboardScreen` replacing the DemoHomeScreen.
*   Create a reusable Glassmorphism Bottom Navigation Bar (`GlassBottomNav`).
*   Implement custom, visually striking data visualization widgets: a glowing `StrengthLevelRing` and a `WeeklyProgressBarChart`.
*   Maintain the existing navigation flow seamlessly entering the `ActiveSessionScreen` via a "Today's Workout" hero card.

**Non-Goals:**
*   Integrating real historical database data for the charts (the MVP dashboard will use mocked structured data to demonstrate exactly how the UI reacts).
*   Handling complex multi-page routing for the new bottom nav tabs (we will only build the visual shell of the navigation bar, with the Home tab active).

## Decisions

*   **Decision 1: Constructing the Glassmorphism Effect**
    *   *Approach*: We will use Flutter's built-in `BackdropFilter` widget wrapped in a `ClipRRect` to achieve the frosted glass effect for the bottom navigation and potentially some card backgrounds.
    *   *Rationale*: This avoids external dependencies while providing native-level rendering of blur effects. The dark theme colors mixed with a slight opacity (e.g., `Colors.white.withOpacity(0.05)`) provide an excellent base for the blur.
*   **Decision 2: Data Visualization Implementation (Charts)**
    *   *Approach*: Instead of importing heavy charting libraries (like `fl_chart`) just for two specific, highly-styled minimalist charts, we will build them natively.
        *   **Strength Ring**: A custom `CustomPainter` drawing an arc with a `SweepGradient` and a subtle drop shadow to simulate neon glow.
        *   **Weekly Bar Chart**: A horizontal sequence of `AnimatedContainer` widgets whose height is determined by the data relative to the maximum value in the dataset.
    *   *Rationale*: Total control over the exact gradient, corner radius, and neon glow effects required by the premium UI mockup without fighting a chart library's API.
*   **Decision 3: Layout Architecture**
    *   *Approach*: The screen will use a base `Scaffold` where `extendBody: true` is set. The body will be a scrollable `ListView` or `CustomScrollView`, and the bottom navigation will sit over the content, allowing the scrollable content to elegantly blur under the navigation bar as it moves.

## Risks / Trade-offs

*   **Risk**: Overuse of `BackdropFilter` can cause frame drops (jank) on lower-end Android or older iOS devices, especially during scrolling.
    *   **Mitigation**: Restrict `BackdropFilter` primarily to the bottom navigation bar and perhaps the main hero card. Evaluate performance in profile mode; if jank occurs, fallback to a semi-transparent solid color on specific devices.
*   **Risk**: Custom building charts can lead to hardcoded layouts that don't scale well across screen sizes.
    *   **Mitigation**: Build the custom painters and containers using relative sizing (e.g., `LayoutBuilder` or percentages of available width) rather than absolute pixel values.
