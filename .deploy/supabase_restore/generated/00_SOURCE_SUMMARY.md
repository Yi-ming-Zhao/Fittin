# Migration Export Summary

- Current runtime assessment: local Supabase CLI + Docker is running for the Fittin project
- Project URL: http://127.0.0.1:55321
- DB URL obtained: yes
- Schema export: success
- Business data export: success
- Auth information export: success
- Storage bucket/object inventory: success
- Storage actual files: checked-but-empty

## Key connection info

- Project URL: http://127.0.0.1:55321
- REST URL: http://127.0.0.1:55321/rest/v1
- GraphQL URL: http://127.0.0.1:55321/graphql/v1
- DB URL: postgresql://postgres:postgres@127.0.0.1:55322/postgres
- Publishable key: <redacted-publishable-key>
- Secret key: <redacted-secret-key>
- Storage S3 URL: http://127.0.0.1:55321/storage/v1/s3

## Data summary

- plans: 0
- plan_instances: 3
- workout_logs: 44
- body_metrics: 2
- progress_photos: 0
- auth.users: 12
- storage bucket progress-photos: present
- storage objects in progress-photos: 0

## Notes

- A second local Supabase project named supabase-local is also running on ports 54321-54327. This export targets the Fittin project on ports 55321-55327.
- Storage volume supabase_storage_Fittin currently appears nearly empty except for stub content, so there may be no uploaded object payloads to migrate from this local stack.
- Remote deployment clues still exist in the repository for https://supabase.yimelo.cc, but the live exported environment in this bundle is the local Fittin stack.
