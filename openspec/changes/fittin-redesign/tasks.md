# Implementation Tasks

## Theme System

- [x] **T1**: Create new theme token system in `lib/src/presentation/theme/fittin_theme.dart`
  - Define 3 directions: `editorialMono`, `technicalMono`, `warmClay`
  - Each direction has: bg, surface, border, fg, fgDim, fgMuted, fgFaint, accent, accentInk, accentDim, displayFont, uiFont, numFont, displayWeight, numWeight, chartStyle, chartStroke, chartGrid, chartDot, radius, radiusSm
  - Create `resolveTheme(baseId, tweaks)` function
  - Accent presets: bone (#f3ece0), lime (oklch 0.86 0.08 118), terracotta (oklch 0.72 0.11 45), sky, plum, ember
  - Bg presets: trueBlack (#000), warmBlack (#0c0b0a), charcoal, warmCharcoal
  - Type presets: editorial (Fraunces+Inter), technical (JetBrains Mono+Inter), clay (Instrument Serif+Sans), neutral
  - Density presets: comfortable (20pad/16gap/34title), compact (14/10/28)

- [x] **T2**: Update `app_colors.dart` to use new theme tokens
  - Remove old AppThemeType enum (ocean, minimalDark, sunset)
  - Keep existing ColorScheme for Flutter compatibility but source from new tokens
  - Note: New FittinTheme system created as parallel; existing app_colors.dart preserved for backward compatibility

## Primitives

- [x] **T3**: Create `Card` widget with glass/flat/bordered variants
  - Location: `lib/src/presentation/widgets/fittin_card.dart`
  - Glass: backdropFilter blur(20px), surface color with opacity, border 0.5px, inset highlight
  - Flat: solid surface color
  - Bordered: transparent bg, borderHi 0.75px

- [x] **T4**: Create typography primitives
  - `Eyebrow`: 10px, weight 500, letter-spacing 1.8, uppercase, fgMuted
  - `SectionTitle`: display font, variable size, letter-spacing -1
  - `BigNum`: large tabular nums with optional unit suffix
  - `Delta`: ▲/▼ with sign and unit, accent (positive) or fgDim (negative)

- [x] **T5**: Create `StepChart` widget (SVG-like CustomPainter)
  - Location: `lib/src/presentation/widgets/charts/step_chart.dart`
  - Variants: step (default), linear, smooth, area
  - Grid lines at 0%, 33%, 66%, 100%
  - Dots at first/middle/last points only
  - Props: data, width, height, showDots, showGrid, yLabels

- [x] **T6**: Create `Sparkline` widget (compact StepChart)
  - No dots, no grid, just the line
  - Props: data, width, height

- [x] **T7**: Create `Ring` widget (circular progress, thin stroke)
  - Replace glowing ring with clean thin stroke
  - Props: value, max, size (default 120), strokeWidth (default 2)

- [x] **T8**: Create `Chip` and `Segmented` controls
  - Chip: pill with active (accent fill) / inactive (bordered) states
  - Segmented: glass background pill with segments

- [x] **T9**: Update `glass_bottom_nav.dart` to use new tab bar design
  - 5 tabs: Today, Plans, PR, Body, Me
  - Glass: blur(24px) saturate(140%), 0.5px border, border-radius 999
  - Active: accent fill; inactive: transparent

## Home Screen

- [x] **T10**: Update `home_dashboard_screen.dart`
  - Top meta row: date (left), Week/Day (right)
  - Session hero card with "In progress" dot, progress strip, "Up next" + Resume CTA
  - Two stat cards: Cycle (9% with mini progress bar) + Squat e1RM (big num + sparkline + delta)
  - Activity card: StepChart + latest/sessions footer
  - Quick actions: 2-col grid

- [x] **T11**: Update `today_workout_hero_card.dart`
  - Show "In progress" status with accent dot
  - Progress strip with 2px height (not glowing ring)
  - "Up next" section with exercise name and details

- [x] **T12**: Update `strength_level_ring.dart`
  - Replace glowing white ring with thin accent stroke ring
  - Remove glow effect (MaskFilter blur on progress paint)

## Plans Screen

- [x] **T13**: Update `plan_library_screen.dart`
  - Filter chips: All | Built-in | Custom | New
  - Plan cards with active dot (6px accent) + "Active" text
  - Tags with bordered pill style
  - Stat row: Workouts | Exercises | Running

- [x] **T14**: Update `plan_editor_screen.dart`
  - Fix field overflow: use column/wrap instead of 2-col for tight fields
  - Day/Week selectors: accent fill when selected, bordered when not
  - Template editor with proper field stacking

## Progress Screen

- [x] **T15**: Update `pr_dashboard_screen.dart`
  - Segmented: Estimated 1RM | Actual PR (plain, no mint accent)
  - PR cards with sparkline and delta
  - Strength progression: StepChart with lift filter buttons
  - Milestones: check icon + exercise + value + date

- [x] **T16**: Update `exercise_deep_dive_screen.dart`
  - 1RM/3RM/5RM overlay: stepped charts at different opacities
  - 1RM: accent color, 3RM: fgMuted, 5RM: fgDim
  - Session history table

- [x] **T17**: Update `progress_analytics_screen.dart`
  - Calendar grid for consistency view
  - Heavy session: accent fill; accessory: accent 40%; rest: border only
  - Muscle load bars with over-target indicator

## Body Screen

- [x] **T18**: Update `body_metrics_screen.dart`
  - Weight hero: big 52px number, unit segmented, delta, sparkline
  - 3-metric row: body fat, waist, chest with deltas
  - Measurement log table

## Profile Screen

- [x] **T19**: Update `profile_settings_screen.dart`
  - Account section with status
  - Language selector with radio indicators
  - Weight tools with converter access
  - Training guide link
  - Glass opacity slider

- [x] **T20**: Update `weight_tools_sheet.dart`
  - Bottom sheet with conversion input
  - Real-time conversion display
  - Visual plate loading diagram

- [x] **T21**: Update `set_type_guide_screen.dart`
  - Numbered entries (01, 02, 03...)
  - Display font for entry name
  - Accent dot bullets for tips

## Chart Updates

- [x] **T22**: Update `line_chart_painter.dart` → rename to step chart painter
  - Remove smooth spline behavior
  - Implement stepped path: horizontal-vertical-horizontal pattern
  - Add smooth/linear/area variants based on style parameter

- [x] **T23**: Update `weekly_progress_bar_chart.dart`
  - Replace smooth curves with stepped bars if applicable
  - Use theme accent for fill
