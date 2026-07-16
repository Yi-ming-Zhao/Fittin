# Fittin theme color inventory

This document is the maintained source for every themeable color-bearing area
in the app. Product UI asks for a semantic role from `FittinTheme`; it does not
select a hue or use literal black/white. `FittinPaletteRegistry` supplies all
roles for the five curated palettes, and `FittinTheme.colorScheme` derives the
Material scheme from the same resolved object.

## Palette contract

The stable palette identifiers are `obsidianBrass`, `midnightCobalt`,
`bordeauxVelvet`, `porcelainInk`, and `espressoEmber`. Stored identifiers must
not be renamed without a preference migration. Unknown identifiers fall back
to `obsidianBrass`.

| Presentation meaning | `FittinTheme` roles | Typical consumers |
| --- | --- | --- |
| App canvas | `bg`, `bgDeep` | Scaffolds, page backgrounds, deep backdrops |
| Surfaces | `surface`, `surfaceSolid`, `surfaceHi`, `surfaceSelected` | Cards, sheets, dialogs, menus, selected rows |
| Content | `fg`, `fgDim`, `fgMuted`, `fgFaint`, `fgInverse` | Text, icons, captions, disabled and inverse content |
| Structure | `borderSubtle`, `border`, `borderHi`, `divider`, `focusRing` | Card outlines, fields, separators, focus indicators |
| Elevation | `shadowSoft`, `shadowStrong`, `scrim` | Cards, sheets, modal barriers |
| Brand interaction | `accent`, `accentInk`, `accentDim`, `accentPressed` | Primary actions, active navigation, accent containers |
| Generic interaction | `pressedOverlay`, `selectedOverlay`, `disabledOverlay` | Ink response, selection and disabled state layers |
| Status | `success`, `warning`, `danger`, `info` and each `*Subtle` role | Notices, deltas, validation, sync and update states |
| Workout set state | `setCompleted`, `setSkipped`, `setCurrent`, `setUpcoming` | Set cards, history, progress and state labels |
| Workout gestures | `gestureLog`, `gestureSkip`, `gestureNavigate` | Swipe direction feedback and action confirmation |
| Chart chrome | `chartGrid`, `chartAxis`, `chartLabel`, `chartSelection`, `chartTooltip` | Axes, grid, labels, selection and detail surfaces |
| Chart data | `chartSeries` | Ordered multi-series charts, compact charts, legends |
| Anatomy | `anatomyBase`, `anatomyStroke`, `anatomyInactive`, `anatomySelected` | Body silhouettes and selected muscle groups |
| Load intensity | `loadLow`, `loadHigh` | Anatomy load maps and heat/intensity interpolation |

Compatibility aliases such as `canvas`, `textPrimary`, `surfaceElevated`,
`chartStroke`, and `chartDot` may be used during migration, but new reusable
components should prefer the canonical roles in the table.

## Area-to-role inventory

| App area | Required semantic roles |
| --- | --- |
| App shell and system chrome | `bg`, `fg`, `fgDim`, `borderSubtle`, `scrim` |
| Bottom navigation | `surfaceSolid`, `surfaceSelected`, `fgMuted`, `accent`, `accentInk`, interaction overlays |
| App bars, headings and section labels | `bg`/surface role, `fg`, `fgDim`, `fgMuted`, `divider` |
| Dashboard hero and KPI cards | surface roles, content roles, border roles, `accent`, status roles, shadows |
| Shared cards, tiles and list rows | `surfaceSolid`, `surfaceHi`, `surfaceSelected`, content roles, borders, overlays |
| Buttons, segmented controls and chips | `accent`, `accentInk`, `accentDim`, `accentPressed`, content roles, borders, overlays |
| Forms, sliders, switches and focus | surface roles, content roles, `border`, `borderHi`, `focusRing`, `danger` |
| Dialogs, sheets, menus and snack bars | `surfaceHi`, content roles, `divider`, shadows, `scrim`, status roles |
| Today workout states | set-state roles, gesture roles, surface/content/border roles |
| Workout history and record details | set-state and status roles, surface/content/border roles |
| Progress and PR dashboards | chart roles, status roles, surface/content/border roles |
| Interactive and compact charts | every chart role plus `fg` for primary values |
| Calendar and heat maps | `surfaceSelected`, `borderSubtle`, `chartLabel`, `loadLow`, `loadHigh`, selection overlays |
| Body metrics | chart roles, status roles, surface/content/border roles |
| Anatomy rendering | every anatomy and load role; surrounding labels use content roles |
| Plan library and editor | surface/content/border roles, `accent`, status roles, overlays |
| Exercise library and detail | surface/content/border roles, chart/anatomy roles where shown |
| Account, settings and Appearance | surface/content/border roles; previews read representative roles from each registry entry |
| Loading, empty and error states | content roles plus `info`, `warning`, or `danger` and corresponding subtle role |

## Material mapping

`FittinTheme.colorScheme` is the only Material color source. The important
mappings are:

- `primary` / `onPrimary` / `primaryContainer` map to `accent` /
  `accentInk` / `accentDim`.
- Material 3 fixed roles (`primaryFixed`, `secondaryFixed`, `tertiaryFixed`
  and their dim/on-color variants) resolve from the same accent, chart-series,
  and info roles; none inherit Flutter's default seed colors.
- Material surfaces map to `bgDeep`, `surface`, `surfaceSolid`, `surfaceHi`,
  and `surfaceSelected` in ascending emphasis, including `surfaceDim` and
  `surfaceBright`.
- `onSurface` / `onSurfaceVariant` map to `fg` / `fgDim`.
- `outline` / `outlineVariant` map to `borderHi` / `border`.
- `error` / `errorContainer` map to `danger` / `dangerSubtle`.
- Material shadow and scrim map to the matching semantic roles.

## Intentional fixed-color exceptions

These exceptions are named and centralized in `domain_color_palettes.dart`:

- `OlympicEquipmentPalette`: bar steel, collars, standardized plate identity,
  and light/dark plate labels. A theme changes the card around the barbell, not
  the represented equipment.
- `ExportPalette`: exported artwork canvas, ink, rules, and QR foreground and
  background. Exports remain predictable and printable across themes.
- `Colors.transparent`: absence of paint, including transparent app bars and
  Material surface tint. It is not a visual hue.

## Pre-Flutter launch surfaces

Android and iOS use the Obsidian Brass warm-black canvas while the native
process and Flutter engine start, preventing a white or platform-default color
flash. Web sets the same warm-black canvas before bootstrap and reads the
persisted SharedPreferences key early so Porcelain Ink can start on its light
canvas. The web manifest's browser chrome/background colors remain warm black
as a stable install-time fallback.

No other literal `Color(...)`, `Colors.black`, or `Colors.white` value is an
approved reusable-UI exception. When a new color-bearing component is added,
update this inventory, add or reuse a semantic role, and include it in palette
guard tests before merging.
