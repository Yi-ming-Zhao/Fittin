# Fittin Custom Backend Deployment

This document describes the self-hosted backend that replaces the previous Supabase runtime.

## Runtime Shape

- Go API process on `127.0.0.1:8081`
- PostgreSQL database reachable through `FITTIN_DATABASE_URL`
- Local disk storage for progress photos
- NPS exposing the 241 backend to Alibaba Cloud nginx on loopback port `24181`
- Alibaba Cloud nginx exposing the same-origin public `/api` prefix

## Required Environment

- `FITTIN_BACKEND_ADDR`
- `FITTIN_DATABASE_URL`
- `FITTIN_JWT_SECRET`
- `FITTIN_FILE_STORAGE_ROOT`

## Flutter Configuration

Use:

```bash
--dart-define=BACKEND_URL=https://fittin.hammerscholar.net/api
```

Production Web and Android builds must pass this value explicitly. Do not rely
on the desktop/local fallback to `http://127.0.0.1:8081` for release builds.

## Notes

- The backend implementation lives under `backend/`.
- Database schema bootstrap lives under `backend/migrations/`.
- The import entrypoint is `backend/cmd/fittin-import`.

Production exports, password hashes, and restoration bundles must never be
committed. Perform any approved migration from an encrypted, access-controlled
path outside the repository and delete the working copy after verification.
