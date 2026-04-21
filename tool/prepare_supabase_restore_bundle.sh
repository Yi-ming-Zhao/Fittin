#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  cat <<'EOF'
Usage:
  tool/prepare_supabase_restore_bundle.sh <migration_export.tar.gz> [output_dir]

Example:
  tool/prepare_supabase_restore_bundle.sh migration_export.tar.gz .deploy/supabase_restore
EOF
  exit 1
fi

ARCHIVE_PATH="$1"
OUTPUT_DIR="${2:-.deploy/supabase_restore}"

if [[ ! -f "$ARCHIVE_PATH" ]]; then
  echo "Archive not found: $ARCHIVE_PATH" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ABS_OUTPUT_DIR="$REPO_ROOT/$OUTPUT_DIR"
EXTRACT_DIR="$ABS_OUTPUT_DIR/extracted"
GENERATED_DIR="$ABS_OUTPUT_DIR/generated"

rm -rf "$ABS_OUTPUT_DIR"
mkdir -p "$EXTRACT_DIR" "$GENERATED_DIR"

tar -xzf "$ARCHIVE_PATH" -C "$EXTRACT_DIR"
find "$EXTRACT_DIR" -name '._*' -delete

BUNDLE_DIR="$EXTRACT_DIR/migration_export"
if [[ ! -d "$BUNDLE_DIR" ]]; then
  echo "Extracted bundle missing migration_export directory" >&2
  exit 1
fi

copy_if_exists() {
  local src="$1"
  local dest="$2"
  if [[ -f "$src" ]]; then
    cp "$src" "$dest"
  fi
}

copy_if_exists "$BUNDLE_DIR/SUMMARY.md" "$GENERATED_DIR/00_SOURCE_SUMMARY.md"
copy_if_exists "$BUNDLE_DIR/02_supabase_status.txt" "$GENERATED_DIR/01_SOURCE_STATUS.txt"
copy_if_exists "$BUNDLE_DIR/08_row_counts.txt" "$GENERATED_DIR/02_ROW_COUNTS.txt"
copy_if_exists "$BUNDLE_DIR/10_auth_config_summary.txt" "$GENERATED_DIR/03_AUTH_CONFIG.txt"
copy_if_exists "$BUNDLE_DIR/06_policies.txt" "$GENERATED_DIR/04_POLICIES.txt"

# Concatenate repo-owned migrations for schema restore on a fresh target.
MIGRATION_OUT="$GENERATED_DIR/10_repo_migrations.sql"
: > "$MIGRATION_OUT"
if [[ -d "$BUNDLE_DIR/project_supabase/migrations" ]]; then
  while IFS= read -r file; do
    cat "$file" >> "$MIGRATION_OUT"
    printf '\n\n' >> "$MIGRATION_OUT"
  done < <(find "$BUNDLE_DIR/project_supabase/migrations" -type f | sort)
fi

# Create a safe app-data restore script from table-specific dumps.
APP_DATA_OUT="$GENERATED_DIR/20_restore_public_app_data.sql"
cat > "$APP_DATA_OUT" <<'EOF'
BEGIN;
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

TRUNCATE TABLE
  public.progress_photos,
  public.body_metrics,
  public.workout_logs,
  public.plan_instances,
  public.plans
RESTART IDENTITY CASCADE;

EOF

for table_dump in \
  "$BUNDLE_DIR/plans.sql" \
  "$BUNDLE_DIR/plan_instances.sql" \
  "$BUNDLE_DIR/workout_logs.sql" \
  "$BUNDLE_DIR/body_metrics.sql" \
  "$BUNDLE_DIR/progress_photos.sql"
do
  if [[ -f "$table_dump" ]]; then
    cat "$table_dump" >> "$APP_DATA_OUT"
    printf '\n' >> "$APP_DATA_OUT"
  fi
done

cat >> "$APP_DATA_OUT" <<'EOF'
COMMIT;
EOF

# Split auth-related rows from the full data dump if present.
AUTH_DATA_OUT="$GENERATED_DIR/30_restore_auth_data.sql"
if [[ -f "$BUNDLE_DIR/data.sql" ]]; then
  awk '
    BEGIN {print "BEGIN;"; found=0}
    /^INSERT INTO auth\./ || /^INSERT INTO storage\./ {
      print
      found=1
    }
    END {
      if (found == 0) {
        print "-- No auth/storage INSERT statements found in export."
      }
      print "COMMIT;"
    }
  ' "$BUNDLE_DIR/data.sql" > "$AUTH_DATA_OUT"
fi

cat > "$GENERATED_DIR/README.md" <<'EOF'
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
EOF

printf 'Prepared restore bundle under: %s\n' "$ABS_OUTPUT_DIR"
find "$GENERATED_DIR" -maxdepth 1 -type f | sort
