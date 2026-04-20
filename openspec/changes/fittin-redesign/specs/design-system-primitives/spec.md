# Design System Primitives

## Overview

Shared UI components used across all screens. All primitives receive a `theme` object for consistent styling.

## Component List

### Card
- Variants: `glass` (blur + border), `flat` (solid surface), `bordered` (transparent + border)
- Props: `theme`, `children`, `style`, `padding`, `noPad`, `onClick`
- Glass: `backdropFilter: blur(20px) saturate(140%)`, `border: 0.5px solid border`, `box-shadow: inset 0 1px 0 rgba(255,255,255,0.04)`

### Eyebrow
- Uppercase label, 10px, font-weight 500, letter-spacing 1.8
- Color: `fgMuted`

### SectionTitle
- Display font, variable size via `theme._density.titleSize`
- Letter-spacing: -1 (serif) or -0.5 (mono)

### BigNum
- Large number display with optional unit
- Props: `theme`, `value`, `unit`, `size` (default 40), `style`
- `fontVariantNumeric: tabular-nums` for aligned digits

### Delta
- Shows change value with ▲/▼ indicator
- Props: `theme`, `value`, `unit`
- Positive: accent color, Negative: fgDim color

### Chip
- Pill-shaped tag/category
- Props: `theme`, `children`, `active`, `onClick`, `tone`
- Active: filled with accent; inactive: bordered transparent

### Segmented
- Horizontal segmented control
- Props: `theme`, `options` (array of strings or `{value, label}`), `value`, `onChange`
- Active segment: accent fill; inactive: transparent

### Btn
- Button with variants: `primary` (accent fill), `secondary` (surfaceHi), `ghost` (transparent)
- Props: `theme`, `children`, `variant`, `size` (sm/md), `onClick`, `icon`, `block`

### Divider
- 0.5px horizontal line, `border` color

### StepChart
- SVG-based chart with variants: `step` (default), `linear`, `smooth`, `area`
- Props: `theme`, `data` (number array), `width`, `height`, `showDots`, `showGrid`, `yLabels`
- Grid lines at 0%, 33%, 66%, 100%
- Dots shown at first, middle, last data points only

### Sparkline
- Compact StepChart without dots or grid
- Props: `theme`, `data`, `width`, `height`

### Ring
- Circular progress indicator (thin stroke, replaces glowing ring)
- Props: `theme`, `value`, `max`, `size` (default 120), `strokeW` (default 2), `children`

### AppTabBar
- 5-tab bottom navigation bar with glass background
- Props: `theme`, `active` (tab id), `onChange`
- Tabs: Today, Plans, PR, Body, Me
- Glass: blur(24px) saturate(140%), border 0.5px, border-radius 999

### ScreenHeader
- Top section with eyebrow + section title + optional subtitle/trailing
- Props: `theme`, `eyebrow`, `title`, `subtitle`, `trailing`

### Icons (set)
Minimal line icons: home, plans, progress, body, profile, chevR, chevL, plus, arrow, play, edit, save, close, tune, check
