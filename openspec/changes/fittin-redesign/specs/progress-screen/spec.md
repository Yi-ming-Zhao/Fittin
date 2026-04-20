# Progress Screen

## Overview

PR dashboard showing estimated 1RM per lift, strength progression charts, and milestones.

## Screens

### PR Dashboard

```
┌────────────────────────────────────┐
│ Performance                         │
│ PR dashboard                        │
│ Peak strength benchmarks, derived...│
│ [Estimated 1RM] [Actual PR]         │
├────────────────────────────────────┤
│ ┌──────────────────────────────────┐│
│ │ Squat                             ││
│ │ 139.3 kg                         ││
│ │ ▲ +11.4 kg         [Sparkline]  ││
│ │                    18 sessions    ││
│ └──────────────────────────────────┘│
│ ...Bench, Deadlift, OHP...         │
│ Strength progression                │
│ ┌──────────────────────────────────┐│
│ │ [Squat][Bench][Deadlift][OHP]   ││
│ │ Competition Squat                ││
│ │ Mar 12 — Apr 16                  ││
│ │ [StepChart with y-labels]        ││
│ │ Latest    30d Δ    Sessions      ││
│ │ 139.3     +11.4      18         ││
│ └──────────────────────────────────┘│
│ Recent milestones           [View all]│
│ ┌──────────────────────────────────┐│
│ │ ✓ Competition Squat e1RM 129.7kg││
│ │   Mar 28                         ││
│ │ ✓ Deadlift e1RM 150.7kg Apr 02  ││
│ │ ✓ Bench e1RM 82.4kg   Apr 02    ││
│ └──────────────────────────────────┘│
└────────────────────────────────────┘
```

### Exercise Detail

```
┌────────────────────────────────────┐
│ ← Progress                          │
│ Exercise                            │
│ Competition Squat                   │
│ 139.3 kg · estimated 1RM            │
│ ┌──────┐ ┌──────┐ ┌──────┐         │
│ │ e1RM │ │ 30dΔ │ │Sessions│       │
│ │139.3 │ │+11.4 │ │  18   │        │
│ └──────┘ └──────┘ └──────┘        │
│ Strength trends                     │
│ 1RM(accent) 3RM(dim) 5RM(muted)    │
│ [3-layer StepChart overlay]         │
│ Session history                     │
│ ┌──────────────────────────────────┐│
│ │ Apr 16  3×6 @ 110kg  e1RM 139.3 ││
│ │ Apr 12  5×5 @ 100kg  e1RM 135.0 ││
│ │ Apr 08  3×6 @ 105kg  e1RM 132.1 ││
│ │ Apr 04  5×5 @ 95kg   e1RM 128.5 ││
│ └──────────────────────────────────┘│
└────────────────────────────────────┘
```

- 3RM/5RM charts overlaid at reduced opacity (fgMuted/fgDim)
- 1RM chart uses accent color, full opacity

### Trends & Analytics

```
┌────────────────────────────────────┐
│ ← Progress                          │
│ Insights                            │
│ Trends & analytics                  │
│ Training consistency                 │
│ [Week] [Month] [Plan]               │
│ Calendar grid (8 weeks)             │
│ Heavy session: accent fill          │
│ Accessory: accent 40% opacity       │
│ Rest: border only                   │
│ Muscle load (sets/week)             │
│ ┌──────────────────────────────────┐│
│ │ Legs   35/25 ████████░░ [OVER] ││
│ │ Chest  18/20 ████████░░        ││
│ │ Back   14/20 ██████░░░░        ││
│ │ ...                              ││
│ └──────────────────────────────────┘│
│ Anatomical load                     │
│ [Hatched placeholder]               │
└────────────────────────────────────┘
```

## Fixed Issues

- Mint "Estimated 1RM" segmented control removed (plain segmented: Estimated 1RM | Actual PR)
- Red smooth spline charts replaced with stepped
- Neon 3-line chart replaced with stepped overlay (1RM accent, 3RM dim, 5RM muted)
