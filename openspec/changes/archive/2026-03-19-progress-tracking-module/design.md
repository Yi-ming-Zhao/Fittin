## Context

Fittin v2 has established a "Premium Minimal" dark-mode aesthetic, particularly in the current Home Dashboard. Currently, progress tracking is limited to showing a list of past workouts. To provide a high-end athlete experience, we need sophisticated data visualization that matches the app's existing visual quality and Stitch-inspired design language. This design leverages custom-painted charts and a structured data model to track PRs, body metrics, and long-term trends, ensuring a seamless visual transition from the home dashboard.

## Goals / Non-Goals

**Goals:**
*   **High-Fidelity Visualization**: Implement multi-line E1RM charts, GitHub-style consistency heatmaps, and muscle-group volume bars using `CustomPainter`.
*   **Unified Progress Entry**: Consolidate Training Maxes, Body Metrics, and General Analytics into a single cohesive dashboard.
*   **Physical Change Tracking**: Build a specific module for body weight/composition and photographic progress.
*   **Granular Exercise Insights**: Create a "Deep Dive" view accessible from any exercise reference in the app.

**Non-Goals:**
*   Implementation of social sharing of graphs (this is handled by the general `share_screen.dart` capability).
*   Automatic body fat calculation from photos (manual entry only).

## Decisions
 
**1. Rendering Strategy: Native CustomPainter vs. 3rd Party Libraries**
*   **Decision**: Use native `CustomPainter` for all charts (Heatmaps, E1RM line charts, Volume bars).
*   **Rationale**: Third-party libraries often struggle with the "Premium Minimal" aesthetic (neon glows, specific grid treatments, frosted glass overlays). Native painting allows full control over implicit animations and visual effects (like soft-edged glows on PR lines).
 
**2. Data Modeling: BodyMetrics & ProgressPhotos**
*   **Decision**: Create new Isar collections `BodyMetric` (timestamped measurements) and `ProgressPhoto` (file path and metadata).
*   **Rationale**: These metrics are distinct from Workout sessions but should be correlated in the UI. Isar provides the performance needed for fast querying of historical data for real-time graph rendering.
 
**3. PR Attribution Logic**
*   **Decision**: The system will automatically calculate Estimated 1RM (E1RM) using the Brzycki formula for any set marked as a "Working Set" or "Top Set" in the training log.
*   **Rationale**: This ensures the PR Dashboard feels automatic and "smart" without requiring manual PR entry.
 
**4. Premium Visual Language & Glassmorphism**
*   **Decision**: Adopt the "Glass-Glow" design system from the Home Dashboard, with user-configurable transparency.
*   **Implementation**:
    *   **Main Hero Cards**: Use `LinearGradient` with `primary.withValues(alpha: glassOpacity * 0.8)` to `primaryContainer.withValues(alpha: glassOpacity)`. Include a box shadow with `primary.withValues(alpha: 0.12)` and 24 blur.
    *   **Standard Cards**: Use `onSurface.withValues(alpha: glassOpacity * 0.1)` with a `1.0` width border at `onSurface.withValues(alpha: glassOpacity * 0.15)`.
    *   **Chart Aesthetics**: E1RM lines must use a dual-stroke approach: a thin, high-opacity primary line and a wider, low-opacity "neon glow" line (BlurStyle.normal).
    *   **Typography**: Section labels must use `labelSmall` with `bold`, `letterSpacing: 1.2`, and `onSurface.withValues(alpha: 0.5)`.
 
**5. User-Configurable Transparency**
*   **Decision**: Add a new setting to allow users to adjust the `glassOpacity` intensity (range 0.1 to 1.0, default 0.3).
*   **Rationale**: Different environments and display qualities impact the legibility of glassmorphism. Giving control to the user aligns with the "Advanced Athlete" persona who values customization.
 
## Risks / Trade-offs

*   **[Risk] Performance with large datasets**: Rendering 90-day heatmaps and multi-year charts can become frame-intensive.
*   **[Mitigation]**: Implement data downsampling for very long charts and use `RepaintBoundary` for static graph elements.
*   **[Trade-off] Manual Photo Management**: We will store photo references in the local database but rely on the user to manage their local storage. We will not implement a cloud-sync solution in this phase.
