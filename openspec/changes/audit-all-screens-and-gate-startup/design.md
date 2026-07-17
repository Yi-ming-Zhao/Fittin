## Context

`main()` finishes local persistence creation and built-in seeding before `runApp`, but the authenticated user is restored later by `authStateProvider`. `SyncLifecycleGate` currently renders `AppShellScreen` immediately and only starts signed-in hydration after the first frame. During that interval, `currentUserIdProvider` is `null`, so plan and dashboard providers can query the wrong owner scope and briefly publish a real `AsyncError`. Hydration then invalidates them and the correct plan appears, producing the reported false “unable to load” flash.

The v1.0.9 theme and primary-tab work has already shipped. This follow-up must preserve the five semantic palettes, the prohibition on cyan/teal, local-first operation, touch-first workout gestures, and the existing stable Android signer while auditing every other reachable surface.

## Goals / Non-Goals

**Goals:**

- Keep the app shell hidden until stored authentication, the first signed-in hydration attempt, and first-frame plan/dashboard reads have settled for the correct owner scope.
- Present a distinctive but restrained Fittin startup animation that continues the selected palette from the native/web launch surface.
- Remain usable when signed out or temporarily offline, with bounded waiting and explicit recovery choices for genuine startup failures.
- Produce a route-and-state inventory and inspect every reachable screen, subpage, sheet, dialog, and major async state at 390x926 and 390x568.
- Apply only reproducible fixes and publish them as the next signed release after automated and visual verification.

**Non-Goals:**

- Hiding real data corruption or backend failures indefinitely behind a splash screen.
- Replacing Flutter's native platform launch screen, changing backend APIs, or changing training-data schemas.
- Redesigning pages that pass the audit merely to create visual churn.
- Adding a third-party animation dependency or a fixed network delay to every launch.

## Decisions

### Readiness is a state gate, not a timer

Add an application startup coordinator above the app shell. It awaits the first resolved authentication state. Signed-out local-first users proceed without a network dependency. Signed-in users run one initial hydration attempt, then prewarm the current plan, Today summary, and home dashboard in the resolved user scope before the shell is revealed.

The startup presentation has a short minimum dwell so the transition does not flash, but readiness work remains the controlling condition. Blocking work is bounded; if authentication or prewarming fails, the user sees a themed recovery state with Retry and Continue locally instead of an infinite animation. A failed cloud hydration that still leaves readable local data is degraded-ready, not fatal.

Alternative considered: suppress the workout error card for a few seconds. That would hide one symptom while allowing other dashboard providers to query the wrong owner scope, so it is rejected.

### Initial synchronization and lifecycle synchronization have separate responsibilities

The startup coordinator owns exactly one initial restore/hydration attempt. The existing lifecycle listener remains responsible for later sign-in, sign-out, and foreground transitions, but it skips its post-frame initial sync when startup already completed it. This prevents duplicate syncs and the resulting provider churn.

### The animation is an abstract loaded bar, built from semantic primitives

The Flutter splash uses a compact abstract barbell mark: a central bar, paired plates, and a restrained settling/breathing motion. Canvas, surfaces, content, structure, and accent colors come exclusively from the resolved theme. Motion is disabled or reduced when the platform requests reduced animation. The screen includes localized status copy and no percentage that could misrepresent network progress.

Alternative considered: a generic circular progress indicator. It communicates waiting but adds no product identity and looks like an unfinished intermediate state.

### Audit coverage is route-and-state based

Build the inventory from every screen file plus actual navigation call sites, then group evidence into primary tabs, training flows, analytics/history, account/settings, utilities, sheets/dialogs, and loading/empty/error states. Every reachable surface is checked at both target viewport heights; representative dark and light palettes and both languages are mandatory, while automated theme guards continue to cover all five palettes.

Issues are recorded with severity, viewport, state, and code location. Only reproducible overflow, clipping, unsafe-area, touch-target, hierarchy, contrast, localization, gesture, or inconsistent-state findings are changed. Passing surfaces are explicitly recorded to prevent needless redesign.

## Risks / Trade-offs

- [Risk] Startup waits on a slow or unavailable backend. -> Bound each stage, allow local continuation, and keep signed-out startup network-independent.
- [Risk] Initial sync runs twice. -> Let the startup coordinator own first hydration and make the lifecycle gate skip only its initial post-frame run.
- [Risk] Prewarming treats “no active plan” as fatal. -> Recognize that domain state as ready and render the stable plan-selection experience after startup.
- [Risk] Animation increases perceived launch time. -> Use a short minimum dwell, reveal immediately after readiness beyond that dwell, and honor reduced motion.
- [Risk] Broad audit creates unrelated churn. -> Require reproducible evidence and limit edits to confirmed defects.
- [Risk] Widget-only checks miss browser chrome or real gestures. -> Combine geometry tests with production web checks at both mobile viewports.

## Migration Plan

1. Add failing startup-race tests and the readiness coordinator with themed recovery states.
2. Integrate initial sync ownership and plan/dashboard prewarming, then verify signed-in, signed-out, offline, timeout, retry, and local-continuation paths.
3. Complete the agent-generated route/state audit and implement confirmed visual or interaction fixes.
4. Run formatting, analysis, full tests, strict OpenSpec validation, and production mobile visual QA.
5. Bump to the next patch/build number, push, wait for CI, publish with the stable signer, and deploy the web artifact when Alibaba Cloud access is available.

Rollback removes the startup coordinator and restores the previous lifecycle-gate composition; no stored data migration is required.

## Open Questions

None. Exact per-screen fixes remain evidence-driven within the constraints above.
