## Context

The homepage already expresses the strongest visual system in the app: generous spacing, rounded low-contrast cards, small uppercase section labels, soft borders, and a clear primary-focus-first hierarchy. The active workout screen, analytics screen, and profile/settings screen currently diverge from that system, using more default scaffold structures, denser layouts, and inconsistent section framing.

This change is mostly presentational, but it spans several high-traffic screens and must preserve the fast logging behavior, localized labels, and existing analytics interactions. The goal is not a redesign of the app's information architecture, but a normalization of its visual language.

## Goals / Non-Goals

**Goals:**
- Bring the active session, progress analytics, and profile/settings screens into the same visual family as the home dashboard.
- Introduce shared patterns for screen headers, section labels, card containers, grouped content blocks, and action placement.
- Preserve current functionality while improving readability, hierarchy, and perceived quality.
- Keep the active workout page fast to operate and compatible with the zero-typing flow.

**Non-Goals:**
- Do not redesign the home dashboard itself.
- Do not change navigation structure or workflow semantics.
- Do not add new product features beyond what is needed to support a unified presentation.
- Do not introduce a heavy component framework or remote design-token system.

## Decisions

### 1. Unify around a reusable “dashboard surface” language
All three screens will adopt the same design vocabulary already seen on the homepage:
- outer page padding with generous top rhythm
- small uppercase section labels for grouping
- soft surface cards with large radii and subtle borders
- stacked sections instead of dense full-bleed lists
- strong first card / primary object, then secondary modules below

Alternative considered:
- Rebuilding the homepage to match the denser screens would be cheaper, but it would discard the strongest existing design direction.

### 2. Keep each screen’s functional structure, but restage it visually
We will not force all pages into identical content shapes. Instead:
- active session remains an operational workspace, but gets a calmer hero header, grouped exercise rail, and section-based set list layout
- analytics remains data-driven, but becomes more card-led and less form-like
- profile/settings remains a configuration screen, but uses section cards and dashboard-style grouping rather than plain tiles

Alternative considered:
- A literal one-layout-fits-all approach would reduce design work, but would harm usability for task-heavy pages like the workout logger.

### 3. Introduce shared presentation helpers before polishing individual screens
Implementation should first create shared wrappers/tokens for:
- page shell padding
- section eyebrow labels
- soft card surface container
- compact stat card
- emphasized CTA row or sticky action area

Then the three target screens can be migrated to those primitives.

Alternative considered:
- Styling each screen independently would be faster initially but would recreate drift after the next feature change.

### 4. Preserve zero-typing ergonomics in the active workout redesign
The logging page will remain optimized for fast thumb interactions. Visual unification must not reduce hit targets, add extra taps, or bury the conclude/save action.

Alternative considered:
- Making the workout page look more editorial would align visually, but would directly hurt the core training flow.

### 5. Use lightweight motion to connect state changes across screens
We will reuse and extend the existing premium micro-animation direction:
- press feedback on surface cards and chips
- smoother selection transitions for exercise rail and setting choices
- subtler sheet/card entry motion where appropriate

Alternative considered:
- Leaving motion inconsistent would preserve behavior but keep the redesigned pages feeling mechanically disconnected from the home screen.

## Risks / Trade-offs

- [Over-unifying reduces task efficiency] → Keep active session interactions large, sticky, and action-oriented even while updating layout and surfaces.
- [Shared wrappers become too generic] → Limit abstractions to a few stable primitives and keep screen-specific composition local.
- [Analytics page becomes visually cleaner but less information-dense] → Use progressive disclosure: summary cards first, deeper detail in cards/sheets.
- [Profile page still feels empty after cleanup] → Add grouped setting sections and account summary framing instead of a single raw language block.

## Migration Plan

No data migration is required. The work is presentation-focused. Rollout is safe because the redesign sits on top of existing data and provider flows. If needed, the screen-level refactors can be reverted independently without affecting training data or analytics computation.

## Open Questions

- Whether the active session should adopt a floating translucent header or a fixed dashboard-style hero block.
- Whether analytics detail should stay as a bottom sheet or move to a full drill-down screen in a later iteration.
- Whether settings should add a lightweight profile summary card now or wait for future account features.

## Wireframe

```text
Active Session
┌──────────────────────────────────────┐
│ Day 1 / Workout Hero Card            │
│ Lift name, stage, quick stats        │
├──────────────────────────────────────┤
│ EXERCISES                            │
│ [T1 Squat] [T2 Row] [T3 Curl]        │
├──────────────────────────────────────┤
│ SETS                                 │
│ soft card                            │
│ soft card                            │
│ soft card                            │
├──────────────────────────────────────┤
│ sticky full-width conclude CTA       │
└──────────────────────────────────────┘

Progress Analytics
┌──────────────────────────────────────┐
│ Progress Analytics                   │
│ formula chip + summary cards         │
├──────────────────────────────────────┤
│ ALL EXERCISES                        │
│ progress card                        │
│ progress card                        │
│ progress card                        │
└──────────────────────────────────────┘

Profile / Settings
┌──────────────────────────────────────┐
│ Profile Summary Card                 │
├──────────────────────────────────────┤
│ SETTINGS                             │
│ language card                        │
│ theme card / future settings slots   │
└──────────────────────────────────────┘
```
