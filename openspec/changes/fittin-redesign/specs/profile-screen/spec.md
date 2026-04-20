# Profile Screen

## Overview

Settings: account status, language selector, weight tools, training guide reference.

## Screens

### Profile / Settings

```
┌────────────────────────────────────┐
│ Profile                             │
│ Settings                            │
│ Account, language, weight tools...  │
│ Account                             │
│ ┌──────────────────────────────────┐│
│ │ Signed out                       ││
│ │ Sign in to sync plans...  [Manage]││
│ └──────────────────────────────────┘│
│ Language                            │
│ ┌──────────────────────────────────┐│
│ │ English (English)        ◉       ││
│ │ 中文 (Chinese)          ○       ││
│ │ 日本語 (Japanese)        ○       ││
│ └──────────────────────────────────┘│
│ Weight tools                        │
│ ┌──────────────────────────────────┐│
│ │ Converter defaults and bar...    ││
│ │ kg bar: 20kg     lb bar: 45lb    ││
│ │        [Open converter]          ││
│ └──────────────────────────────────┘│
│ Reference                            │
│ ┌──────────────────────────────────┐│
│ │ Training set guide        →      ││
│ │ AMRAP, top set, backoff...      ││
│ └──────────────────────────────────┘│
│ Visual                              │
│ ┌──────────────────────────────────┐│
│ │ Glass opacity          55 %      ││
│ │ [━━━━━━━●━━━━]                   ││
│ │ 0.1                    1.0      ││
│ └──────────────────────────────────┘│
└────────────────────────────────────┘
```

### Converter Sheet (Bottom Sheet)

```
┌────────────────────────────────────┐
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│ Converter                           │
│ Weight tools              [X]       │
│ [kg] [lb]                           │
│ Enter weight                         │
│ 100                                 │
│ ────────────────────────────────────│
│ ┌─────────────┐ ┌─────────────┐    │
│ │ Converted   │ │ Bar          │    │
│ │ 220.5 lb    │ │ 20 kg        │    │
│ └─────────────┘ └─────────────┘    │
│ Plate loading · per side            │
│ ┌──────────────────────────────────┐│
│ │ [bar][plate][25][20][10][10]~~ ││
│ │ 25kg  20kg  10kg  10kg          ││
│ └──────────────────────────────────┘│
└────────────────────────────────────┘
```

- Visual barbell with plates (accent/foreground alternating)
- Plate list below: 25kg, 20kg, 10kg, 10kg (per side for 100kg on 20kg bar)
- Real-time conversion as user types

### Training Guide

```
┌────────────────────────────────────┐
│ ← Settings                         │
│ Reference                           │
│ Training set guide                  │
│ Use set categories to describe...   │
│ ┌──────────────────────────────────┐│
│ │ 01  Straight set                 ││
│ │ Repeated work sets at same...    ││
│ │ • Stable volume work (3×5, 4×8) ││
│ │ • Same load across sets         ││
│ └──────────────────────────────────┘│
│ ...Top set, Backoff, AMRAP...      │
└────────────────────────────────────┘
```

- Numbered entries (01, 02, 03...)
- Display font for entry name
- Tips use accent dot bullets
- Divider lines between entries

### Account Screen

```
┌────────────────────────────────────┐
│ ← Settings                         │
│ Profile                             │
│ Account                             │
│ Sign in to sync plans...            │
│ ┌──────────────────────────────────┐│
│ │ ○ Not connected                  ││
│ │ Sync unavailable                 ││
│ │ Local dev stack at 127.0.0.1... ││
│ │    [Retry]  [Sign in]           ││
│ └──────────────────────────────────┘│
│ Local data                          │
│ ┌──────────────────────────────────┐│
│ │ Plans              4            ││
│ │ Workouts logged   42            ││
│ │ Body check-ins     8            ││
│ │ Last backup    never             ││
│ └──────────────────────────────────┘│
└────────────────────────────────────┘
```

- Shows sync connection status
- Local data stats (read-only display)
