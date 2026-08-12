# Fittin Backend Setup Guide

This document replaces the historical Supabase setup guide.

Fittin no longer depends on a Supabase runtime for production use. The supported
backend model is now:

- Go API on `127.0.0.1:8081`
- PostgreSQL for auth and sync data
- Local disk storage for progress photo files
- NPS from 241 to Alibaba Cloud and direct HTTPS exposure through Nginx

Use these documents instead of the old Supabase workflow:

- [docs/custom-backend-deployment.md](/data/zhaoyiming/Fittin/docs/custom-backend-deployment.md)
- [docs/web-public-deployment.md](/data/zhaoyiming/Fittin/docs/web-public-deployment.md)

Production migration exports are deliberately excluded from source control.
When an approved migration is required, use an encrypted input path outside the
repository and follow `docs/security-incident-response.md` for cleanup and
credential handling.

If you are looking for the previous Supabase-specific instructions, treat them
as archival context only. They no longer describe the supported runtime.
