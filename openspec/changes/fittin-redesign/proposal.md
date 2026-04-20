## Why

The current Fittin UI uses high-saturation, uncoordinated colors (mint green, red, orange, blue, magenta, yellow) that make the app feel cheap and dirty. Layout hierarchy is weak, charts use glowing elements and smooth red splines that reduce data readability, and glassmorphism is overdone. The app needs a complete visual refresh: dark-only, monochrome-first, with one restrained accent per direction and data-forward stepped charts.

## What Changes

- **Color system overhaul**: Replace all high-saturation colors with 3 restrained visual directions (Editorial Mono, Technical Mono, Warm Clay), each with a single muted accent
- **Chart redesign**: Replace smooth red splines with stepped/data-forward charts; remove glowing white rings on progress indicators
- **Glassmorphism refinement**: Reduce blur/opacity, cleaner borders on glass cards
- **Typography hierarchy**: Consistent use of display serif for numbers, clean sans-serif for UI, proper weight hierarchy
- **Layout improvements**: Fix cramped tab bar, overflow in template editor, proper whitespace in all screens
- **5 screens redesigned**: Home, Plans, Progress, Body, Profile

## Capabilities

### New Capabilities
- `theme-system`: Visual direction system with 3 themes (editorial/technical/clay), accent presets, background tone presets, type family presets, card style variants (glass/flat/bordered), density scales (comfortable/compact)
- `home-screen`: Today view with session progress hero, cycle/Squat e1RM stat cards, stepped activity chart, quick action grid
- `plans-screen`: Plan library with filter chips, plan detail view, template editor with proper field stacking
- `progress-screen`: PR dashboard with per-lift cards and sparklines, strength progression chart with stepped overlay, milestones list
- `body-screen`: Body weight hero with sparkline, 3-metric quick row, measurement log
- `profile-screen`: Account status, language selector, weight tools with converter sheet, training guide reference
- `design-system-primitives`: Card, Eyebrow, SectionTitle, BigNum, Delta, Chip, Segmented, Btn, Divider, StepChart, Sparkline, Ring, AppTabBar, Icons

### Modified Capabilities
- None — this is a pure visual redesign without behavior changes

## Impact

- **UI layer only**: No changes to data models, API contracts, or business logic
- **Theme tokens**: All color/type/spacing values sourced from theme objects (no hardcoded values)
- **No dependencies added**: Purely presentational, no new packages required
- **Target**: Flutter/dart codebase (this app), design prototype delivered as HTML/JSX reference
