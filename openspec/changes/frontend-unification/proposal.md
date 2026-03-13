## Why

The home dashboard already establishes a stronger visual identity, but the workout logging page, progress analytics page, and profile/settings page still feel like separate products. This inconsistency makes the app feel unfinished and weakens the premium design language that the homepage already demonstrates.

## What Changes

- Unify the active workout, progress analytics, and profile/settings screens around the same layout, card, spacing, and visual hierarchy used by the home dashboard.
- Replace dense or utility-style sections with calmer, premium containers, stronger section grouping, and more intentional typography.
- Standardize shared UI tokens for page headers, section labels, card surfaces, and action emphasis so these screens no longer reinvent their own styles.
- Preserve current functionality while redesigning presentation structure, spacing, and interaction polish.
- Modify the existing design-system-related capabilities so the non-home screens follow the same visual language already defined for the dashboard.

## Capabilities

### New Capabilities
- `frontend-unification`: shared surface, spacing, header, and section patterns for non-home primary app screens.

### Modified Capabilities
- `minimalist-layout-system`: extend layout rules from the dashboard to workout logging, analytics, and profile screens.
- `premium-micro-animations`: apply the existing interaction polish consistently across these redesigned screens.
- `zero-typing-ui`: preserve low-friction workout logging behavior while redesigning the active session presentation.

## Impact

- Affected code: active session screen, progress analytics screen, profile/settings screen, shared presentation widgets, and app-level styling helpers.
- Affected UX: hierarchy, spacing, surface treatment, section labeling, button emphasis, and cross-screen consistency.
- Affected tests: widget coverage for navigation targets and redesigned screen structure.
