# Plans Screen

## Overview

Plan library showing all available training plans, with detail view and template editor.

## Screens

### Plans Library

```
┌────────────────────────────────────┐
│ Plan Library                        │
│ Training plans                      │
│ Built-in templates, custom copies...│
├────────────────────────────────────┤
│ [All] [Built-in] [Custom]     [+ New]│
├────────────────────────────────────┤
│ ┌──────────────────────────────────┐│
│ │ Built-in  ●Active                ││
│ │ TSA Intermediate Approach 2.0     ││
│ │ 8-week normalized intermediate... ││
│ │ [Squat Hyp.] [DL Power] [Squat]  ││
│ │ Workouts  Exercises  Running     ││
│ │   4          20          1       ││
│ └──────────────────────────────────┘│
│ ...more plan cards...               │
└────────────────────────────────────┘
```

- Filter chips: All | Built-in | Custom | New
- Plan card: kind label, active dot+text (if active), name (displayFont 22px), summary, tags, stat row
- Active indicator: 6px accent dot + "Active" text in accent color

### Plan Detail

```
┌────────────────────────────────────┐
│ ← Library    [Edit] [Switch]        │
│ Built-in                             │
│ TSA Intermediate Approach 2.0        │
│ ● Currently active                   │
│ 8-week normalized...                 │
│ ┌──────────────────────────────────┐│
│ │ Workouts  Exercises  Running     ││
│ └──────────────────────────────────┘│
│ Weekly structure                     │
│ ┌──────────────────────────────────┐│
│ │D1│ Squat Hypertrophy  5ex · 75m ││
│ └──────────────────────────────────┘│
│ ...D2, D3, D4...                    │
│ Progression                         │
│ ┌──────────────────────────────────┐│
│ │ Weeks 1–8   Intensity 60→92%    ││
│ │ [StepChart]                      ││
│ └──────────────────────────────────┘│
└────────────────────────────────────┘
```

- Back button → Library
- Edit → Template Editor
- Switch → Activate plan
- Day cards: D1-D4 with name, exercise count, duration, chevron

### Template Editor

```
┌────────────────────────────────────┐
│ ← Back    [Discard] [Save]          │
│ Template editor                     │
│ Jacked & Tan 2.0                    │
│ ┌──────────────────────────────────┐│
│ │⚠ Editing built-in creates copy   ││
│ └──────────────────────────────────┘│
│ Template card                       │
│ Name / Description / Schedule mode   │
│ Day: [D1][D2][D3][D4]               │
│ Week: [W1][W2][W3][W4][W5][W6]     │
│ ┌──────────────────────────────────┐│
│ │ W1 · D1        [Rename]         ││
│ │ Squat & Pull                    ││
│ │ Day label   Minutes             ││
│ └──────────────────────────────────┘│
│ Exercise 1 card (stacked fields)     │
│ ...fields stack, no overflow...      │
│ Stages · Week 1 · 3×6+              │
│ [Set 1 · Warm-up] [Straight]        │
│ [Set 2 · Working] [Straight]        │
│ [Set 3 · Working] [Top set]        │
└────────────────────────────────────┘
```

- Fields stack vertically (no 2-col overflow on tight rows)
- Day/Week selectors: filled accent when selected, bordered when not
- Exercise card: field grid uses 1fr 1fr but stacks properly
- Set stages: 3-column MicroField grid (Reps, Intensity, Target RPE)

## Fixed Issues from Original

- Long template names get proper space (no truncation)
- "Active" mint chip replaced with subtle 6px dot + text in accent color
- Template editor fields don't overflow (stack on narrow)
