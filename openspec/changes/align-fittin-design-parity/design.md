## Context

The source design is the Claude/Fittin prototype bundled in `Fittin-design.zip`, especially `theme.jsx`, `primitives.jsx`, `screens/home.jsx`, `screens/plans.jsx`, `screens/progress.jsx`, and `screens/body-profile.jsx`. The archived `2026-04-21-fittin-redesign` change provides prior intent, but this change is the implementation pass for full visual parity.

## Decisions

### Shared Tokens First

Flutter components should consume `FittinTheme` rather than hardcoding colors, fonts, radii, or density. The default runtime state should represent the prototype's Editorial Mono direction: warm black background, bone foreground/accent, Fraunces display/numerics, Inter UI, step charts, and glass cards.

### Prototype-Matched Primitives

Repeated UI should be implemented once through shared primitives:

- Glass cards: prototype-like surface opacity, 20px saturation blur, 0.5px border, no heavy glow.
- Typography: 10px uppercase eyebrows, display section titles, tabular big numbers, compact deltas.
- Controls: pill chips/segmented controls/buttons with accent fill only for active/primary states.
- Charts: stepped paths by default, subtle grid, dots only at first/middle/last points.
- Bottom nav: 5 text tabs in a 52px glass pill, with active tab filled by accent.

### Screen Parity Without Behavior Changes

Each primary tab should retain real app data and navigation while matching the prototype's layout. Where the prototype uses static demo values, map existing providers into the same visual structure rather than introducing mock data.

### Visual Iteration Loop

After implementation batches, run Flutter checks and inspect the running local app with Computer Use against the prototype. Fix visible overflow, cramped controls, inconsistent surfaces, or chart style regressions before marking tasks complete.

### Subpage And Dialog Completion

All non-root routes must use the same back control: chevron-left icon, compact text label when helpful, transparent background, prototype typography, and consistent hit target. The visual parity pass includes directly reachable subpages and transient UI, including active training, workout records, editor sheets, account/profile children, share/import, training guide, PR details, milestone history, body metric dialogs, weight tools, and training max setup dialogs.

### Backend Auth Configuration

Local development may still fall back to `http://127.0.0.1:8081` when reachable. Production Web/Android builds must pass `--dart-define=BACKEND_URL=https://api.yimelo.cc`. Auth failures from unreachable backend URLs must be converted into actionable user-facing messages rather than raw `ClientException` or `SocketException` text.

## Risks

- Font loading and glass blur may affect web startup or rendering; keep existing Google Fonts dependency and avoid adding new dependencies.
- Some widget tests may assert old text/layout assumptions; update only tests whose expectations conflict with the new visual contract.
- Existing local preserved work may overlap redesign files; keep those changes unless they directly conflict with the parity requirements.
