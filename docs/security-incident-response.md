# Fittin Repository Data Exposure Response

The current source tree no longer contains the generated Supabase restoration
bundle, password hashes, application rows, or Android build reports. CI rejects
those paths and bcrypt-shaped values. This does **not** remove blobs from older
Git commits or invalidate credentials that were previously exposed.

## Required maintenance window

1. Freeze pushes and create an encrypted mirror backup of every branch, tag,
   release, and pull-request ref.
2. Inventory affected blob ids and confirm the exact first/last containing
   commits. Preserve only a restricted incident copy for audit purposes.
3. Use `git filter-repo` path removal across all refs. Re-run the bcrypt,
   email/user-row, secret, and generated-export scans against every rewritten
   ref before publishing it.
4. Coordinate the force-push. Delete and recreate affected tags/releases, then
   require every contributor and the 241 checkout to fresh-clone or hard-reset
   only after their uncommitted work has been separately backed up.
5. Rotate database, JWT, deployment, signing-access, and provider credentials
   that appeared in any affected file or nearby environment capture. Do not
   rotate the Android signing certificate itself unless compromise is proven;
   changing it would prevent in-place upgrades.
6. Revoke all active backend sessions. Force password reset for every account
   whose bcrypt hash was exposed, notify affected users, and monitor failed
   login/rate-limit activity.
7. Verify the public Git host no longer serves the blob ids, forks/caches have
   been escalated to the provider, the first-party Android manifest still works,
   and production login/sync/media access succeed with newly issued sessions.

History rewriting and credential invalidation are intentionally not executed by
ordinary build/deploy scripts because both operations are irreversible and
require a coordinated user communication and rollback window.
