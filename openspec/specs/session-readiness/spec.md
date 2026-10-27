# session-readiness Specification

## Purpose
Keep saved Agent configuration usable and preserve application state across ordinary data refreshes without weakening account isolation.

## Requirements

### Requirement: Configured Agent can run
The Agent SHALL accept a complete saved URL, model and available key without requiring a prior connection test. Loading settings MUST NOT render an unconfigured empty state. Unchanged saves SHALL retain capability verification; changed provider identity or key SHALL invalidate it. Keys MUST retain existing native-secure/Web-memory-only storage semantics.

#### Scenario: Saved provider has not been tested
- **WHEN** complete settings are restored without a verified capability flag
- **THEN** the composer and runtime accept requests without redirecting to configuration

#### Scenario: Save after successful test
- **WHEN** the user saves unchanged provider settings
- **THEN** the stored verification is retained

### Requirement: Startup is not a data refresh barrier
After becoming ready for an identity, the app SHALL keep its shell mounted through same-identity data refreshes and transient validation errors. The initial splash SHALL appear only before the first successful opening. Actual identity changes MUST isolate the previous shell until hydration completes, using a normal account-loading state rather than replaying startup branding.

#### Scenario: Training or sync invalidates data
- **WHEN** the current user's dashboard data refreshes after startup
- **THEN** the current screen and local widget state remain mounted with no startup splash

#### Scenario: Switch identity
- **WHEN** the current account changes
- **THEN** old account content is not visible while the new scope hydrates
