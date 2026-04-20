# Theme System

## Overview

The theme system provides visual tokens for all UI elements. It resolves a complete theme from a base direction + optional tweaks.

## Token Categories

### Surface Colors
- `bg`: Main background color
- `bgDeep`: Deepest background (for layering)
- `surface`: Glass card background (semi-transparent)
- `surfaceSolid`: Flat card background
- `surfaceHi`: Highlighted surface (active states)
- `border`: Default border color
- `borderHi`: Highlighted border color

### Foreground Colors
- `fg`: Primary text color
- `fgDim`: Secondary/dimmed text
- `fgMuted`: Muted/tertiary text
- `fgFaint`: Faint text (placeholders)

### Accent Colors
- `accent`: Primary accent (single per direction)
- `accentInk`: Text on accent background
- `accentDim`: Dimmed accent (backgrounds, 20% opacity)

### Typography
- `displayFont`: Serif font for section titles (e.g., Fraunces, Instrument Serif)
- `uiFont`: Sans-serif for UI text (Inter, Instrument Sans)
- `numFont`: Monospace or display for numbers (JetBrains Mono, Fraunces)
- `displayWeight`: Font weight for display text (400-500)
- `numWeight`: Font weight for numbers (400-500)

### Chart
- `chartStyle`: 'step' | 'linear' | 'smooth' | 'area'
- `chartStroke`: Color for chart lines
- `chartGrid`: Color for chart grid lines
- `chartDot`: Color for chart dots

### Layout
- `radius`: Card border radius (16-22px)
- `radiusSm`: Small element radius (8-14px)
- `_density`: Computed density values (pad, gap, titleSize, rowH)

## 3 Visual Directions

### Editorial Mono
- bg: #0c0b0a, accent: #f3ece0 (bone)
- displayFont: Fraunces, numFont: Fraunces
- Warm black + bone/cream accent, no saturation

### Technical Mono
- bg: #000000, accent: oklch(0.86 0.08 118) (muted lime)
- displayFont: JetBrains Mono, numFont: JetBrains Mono
- True black + desaturated lime, all-mono numerics

### Warm Clay
- bg: #141110, accent: oklch(0.72 0.11 45) (terracotta)
- displayFont: Instrument Serif, numFont: Instrument Sans
- Warm charcoal + terracotta, editorial feel

## Tweak Overrides

- **accent**: bone | lime | terracotta | sky | plum | ember
- **bg**: trueBlack | warmBlack | charcoal | warmCharcoal
- **type**: editorial | technical | clay | neutral
- **chart**: step | linear | smooth | area
- **card**: glass | flat | bordered
- **density**: comfortable | compact

## API

```dart
Theme resolveTheme(String baseId, [Map tweaks])
```

Resolves full theme tokens by merging base direction with tweak overrides.
