## Context

The app currently resolves Material widgets from `themeProvider`/`AppColors` while most product surfaces resolve `FittinTheme` from a separate in-memory provider. This permits dialogs, form fields, navigation, charts, and custom cards to disagree, and neither appearance path restores the user's choice before first paint. Literal colors remain in training states, chart series, anatomy rendering, overlays, reusable primitives, and body/history components.

The Today screen always renders its compact hero and fixed 6 px section rhythm, even on a tall Android viewport. The Body screen calculates a wide-layout flag but renders three metric columns for both branches, compressing three cards into roughly 110 px each on a 390 px device. The release must preserve touch behavior, bilingual content, stable Android signing, and direct Alibaba Cloud hosting.

Color architecture follows semantic-role guidance from Material 3 and the usage-level discipline of Radix Colors: components ask for a role, not a hue. The palette design deliberately excludes cyan/teal, uses dominant neutrals with one controlled accent, and reserves stronger chroma for actions, selected data, and status feedback.

## Goals / Non-Goals

**Goals:**

- Make a single persisted palette selection drive both Material and custom Fittin components before the first app frame.
- Cover every user-facing color role with named semantic tokens and document intentional fixed-domain palettes.
- Provide five coherent, refined palettes with readable text, borders, charts, and states.
- Expose an immediate bilingual palette chooser in the My/Settings page.
- Give Today a relaxed tall-screen composition and a compact, scrollable short-screen composition.
- Reflow Body metrics into a breathable mobile 2+1 layout and tune chart/section density to the safe viewport.
- Verify every palette on 390x926 and 390x568 viewports, then ship Android and web version 1.0.9.

**Non-Goals:**

- A free-form hue picker or per-token color editor. Curated complete palettes prevent unreadable or visually inconsistent combinations.
- User-selectable typography, chart geometry, or density in this release.
- Recoloring exported share artwork or standardized Olympic plate identification arbitrarily. These remain named domain palettes so their fixed behavior is explicit.
- Backend schema or training-data changes.

## Decisions

### One palette ID is the appearance source of truth

Introduce `FittinPaletteId` and store its stable string key in `SharedPreferences`. `FittinThemeNotifier` receives the already-loaded preferences object at app boot, resolves its initial state synchronously, applies changes optimistically, and then persists them. `FittinApp` watches the same resolved Fittin theme used by product widgets and derives `ColorScheme`/`ThemeData` from it. The legacy `themeProvider`/`AppColors` path is removed.

Alternative considered: retain independently selectable direction, background, and accent enums. That creates combinations that have not been contrast-checked and keeps the current split-brain behavior, so complete palettes are safer and simpler.

### Semantic tokens cover presentation meaning, not implementation location

The resolved theme exposes these categories:

- Canvas and surfaces: canvas, deep canvas, solid/elevated/selected surfaces.
- Content: primary, secondary, muted, disabled, and inverse text/icon colors.
- Structure: subtle/default/strong borders, dividers, focus ring, soft/strong shadow, and scrim.
- Brand interaction: accent, on-accent, accent container, pressed accent, selected/pressed/disabled overlays.
- Status and workout interaction: success, warning, danger, info; completed, skipped, current, upcoming; log, skip, and navigation gesture feedback.
- Data visualization: grid, axis, labels, selection, tooltip, and six ordered series colors.
- Anatomy: inactive body, stroke, low/high load, and selected muscle.
- Domain-fixed palettes: Olympic bar/plate materials and export canvas/ink.

Transparent itself remains literal because it is absence of paint. Standardized plate colors and export black/white remain centralized named constants rather than user-theme tokens. All other reusable UI literals are migrated or explicitly documented.

### Five complete curated palettes

The initial registry contains:

