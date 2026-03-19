## 1. Data Layer & Core Logic

- [x] 1.1 Define `BodyMetric` Isar collection including weight, body fat, and timestamp.
- [x] 1.2 Define `ProgressPhoto` Isar collection for tracking local file paths and comparison metadata.
- [x] 1.3 Implement E1RM calculation service based on Brzycki formula.
- [x] 1.4 Create `ProgressRepository` to handle queries for historical E1RM peaks and metric trends.

## 2. Shared Visualization Components

- [x] 2.1 Implement `LineChartPainter` supporting multi-line data, neon glow effects, and grid lines.
- [x] 2.2 Implement `HeatmapPainter` for the 90-day consistency grid.
- [x] 2.3 Implement `MuscleDistributionPainter` for horizontal bars and anatomical highlighting.
- [x] 2.4 Create a shared `ChartContainer` widget with glassmorphism styling.

## 3. PR Dashboard Implementation

- [x] 3.1 Build `PrDashboardScreen` with a vertical scrollable layout.
- [x] 3.2 Implement `StrengthSummaryCard` showing E1RM and 30-day delta.
- [x] 3.3 Implement `E1RMProgressionChart` using the shared painter.
- [x] 3.4 Build the `MilestoneFeed` list populated from historical data peaks.

## 4. Exercise Deep Dive Implementation

- [x] 4.1 Build `ExerciseDeepDiveScreen` as a modal or secondary screen.
- [x] 4.2 Add `StrengthTrendsOverlayChart` showing 1/3/5RM lines.
- [x] 4.3 Implement `ExerciseHeroHeader` with high-contrast B&W image support.
- [x] 4.4 Build the filtered `ActivityHistory` list for the deep dive view.

## 5. Body Metrics Tracking Implementation

- [x] 5.1 Build `BodyMetricsScreen` featuring the weight progression chart.
- [x] 5.2 Implement the `MetricTileGrid` for Body Fat and Waist measurements.
- [x] 5.3 Build `ProgressPhotoVault` with image picker and side-by-side comparison view.

## 6. Advanced Analytics Screen

- [x] 6.1 Build `AdvancedAnalyticsScreen` within the main navigation flow.
- [x] 6.2 Implement `ConsistencyModule` with the 90-day heatmap.
- [x] 6.3 Implement `TrainingVolumeModule` with muscle group volume bars.
- [x] 6.4 (Optional/Bonus) Add the anatomical training load diagram.

## 7. Polish & Integration

- [x] 7.1 Integrate new screens into the `AppShell` or `Home` navigation menu.

## 8. Premium UI Overhaul (Glassmorphism & Glow)

- [x] 8.1 Redesign all dashboard cards using the Home Dashboard's Gradient + Blur pattern.
- [x] 8.2 Overhaul chart painters to support neon glow paths and soft backgrounds.
- [x] 8.3 Align typography tokens (headlineMedium, labelSmall) across all progress screens.
- [x] 8.4 Implement "Glass-Action" buttons for sub-navigation and details.

## 9. Dynamic UI Settings

- [x] 9.1 Add `glassOpacity` field to `AppStateCollection` and update `DatabaseRepository`.
- [x] 9.2 Create `UISettingsProvider` to manage global glassmorphism intensity.
- [x] 9.3 Add an "Opacity Slider" to the Profile/Settings screen.
- [x] 9.4 Integrate `UISettingsProvider` into all Premium components for real-time transparency scaling.
