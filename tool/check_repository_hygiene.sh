#!/usr/bin/env bash

set -euo pipefail

tracked_generated="$(
  git ls-files \
    | grep -E '(^|/)\.deploy/|(^|/)android/build/|migration_export|database_export' \
	| while IFS= read -r path; do [[ -e "$path" ]] && echo "$path"; done \
    || true
)"
if [[ -n "$tracked_generated" ]]; then
  echo "Generated migration/build artifacts must not be tracked:" >&2
  echo "$tracked_generated" >&2
  exit 1
fi

bcrypt_hits="$(
  git grep -I -n -E '[$]2[aby][$][0-9]{2}[$][./A-Za-z0-9]{53}' -- . \
    ':!tool/check_repository_hygiene.sh' \
    || true
)"
if [[ -n "$bcrypt_hits" ]]; then
  echo "Possible bcrypt password hashes found in tracked files:" >&2
  echo "$bcrypt_hits" >&2
  exit 1
fi

echo "Repository hygiene checks passed."
