## Context

Fittin uses shared themed primitives but individual pages choose compact thresholds, fixed module heights and scroll behavior independently. Existing tests cover common 320/390 widths and several phone heights at normal text size; this change extends the same design system to safe insets, 200 percent text and evidence found by the multi-agent audit. The five semantic palettes and current editorial, strength-focused visual direction remain authoritative.

## Goals / Non-Goals

**Goals:**

- Make every corrected surface safe at 320×568, 390×844 and 390×926, including large text and keyboard states.
- Fix shared primitives when one change safely resolves the same defect across pages; otherwise use focused per-screen reflow.
- Preserve an intentional hierarchy: one dominant action, readable values and subordinate metadata.
- Back each code change with a focused regression and verify the signed upgrade path before publishing.
- Preserve account and workout consistency when asynchronous UI, synchronization and storage events overlap.

**Non-Goals:**

- Redesigning the five themes, expanding training or Agent capabilities, or adding dependencies.
- Shrinking text globally, disabling accessibility scaling, or converting every page into an identical card stack.
- Treating subjective preference as a defect without a concrete viewport or interaction failure.

## Decisions

1. **Reflow instead of global text clamping.** Scroll, wrap and stack content at its owning layout boundary. A global maximum text scale would conceal overflow by reducing accessibility and is rejected.
2. **Preserve tall-screen composition while adding an overflow escape path.** Primary pages may keep a non-scrolling balanced layout when it fits, but must switch or naturally become scrollable when measured content exceeds the safe viewport. Always-scrollable pages remain acceptable when physics do not create forced motion.
3. **Use semantic theme tokens only.** Layout polish may adjust hierarchy through existing type, surface and accent tokens; no new hard-coded cyan/teal or one-off page palette is allowed.
4. **Audit before touching shared primitives.** A shared scaffold or bottom-navigation change must have regressions for both shell-hosted pages and pushed pages so safe-area fixes do not create double padding.
5. **Release as v1.2.1+25.** This is a backward-compatible presentation and stability patch. CI artifacts, the stable Android signer, an install-over-v1.2.0 check, public Web verification and `latest.json`-last deployment remain release gates.
6. **Bind cached UI state to its owner.** Providers that expose user-owned rows rebuild on authentication ownership changes, and repositories reject a destructive operation when the row does not belong to the active owner.
7. **Commit one workout conclusion as one local transaction.** The workout log, progressed instance and their sync records succeed or fail together. A stable conclusion identity makes rapid retry idempotent.
8. **Fail blocked Web upgrades explicitly.** IndexedDB connections close on `versionchange`; a blocked or timed-out open returns a typed recoverable error and clears the cached opening future so retry can succeed.
9. **Serialize Agent continuation controls.** Submit, retry and resume share one controller-side occupancy guard; UI disabled state is supplementary rather than the correctness boundary.
10. **Preserve sync conflicts honestly.** A synchronization pass may retain recoverable conflicting rows, but the controller must publish a conflict state instead of a successful timestamp.

## Risks / Trade-offs

- [Adding scroll fallback can change gesture ownership] → Keep horizontal card and chart gestures scoped and test vertical drag behavior on affected pages.
- [Large-text reflow can make pages longer] → Prefer content preservation and natural scrolling over clipping; retain compact spacing bounds.
- [Shared safe-area changes can double-count app-shell navigation] → Test both a tab inside `AppShellScreen` and a standalone pushed route.
- [Aesthetic cleanup can become unbounded] → Require a reproducible viewport, semantics or state failure for each edit and defer unsupported preferences.
- [Cross-repository atomic commits differ on Isar and IndexedDB] → Keep one platform-neutral operation contract and add failure-injection coverage for both storage implementations.
- [Blocked IndexedDB requests may later succeed] → Close any late database result after the typed failure and allow an explicit retry.

## Migration Plan

No data or storage migration is required. Build and test on the feature branch, merge after CI, deploy the 241 backend only if backend files changed, switch the immutable Web release with the previous symlink retained, publish the signed Android release, and update first-party `latest.json` only after all checks pass.

## Open Questions

The audit findings decide the final per-screen task list; the requirements and release gates above remain fixed.
