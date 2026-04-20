# Body Screen

## Overview

Body composition tracking: weight, body fat, and measurements over time.

## Layout

```
┌────────────────────────────────────┐
│ Composition                         │
│ Body metrics                        │
│ Track physical change alongside...   │
│ ┌──────────────────────────────────┐│
│ │ Body weight                      ││
│ │ 72.5 kg              [kg] [lb]   ││
│ │ ▲ -2.3 kg  last 30 days          ││
│ │ [StepChart sparkline]            ││
│ │ Mar 17              Apr 16       ││
│ └──────────────────────────────────┘│
│ ┌──────┐ ┌──────┐ ┌──────┐        │
│ │ BODY │ │ WAIST│ │CHEST │        │
│ │ 16.2%│ │  78cm│ │ 102cm│        │
│ │ -0.4 │ │ -0.8 │ │ +0.3 │        │
│ └──────┘ └──────┘ └──────┘        │
│ ┌──────────────────────────────────┐│
│ │ Log a check-in                   ││
│ │ Weight, body fat, waist...  [Add]││
│ └──────────────────────────────────┘│
│ Measurement log                      │
│ ┌──────────────────────────────────┐│
│ │ Apr 16 72.5kg  16.2%  morning  ││
│ │ Apr 09 73.0kg  16.4%  morning  ││
│ │ Apr 02 73.7kg  16.8%  morning  ││
│ │ Mar 26 74.2kg  17.1%  morning  ││
│ └──────────────────────────────────┘│
└────────────────────────────────────┘
```

## Components

- **Weight hero card**: Large 52px number, unit segmented control, delta chip, sparkline chart, date range
- **3-metric row**: Body fat %, waist cm, chest cm — each with delta
- **Log CTA card**: "Log a check-in" description + Add button
- **Measurement log**: Date | Weight | Body fat | Note (morning/evening)

## States

- Delta shows ▲/▼ with accent color for positive, fgDim for negative
- Below-target metrics show negative delta in accent color
- kg/lb segmented switches unit throughout card
