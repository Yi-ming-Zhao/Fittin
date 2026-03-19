## Why

The current progress tracking in Fittin v2 is skeletal. Users need to visualize their strength gains, physical changes, and training consistency to stay motivated. By introducing a "Progress Tracking" module, we transition from a simple logger to a comprehensive training companion that provides actionable data insights.

**Visual Alignment**: This module MUST strictly adhere to the "Premium Minimal" aesthetic implemented in the current Home Dashboard. The Stitch-inspired layouts are intentional choices designed to harmonize with the existing glassmorphism, layered surfaces, and high-contrast typography of our current home screen.

## What Changes

We are introducing a comprehensive progress suite across four key areas:
1.  **PR Dashboard**: A high-level overview of maximum strength (1RM) and significant training achievements.
2.  **Exercise Deep Dive**: Granular analysis for individual exercises, including volume trends and strength progression across different rep ranges.
3.  **Body Metrics**: A dedicated space for tracking body composition (weight, body fat, dimensions) and visual progress via photos.
4.  **Advanced Analytics**: Long-term consistency tracking (Heatmaps) and structural load analysis (Muscle Group Volume distribution).

## Capabilities

### New Capabilities
- `pr-dashboard`: High-level summary of Estimated 1RM progression for big lifts and a feed of training milestones.
- `exercise-deep-dive`: Specific analysis screen for individual exercises with 1RM/3RM/5RM trend overlays and session history.
- `body-metrics-tracker`: Tracking for physical measurements (weight, fat, waist) and side-by-side progress photo comparison.
- `advanced-training-analytics`: Consistency heatmaps (90 days), horizontal volume distribution bars per muscle group, and anatomical training load visualization.

### Modified Capabilities
- `progress-analytics`: The current analytics screen will be refactored to serve as the entry point for these new detailed modules.

## Impact

- **UI**: New screens for Deep Dive, Body Metrics, and PR details. Implementation of several custom chart types (Multi-line graphs, Heatmaps, Bar charts, Anatomical diagrams).
- **Data**: New local datastore collections for body metrics and progress photo metadata.
- **Logic**: Backend calculations for E1RM trends across different session types.
