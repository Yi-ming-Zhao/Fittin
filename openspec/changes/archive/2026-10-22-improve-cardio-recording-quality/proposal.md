## Why

RQrun demonstrates that useful running analysis depends on correctly separated timing, trustworthy imported measurements and readable splits. Fittin already records GPS routes, but import aggregation and prolonged stationary recording need stronger correctness guarantees before adding fitness scores.

## What Changes

- Install a version-pinned REA MCP integration for Codex, inspect the official RQrun Android artifact locally, and document observed facts separately from inference and inaccessible server algorithms.
- Preserve elapsed time in supported imports; aggregate TCX heart rate across laps without treating the first lap as the whole activity.
- Correct stationary GPS handling so a continuous stream of stationary fixes is not mistaken for a reception gap and does not end auto-pause.
- Improve activity review and live split presentation with pace/speed, source, moving/elapsed time and honest missing-data states, using existing semantic themes.
- Add targeted deterministic tests; do not claim physiological validity or real-device outdoor verification from static analysis.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `cardio-data-import`: Preserve time semantics and aggregate multi-lap measurements correctly.
- `live-cardio-recording`: Keep stationary GPS and genuine signal gaps separate; present useful, correctly labelled split data.

## Impact

Flutter domain recorder, import service and cardio review widgets/tests. No production credentials, proprietary source/assets, raw routes or downloaded APKs enter the Fittin repository. REA and its Android analysis dependency stay in a local tool directory. No backend or release change is assumed by this request.
