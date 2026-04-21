## Why

The account screen can report Supabase as "not configured" even when the repository already carries a local Supabase development stack configuration. The current bootstrap logic also claims there is a fallback path without first verifying whether the local gateway is actually reachable, which makes the account surface hard to trust during local development and troubleshooting.

## What Changes

- Add a focused Supabase bootstrap contract that defines configuration precedence, local fallback eligibility, and unavailable-state reporting.
- Update bootstrap logic so explicit `SUPABASE_URL` / `SUPABASE_ANON_KEY` values take precedence, and the repo-local dev stack is only used after a reachability check succeeds.
- Clarify Android runtime behavior so release/debug APKs do not assume `127.0.0.1` can reach the repo-local Supabase stack, and require explicit config on device builds.
- Return a more accurate unavailable reason when neither explicit config nor a reachable local dev stack can be used.
- Add tests for explicit config, local fallback, and unavailable bootstrap cases.

## Capabilities

### New Capabilities
- `supabase-bootstrap-configuration`: Defines how the app resolves Supabase runtime configuration and when local fallback is allowed.

### Modified Capabilities
- `user-account-authentication`: Clarifies that the account surface must reflect the real bootstrap state when Supabase auth is unavailable.

## Impact

- Affected code: `lib/src/application/supabase_bootstrap.dart`, Android manifest permissions, account-surface messaging, and bootstrap tests.
- Affected systems: local Supabase development flow and authenticated account entry.
