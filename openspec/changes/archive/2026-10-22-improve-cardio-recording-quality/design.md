## Context

The released cardio pipeline uses owner-scoped private route stores and normal summary synchronization. This change follows official RQrun public documentation and local static artifact inspection, not a claim to recover its proprietary fitness algorithms.

## Goals / Non-Goals

Goals: trustworthy timer/elapsed separation, multi-lap import aggregation, sustained auto-pause and useful mobile split review. Record provenance and limitations of the comparison.

Non-goals: copying code or assets, accessing paid/private services, inventing RQ/VO2max/recovery scores, connecting wearables, enabling AMap or releasing an unverified build.

## Decisions

1. Keep REA 6.7.0 and the verified Android analysis JAR outside the app repository. Register only Codex, preserving other configuration. Use an explicit MCP client if the current desktop session cannot hot-load the server; do not claim UI reconnection from configuration alone.
2. Preserve the existing nullable elapsedSeconds field through import construction. FIT's total_elapsed_time supplies total time and total_timer_time supplies timer time. Do not infer exact TCX elapsed time from an incomplete last track point.
3. Weight TCX lap-average heart rate by valid lap timer duration, and take the maximum of reported lap maxima. Never overwrite known multi-point summaries with the first lap; unavailable measurements remain absent.
4. Separate the last received fix timestamp from the displacement anchor in the live recorder. Reception gap detection uses the former; short stationary displacement accumulates relative to the latter. Auto-pause remains optional and must not turn off because stationary fixes continue.
   Adjacent valid fixes also drive jump filtering and current speed; an old displacement anchor must not dilute either speed after a stop. Split interpolation preserves continuous small-movement time but excludes detected stationary minutes from a resumed crossing interval.
5. Share a compact semantic-themed split widget between live and review screens. Pace uses each split's own duration/distance; cycling uses speed. Distinguish recorded splits from pure kilometre splits rather than relabelling partial/manual laps as kilometres.

## Risks / Trade-offs

- Static Android analysis does not prove runtime GPS behavior or recover server-side models → label facts, inferences and unknowns explicitly.
- Sparse imported tracks and phone GPS need different gap policies → do not silently reinterpret existing imports with live-capture thresholds.
- Physical positioning remains unverified → retain trial and online-map restrictions.
- Existing summaries are not silently recalculated → fixes apply to new imports/recordings, and old nullable fields remain compatible.

## Migration Plan

No schema migration; existing fields are preserved. No production deployment in this task. Revert this branch to roll back future imports/UI changes without rewriting saved activities.