| Palette | Character | Canvas | Surface | Accent | Primary text | Supporting accent |
| --- | --- | --- | --- | --- | --- | --- |
| Obsidian Brass | refined black, warm metal | `#090806` | `#171512` | `#D8B56B` | `#F7F1E5` | `#A58AD5` |
| Midnight Cobalt | precise navy, cool light | `#070A12` | `#101829` | `#8FB4FF` | `#F4F7FF` | `#C6A7FF` |
| Bordeaux Velvet | oxblood, rose and champagne | `#10070A` | `#211117` | `#E3A3AF` | `#FCEFF2` | `#D7B978` |
| Porcelain Ink | warm paper, ink and vermilion | `#F3EEE5` | `#FBF8F2` | `#9E3A32` | `#211D19` | `#294873` |
| Espresso Ember | roasted brown, restrained flame | `#100B08` | `#20150F` | `#E98A52` | `#F7EBDD` | `#BFA4D8` |

Each palette includes all tokens, not only the six preview swatches. Automated tests check palette completeness, prohibit cyan/teal hues, and require contrast of at least 4.5:1 for normal primary text and on-accent content, with at least 3:1 for large/secondary content and structural emphasis where applicable.

### Appearance is edited inline under My

Add an Appearance section ahead of lower-priority utilities. It contains a concise explanation that backgrounds, cards, text, lines, charts, and feedback update together, followed by horizontally scrollable tactile palette previews. A preview shows its canvas, surface, accent, text, and representative data colors; selection updates the entire live page immediately and exposes a check indicator plus semantics. Five previews remain reachable without making the already-long Settings page excessively tall.

Alternative considered: a separate appearance route. The user asked for an appearance bar in My, and immediate side-by-side comparison is more discoverable inline.

### Today uses bounded relaxed and compact compositions

At a safe content height of 720 px or more, Today uses the non-compact workout hero, theme-scaled 12-20 px section rhythm, slightly taller KPI/activity modules, and a less compressed quick-action row. Remaining height is distributed only within bounded gaps, avoiding both a dense center cluster and giant empty holes. Below the breakpoint, it retains compact sizes inside one vertical scroll view.

### Body uses responsive 2+1 metrics and height-aware charting

Below 520 px, body-fat and waist cards share one row and Check-ins occupies the full next row. At 520 px and above, all three share a row. The weight chart uses a shorter bounded height on short viewports and 250 px on tall viewports. Header and section spacing come from theme rhythm. Empty, partial, loading, and populated states all retain a top-anchored progress hierarchy and scroll naturally rather than jumping from a centered spinner.

## Risks / Trade-offs

- [Risk] Migrating literal colors can subtly change specialized screens. -> Keep fixed domain palettes for physical equipment/export output, add targeted widget tests, and inspect the highest-risk Today, Body, workout, chart, and Settings surfaces in every theme.
- [Risk] Light Porcelain surfaces expose assumptions that everything is black or white. -> Make it the regression palette, remove white overlays from primitives, and test Material/custom theme synchronization.
- [Risk] Async persistence could flash the default theme. -> Inject the already-loaded `SharedPreferences` instance and resolve the initial palette synchronously.
- [Risk] Tall-screen spacing can become theatrical or short-screen content can overflow. -> Bound every adaptive dimension and test through the real app shell at both target heights.
- [Risk] Five palettes multiply visual QA. -> Automate overflow/contrast/semantics checks and capture a fixed matrix of representative screens before release.

## Migration Plan

1. Add palette registry, semantic tokens, persistence, and Material-theme derivation while retaining current Obsidian-like appearance as the default.
2. Add Appearance UI and localization, then migrate reusable primitives and high-risk literal colors.
3. Implement responsive Today and Body layouts and run targeted tests.
4. Run full analysis/tests, strict OpenSpec validation, and the mobile visual matrix; iterate until all palettes pass.
5. Bump to `1.0.9+16`, push a clean commit, wait for CI, publish `v1.0.9`, synchronize 241, and deploy the direct Alibaba Cloud web build.
6. Roll back web by restoring the previous release symlink; Android users can remain on v1.0.8 if a rollback is needed because stored palette keys are additive and training data is unchanged.

## Open Questions

None. Palette naming, responsive breakpoints, persistence behavior, and release version are fixed by this design and can be tuned only within the stated visual constraints during QA.
