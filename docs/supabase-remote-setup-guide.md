# Fittin Backend Setup Guide

This document replaces the historical Supabase setup guide.

Fittin no longer depends on a Supabase runtime for production use. The supported
backend model is now:

- Go API on `127.0.0.1:8081`
- PostgreSQL for auth and sync data
- Local disk storage for progress photo files
- Cloudflare Tunnel for public exposure

Use these documents instead of the old Supabase workflow:

- [docs/custom-backend-deployment.md](/data/zhaoyiming/Fittin/docs/custom-backend-deployment.md)
- [docs/web-public-deployment.md](/data/zhaoyiming/Fittin/docs/web-public-deployment.md)

Migration source assets from the previous Supabase environment remain in:

- `.deploy/supabase_restore/generated/30_restore_auth_data.sql`
- `.deploy/supabase_restore/generated/20_restore_public_app_data.sql`

Those files are consumed by:

```bash
cd backend
go run ./cmd/fittin-import
```

If you are looking for the previous Supabase-specific instructions, treat them
as archival context only. They no longer describe the supported runtime.
