## Purpose

Define the shared spacing, typography, depth, and compositional rhythm rules that shape the app's premium minimalist layout system.

## Requirements

### Requirement: Elevated Whitespace System
All screen layouts MUST utilize generous margins and paddings, removing dense boundaries to separate core content blocks cleanly. Primary focus elements MUST be vertically and horizontally distinct from secondary info.

For premium minimal screens, whitespace MUST work together with tonal layering so the result feels composed and high-end rather than empty.

#### Scenario: Viewing a dense workout list
- **WHEN** multiple overlapping elements compete for attention on screen
- **THEN** the layout cleanly separates active tasks with padding spaces instead of heavy dividers.

### Requirement: Unified Sans-Serif Typography
The app MUST implement a modern geometric sans-serif font family (e.g., Inter, Outfit, or Manrope) uniformly across all headings and body copy, prioritizing readability in workout conditions.

Primary workout values, analytics highlights, and key settings labels MUST use stronger type hierarchy than surrounding support text.

#### Scenario: Reading targets mid-workout
- **WHEN** the user needs to glance at the current session's rep/weight targets quickly
- **THEN** the type is clean, highly legible, and properly prioritized by weight and size.

### Requirement: Premium Dark Layout Hierarchy
The workout logger, analytics screen, and profile/settings screen MUST use a premium dark hierarchy with at least three visual depth levels:
- page background
- secondary surface modules
- primary focus module

The system MUST avoid presenting these screens as a single uniform black field.

#### Scenario: Opening the progress analytics screen
- **WHEN** the analytics page loads
- **THEN** the background, hero summary area, and supporting cards are visually separated through tone, framing, or material treatment.

### Requirement: Non-Flat Module Interiors
Premium surfaces MUST NOT treat all interior content with the same spacing, brightness, and weight. Each major module MUST distinguish:
- primary heading/value
- supporting description or metadata
- interactive controls or actions

#### Scenario: Viewing a plan card
- **WHEN** the user reads a plan card in the library
- **THEN** the title, description, metadata chips, and action row are clearly differentiated rather than appearing as one large undivided dark box.

### Requirement: Editorial Rhythm Across Stacked Content
Long vertically stacked screens MUST introduce intentional rhythm through module size variation, grouped subsections, and focal interruptions rather than repeating one card recipe.

#### Scenario: Scrolling through analytics or plan management
- **WHEN** the user scrolls through repeated content modules
- **THEN** the page maintains hierarchy and premium rhythm instead of feeling like a monotonous stack of identical dark rectangles.

### Requirement: Compact Screen Action Hierarchy
Compact layouts MUST preserve one visually dominant task, keep destructive or secondary controls subordinate, and use responsive wrapping or stacking when translated labels or large text no longer fit in one row. Fixed card heights MUST NOT clip business values or action labels.

#### Scenario: Dense translated content on a short phone
- **WHEN** a data-rich card or action group is shown at 320 by 568 logical pixels in either supported language
- **THEN** its primary value and primary action remain readable and reachable
- **AND** secondary metadata wraps, collapses or moves below without overlapping adjacent content.

#### Scenario: Tall phone has sparse content
- **WHEN** a loading, empty or short-content page is shown on a tall phone
- **THEN** the status appears near the page's established content start and leaves room for the next action
- **AND** it is not centered in a way that disconnects it from the page header or bottom navigation.
