# Home Screen (Today)

## Overview

The home screen shows the current training state: active session progress, cycle stats, and recent e1RM data with activity chart.

## Layout

```
┌────────────────────────────────────┐
│ [Date]              Week 1 · Day 4│
├────────────────────────────────────┤
│ Next session card                   │
│ ┌──────────────────────────────────┐│
│ │ Next session          In progress│
│ │ Squat & Pull                      │
│ │ TSA Intermediate · W1 D4          │
│ │ ████████░░░░░░░░  3/5 exercises  │
│ │ Up next                           │
│ │ Competition Squat · T1             │
│ │ Week 1 · 3×6+ @ 0.6    [Resume]  │
│ └──────────────────────────────────┘│
├────────────────────────────────────┤
│ ┌─────────────┐ ┌─────────────────┐ │
│ │ Cycle 9%    │ │ Squat e1RM      │ │
│ │ █░ 9%       │ │ 139.3 kg       │ │
│ │ W1/D4 · 4/4 │ │ [sparkline] +11.4│ │
│ └─────────────┘ └─────────────────┘ │
├────────────────────────────────────┤
│ Activity card                       │
│ ┌──────────────────────────────────┐│
│ │ Activity        Mar 12 — Apr 16  ││
│ │ Competition Squat                ││
│ │ [StepChart]                      ││
│ │ Latest: 139.3kg    12 sessions   ││
│ └──────────────────────────────────┘│
├────────────────────────────────────┤
│ ┌─────────────┐ ┌─────────────────┐ │
│ │ Switch plan→│ │ See all PRs →  │ │
│ └─────────────┘ └─────────────────┘ │
└────────────────────────────────────┘
```

## Components

- **Top meta row**: Date string (left), Week/Day (right)
- **Session card**: Hero card with "In progress" dot, session name, progress strip, "Up next" info + Resume CTA
- **Cycle card**: 9% progress bar, "Week 1 / 8 · Day 4 / 4"
- **Squat e1RM card**: Big number, sparkline, delta chip (+11.4 kg 30d)
- **Activity card**: Exercise name, step chart, latest value + session count
- **Quick actions**: 2-column grid, "Switch plan" and "See all PRs"

## States

- Session card shows "In progress" dot when active workout exists
- Progress strip shows completion percentage (3/5 exercises = 60%)
- Delta shows ▲ for positive, ▼ for negative, colored with accent (positive) or fgDim (negative)
