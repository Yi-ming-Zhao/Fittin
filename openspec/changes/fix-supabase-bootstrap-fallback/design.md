## Context

`initializeSupabase()` currently resolves config from compile-time `dart-define` values and otherwise hardcodes a local Supabase URL/key pair behind a coarse fallback path. That leaves two gaps: the app can report a generic "missing dart define" error instead of the real bootstrap reason, and the fallback path is not based on actual reachability of the local gateway. Android adds a third gap: `127.0.0.1` inside an APK points back to the Android runtime itself, not the developer workstation, so a repo-local fallback is not a generally valid device path.

## Goals / Non-Goals

**Goals:**
- Keep bootstrap precedence simple: explicit config first, local fallback second.
- Make the local fallback contingent on a real reachability check.
- Avoid claiming Android APKs can use the repo-local fallback when no valid generic host mapping exists.
- Keep the fix small and isolated to bootstrap/account availability behavior.
- Add tests without depending on a live Supabase service.

**Non-Goals:**
- Change cloud sync semantics or authenticated data models.
- Introduce a new runtime config file format.
- Rework public web deployment requirements.

## Decisions

Use an injectable bootstrap initializer and local-endpoint probe in `initializeSupabase()`.
This keeps production behavior unchanged while making the fallback logic testable without mutating global `Supabase` state in tests.

Probe the repo-local Supabase gateway only through a tiny platform helper.
On IO runtimes, the helper performs a short HTTP request to a public auth settings endpoint. On unsupported runtimes, it safely returns false so the app falls back to explicit configuration requirements.

Treat Android APK runtimes as explicit-config-only for Supabase bootstrap.
Desktop/mobile loopback semantics differ: `127.0.0.1` works for desktop local development, the Android emulator uses `10.0.2.2`, and physical devices need a tunnel or remote host. Rather than silently probing the wrong host in release APKs, the bootstrap path returns an actionable error telling the user to supply explicit config.

Return actionable unavailable messages for the two real failure modes.
If only one dart define is supplied, the app reports an incomplete explicit configuration. If no explicit config is supplied and the local gateway is unreachable, the app reports that exact condition instead of implying a fallback that never activated. On Android APKs, the message explicitly states that device builds need explicit Supabase config.

Keep Android release networking enabled.
The APK still needs `android.permission.INTERNET` in the main manifest so explicit hosted Supabase config works outside debug/profile builds.

## Risks / Trade-offs

- [Web/local fallback remains conservative] -> The probe only runs where the app can directly perform the endpoint check, so browser builds still rely on explicit config unless a supported probe path is added later.
- [Android local fallback becomes intentionally conservative] -> Emulator-only auto-detection is skipped for now because the current APK target must also behave correctly on physical devices.
- [Local gateway probe adds startup I/O] -> Use a short timeout and only run the probe when explicit config is absent.
