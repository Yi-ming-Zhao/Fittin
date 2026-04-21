## 1. OpenSpec Artifacts

- [x] 1.1 Add proposal, design, and spec deltas for Supabase bootstrap configuration and account-surface availability.

## 2. Bootstrap Fix

- [x] 2.1 Update `initializeSupabase()` to prefer complete explicit config and only use the local Supabase dev stack after a real reachability check succeeds.
- [x] 2.2 Return actionable unavailable messages for incomplete explicit config and unreachable local fallback.
- [x] 2.3 Handle Android APK runtime separately so release/device builds require explicit Supabase config instead of probing the wrong localhost path.
- [x] 2.4 Move Android network permission into the main manifest so release APKs can reach explicit Supabase backends.

## 3. Verification

- [x] 3.1 Add or update tests that cover explicit config, successful local fallback, and unavailable bootstrap behavior.
- [x] 3.2 Add a focused Android bootstrap test that verifies local auto-fallback is skipped and the unavailable message is explicit.
- [x] 3.3 Run `flutter analyze` or an equivalent repository check and record the result.
