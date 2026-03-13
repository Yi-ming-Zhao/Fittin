## Why

The app currently ships with one real built-in program and no way to switch the active plan from the bottom navigation. Adding a rebalanced Jacked & Tan 2.0 template now fills the missing strength-plus-physique option and makes the plan library a first-class part of the product instead of an editor side path.

## What Changes

- Add a built-in Jacked & Tan 2.0 template derived from [jacked_and_tan.xlsx](/Users/yzxbb/Desktop/Fittin_v2/jacked_and_tan.xlsx), preserving all T1 movements while reducing each training day to 2 T2 movements and 2 T3 movements.
- Rebalance the Jacked & Tan accessory selection around a strength-and-physique goal, reusing proven movements from the existing GZCLP setup where appropriate and keeping each major muscle group within 12 to 20 direct work sets per week.
- Add a plan library and switching flow on the second bottom-navigation tab so users can preview all built-in and saved plans, identify the active plan, and switch the current training plan without leaving the main app shell.
- Update active-plan persistence so the dashboard, today-workout hero card, session launch, and future training logs all resolve from the currently selected plan instance instead of assuming GZCLP is always active.

## Capabilities

### New Capabilities
- `jacked-and-tan-program-template`: Ship a built-in, rebalanced Jacked & Tan 2.0 program that is seeded alongside GZCLP and encoded as app-owned JSON data.
- `plan-library-switching`: Let users browse all available plans, preview their workout structure, and switch the active training plan from the second bottom-nav destination.

### Modified Capabilities
- `glass-bottom-nav`: The second navigation item must open the plan library/switching experience instead of acting as an inert icon.
- `today-workout-gateway`: The dashboard workout summary and session launch must resolve from the selected active plan instance, not a hardcoded GZCLP default.
- `local-datastore-schema`: Local persistence must support multiple built-in templates plus a durable active-plan/active-instance selection.

## Impact

- Affected data: built-in plan assets, template seed bootstrap, active-instance selection, and instance/template relationship records.
- Affected code: repository/storage APIs, seed loaders, dashboard navigation shell, plan library screens, and today-workout/session gateway services.
- Affected UX: bottom navigation behavior, plan preview/switch interactions, and the default built-in program catalog shown to new users.
