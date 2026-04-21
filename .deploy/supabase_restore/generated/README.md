# Supabase Restore Bundle

This directory was generated from `migration_export.tar.gz`.

Files:
- `10_repo_migrations.sql`: repo-owned schema migration SQL
- `20_restore_public_app_data.sql`: public app tables only
- `30_restore_auth_data.sql`: extracted auth/storage inserts from the full dump

Recommended restore order for a fresh target:
1. Provision a Supabase project or another compatible Postgres/Supabase target.
2. Apply `10_repo_migrations.sql`.
3. Apply `20_restore_public_app_data.sql`.
4. Apply `30_restore_auth_data.sql` only if the target supports direct writes to `auth.*` and `storage.*`.

Notes:
- This bundle does not contain uploaded progress photo object payloads; the source export reported zero objects.
- The source export reported 12 `auth.users` rows.
- The source export reported 3 `plan_instances`, 44 `workout_logs`, 2 `body_metrics`, and 0 `plans` / `progress_photos`.
