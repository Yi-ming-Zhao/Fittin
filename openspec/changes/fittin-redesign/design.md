## Context

Fittin is a strength training tracking app. The current UI uses high-saturation, uncoordinated accent colors (mint green, red, orange, blue, magenta, yellow) that make the interface feel cheap and cluttered. The charts use smooth red splines with glowing elements. Glassmorphism is overdone with excessive blur. Layout problems include: cramped tab bar, template editor field overflow, and poor typographic hierarchy.

The design prototype was created as an HTML/JSX bundle with 3 visual directions, 5 screens, and a comprehensive set of design primitives. This design doc explains how to translate that prototype into production code.

## Goals / Non-Goals

**Goals:**
- Implement 3 visual directions: Editorial Mono, Technical Mono, Warm Clay
- Replace all charts with stepped/data-forward style; remove smooth red splines
- Refine glassmorphism: reduced blur (12px), lower opacity surfaces, cleaner borders
- Create consistent typography: serif display numbers, sans-serif UI, proper weight hierarchy
- Fix layout issues: tab bar spacing, template editor field stacking, proper card padding
- Keep dark-only mode; no light theme

**Non-Goals:**
- No changes to data models or business logic
- No new features beyond visual redesign
- No changes to app navigation structure (5-tab layout remains)
- No backend/API changes

## Decisions

### Decision 1: Theme Token System
All visual values are derived from a `theme` object resolved from a base direction + user tweaks. No hardcoded colors or spacing.

**Structure:**
- `DIRECTIONS` map: `editorial`, `technical`, `clay` — each with full token set
- `ACCENT_PRESETS`: bone, lime, terracotta, sky, plum, ember
- `BG_PRESETS`: trueBlack, warmBlack, charcoal, warmCharcoal
- `TYPE_FAMILIES`: editorial (Fraunces+Inter), technical (JetBrains Mono+Inter), clay (Instrument Serif+Sans), neutral
- `DENSITY`: comfortable (20px pad/16px gap/34px title) vs compact (14px/10px/28px)
- `resolveTheme(baseId, tweaks)` merges direction + tweak overrides

**Why**: Single source of truth for all visuals; enables runtime switching between directions and tweak combinations without code changes.

### Decision 2: Glass Card Variants
Cards support 3 styles via `cardStyle` token: `glass` (blur+border), `flat` (solid surface), `bordered` (transparent with border).

**Why**: Flexibility to use glass cards in content areas and flatter cards in chrome/backgrounds while maintaining visual coherence.

### Decision 3: StepChart Primitive
The `StepChart` component draws stepped (default), linear, smooth, or area variants based on `theme.chartStyle`.

**Why**: Stepped charts communicate discrete training data better; removes the "cheap smooth spline" association from the old design.

### Decision 4: Screen Structure
Each screen is a separate component receiving `theme` prop. Navigation state managed by parent App shell.

**Screen list:**
- `HomeScreen` — Today view
- `PlansScreen` / `PlanDetail` / `TemplateEditor` — Plan management
- `ProgressScreen` / `ExerciseDetail` / `TrendsScreen` — PR dashboard
- `BodyScreen` — Body composition
- `ProfileScreen` / `ConverterSheet` / `GuideScreen` / `AccountScreen` — Settings

**Why**: Clean separation, each screen can be developed/tested independently.

### Decision 5: Primitives Reuse
Shared components: `Card`, `Eyebrow`, `SectionTitle`, `BigNum`, `Delta`, `Chip`, `Segmented`, `Btn`, `Divider`, `StepChart`, `Sparkline`, `Ring`, `AppTabBar`, `Icons`.

**Why**: DRY; consistent visual language across all screens.

## Risks / Trade-offs

- **[Risk] Glassmorphism performance** → Mitigation: Use `backdropFilter: blur(12px)` only on key surfaces; consider disabling on lower-end devices
- **[Risk] Many font families loaded** → Mitigation: Use only the font families needed per direction; lazy-load if needed
- **[Risk] Theme prop drilling** → Mitigation: Consider InheritedWidget or Provider for theme if nesting becomes deep (likely not needed with flat screen structure)
- **[Trade-off] 3 directions × many tweak combos = test matrix** → Accept as design system cost; automated screenshot tests recommended
