## Why

The same authenticated account can have cloud-backed workout history available
on the web client but appear empty on Android after sign-in. The sync lifecycle
also lets browser-local pending records upload before the client has hydrated
existing cloud records, which can collide with records whose IDs were created by
another signed-in user and surface as `Bad state: no rows in result set`.

This breaks the core account expectation: signing in with the same email should
restore synchronized training state on every supported client.

## What Changes

- Hydrate remote data before claiming and uploading local-only data during a
  signed-in sync run.
- Restore a signed-in user's active training instance from hydrated remote
  instances when the local device has no active user-scoped selection.
- Generate user-scoped default instance IDs for newly activated built-in plans
  so different accounts do not compete for the same default instance ID.
- Return a clear backend conflict when a sync upsert targets an ID owned by
  another user instead of leaking the low-level no-rows error.

## Capabilities

### Modified Capabilities
- `user-cloud-sync`
- `custom-backend-runtime`

## Impact

- Affects native and web sync ordering.
- Affects default training instance ID generation for future signed-in plan
  activations.
- Existing synced records remain readable; no database migration is required.
- Backend upsert conflicts become explicit `409 Conflict` responses.
