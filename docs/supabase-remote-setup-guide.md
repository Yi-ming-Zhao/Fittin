# Fittin Supabase Remote Setup Guide

This document is for setting up the Supabase backend for Fittin on another computer.

Goal:
- Start a usable Supabase instance on that machine
- Create the database tables and storage bucket expected by the current Flutter app
- Enable auth and row-level security
- Provide the `SUPABASE_URL` and `SUPABASE_ANON_KEY` values needed by the app

This repo currently uses a "Flutter client + Supabase project" architecture.
There is no separate Node/Nest backend to deploy right now.

## Who This Is For

Use this guide when another Codex session or another developer is on a different computer that:
- already has Supabase installed
- needs to configure and start the backend side for this app

## Current App Expectations

The current Flutter app expects:

- Supabase Auth for email/password sign-in
- Postgres tables:
  - `plans`
  - `plan_instances`
  - `workout_logs`
  - `body_metrics`
  - `progress_photos`
- Storage bucket:
  - `progress-photos`

Relevant app code:
- [lib/src/application/supabase_bootstrap.dart](/Users/yzxbb/Desktop/Fittin_v2/lib/src/application/supabase_bootstrap.dart)
- [lib/src/application/auth_provider.dart](/Users/yzxbb/Desktop/Fittin_v2/lib/src/application/auth_provider.dart)
- [lib/src/data/remote/supabase_remote_repository.dart](/Users/yzxbb/Desktop/Fittin_v2/lib/src/data/remote/supabase_remote_repository.dart)
- [lib/src/data/sync/sync_service.dart](/Users/yzxbb/Desktop/Fittin_v2/lib/src/data/sync/sync_service.dart)

The app reads Supabase config from Dart defines:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

## High-Level Checklist

1. Start Supabase on the target machine
2. Get the project API URL and anon key
3. Enable email/password auth
4. Create the required database tables
5. Enable RLS and add per-user policies
6. Create the `progress-photos` storage bucket
7. Add storage policies
8. Run the Flutter app against that Supabase instance
9. Verify sign-up, sync writes, and cross-device restore

## Step 1: Start Supabase

On the target machine, from any working directory:

```bash
supabase start
```

After startup, collect:
- API URL
- anon key

If the machine is using a longer-lived self-hosted Supabase setup instead of local development, use that deployment's public API URL and anon key instead.

## Step 2: Confirm the App Can Reach That Machine

If the app will run on another machine, emulator, or phone:

- do not use `localhost` unless the app is on the same machine
- use the target machine's LAN IP when needed
- ensure the required ports are reachable through the firewall

Common examples:

- Android emulator to host machine: often `10.0.2.2`
- Physical device to another computer: use the other computer's LAN IP

## Step 3: Enable Auth

In Supabase:

1. Open the project dashboard
2. Go to `Authentication`
3. Enable email/password sign-in

For development, email confirmation can be disabled if you want a faster local setup.

The current app only depends on email/password auth.

## Step 4: Create Required Tables

Run the SQL below in the Supabase SQL editor on the target machine/project.

```sql
create table if not exists public.plans (
  id text primary key,
  user_id uuid not null,
  name text not null default '',
  description text not null default '',
  source_plan_id text,
  is_built_in boolean not null default false,
  raw_json text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  version integer not null default 1,
  last_modified_by_device_id text
);

create table if not exists public.plan_instances (
  id text primary key,
  user_id uuid not null,
  template_id text not null,
  current_workout_index integer not null default 0,
  current_states_json text not null,
  training_max_profile_json text not null,
  engine_state_json text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  version integer not null default 1,
  last_modified_by_device_id text
);

create table if not exists public.workout_logs (
  id text primary key,
  user_id uuid not null,
  instance_id text not null,
  workout_id text not null,
  workout_name text not null default '',
  raw_json text not null,
  completed_at timestamptz not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  version integer not null default 1,
  last_modified_by_device_id text
);

create table if not exists public.body_metrics (
  id text primary key,
  user_id uuid not null,
  timestamp timestamptz not null,
  weight_kg double precision,
  body_fat_percent double precision,
  waist_cm double precision,
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  version integer not null default 1,
  last_modified_by_device_id text
);

create table if not exists public.progress_photos (
  id text primary key,
  user_id uuid not null,
  captured_at timestamptz not null,
  label text,
  storage_path text not null,
  metadata_json text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  version integer not null default 1,
  last_modified_by_device_id text
);
```

## Step 5: Enable Row Level Security

Run:

```sql
alter table public.plans enable row level security;
alter table public.plan_instances enable row level security;
alter table public.workout_logs enable row level security;
alter table public.body_metrics enable row level security;
alter table public.progress_photos enable row level security;
```

## Step 6: Add Per-User Policies

Run:

```sql
create policy "plans own rows" on public.plans
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "plan_instances own rows" on public.plan_instances
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "workout_logs own rows" on public.workout_logs
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "body_metrics own rows" on public.body_metrics
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "progress_photos own rows" on public.progress_photos
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
```

If policies already exist, either skip duplicates or drop/recreate them carefully.

## Step 7: Create the Storage Bucket

Create a storage bucket named:

```text
progress-photos
```

The current app uploads files under paths like:

```text
users/<uid>/progress_photos/<photoId>/original.jpg
```

This path shape comes from:
- [lib/src/data/remote/supabase_remote_repository.dart](/Users/yzxbb/Desktop/Fittin_v2/lib/src/data/remote/supabase_remote_repository.dart)

## Step 8: Add Storage Policies

Add policies so authenticated users can manage only their own files inside the `progress-photos` bucket.

Example policy approach:

```sql
create policy "authenticated users can read own progress photos"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'progress-photos'
  and (storage.foldername(name))[1] = 'users'
  and (storage.foldername(name))[2] = auth.uid()::text
);

create policy "authenticated users can upload own progress photos"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'progress-photos'
  and (storage.foldername(name))[1] = 'users'
  and (storage.foldername(name))[2] = auth.uid()::text
);

create policy "authenticated users can update own progress photos"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'progress-photos'
  and (storage.foldername(name))[1] = 'users'
  and (storage.foldername(name))[2] = auth.uid()::text
)
with check (
  bucket_id = 'progress-photos'
  and (storage.foldername(name))[1] = 'users'
  and (storage.foldername(name))[2] = auth.uid()::text
);

create policy "authenticated users can delete own progress photos"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'progress-photos'
  and (storage.foldername(name))[1] = 'users'
  and (storage.foldername(name))[2] = auth.uid()::text
);
```

## Step 9: Run the Flutter App Against That Supabase Instance

From this repo:

```bash
flutter run \
  --dart-define=SUPABASE_URL=http://<HOST_OR_LAN_IP>:8000 \
  --dart-define=SUPABASE_ANON_KEY=<YOUR_ANON_KEY>
```

Replace:
- `<HOST_OR_LAN_IP>` with the Supabase API host reachable from the app
- `<YOUR_ANON_KEY>` with the anon key from the target Supabase project

If the Supabase URL is HTTPS in your setup, use that full HTTPS URL instead.

## Step 10: Verify the Setup

Recommended manual verification flow:

1. Launch the app with valid Supabase Dart defines
2. Open the account screen
3. Create a new account
4. Confirm sign-in succeeds
5. Create or edit a personal plan
6. Complete a workout
7. Save a body metric
8. Check Supabase tables for inserted rows
9. Sign in on another device using the same account
10. Confirm plans, logs, and progress data restore locally

Expected tables to receive data:
- `plans`
- `plan_instances`
- `workout_logs`
- `body_metrics`
- `progress_photos` for photo metadata

Expected storage bucket to receive files:
- `progress-photos`

## Current Limitations

At the time of writing:

- This repo does not yet include official Supabase migration files under a `supabase/` directory
- The backend schema is configured manually from this document
- The app currently relies on direct client access to Supabase with RLS rather than a custom server API

## Recommended Next Improvement

If you want repeatable setup across multiple machines, add:

- `supabase/migrations/*.sql`
- a storage policy SQL file
- a small setup script or README command set

That would let another Codex session automate setup instead of re-entering SQL manually.

## Handoff Prompt For Another Codex

If you want another Codex on another computer to take over, give it this repository and this file:

- [docs/supabase-remote-setup-guide.md](/Users/yzxbb/Desktop/Fittin_v2/docs/supabase-remote-setup-guide.md)

Suggested handoff message:

```text
Read docs/supabase-remote-setup-guide.md in this repo, then help me configure and start the Supabase backend on this machine for the Fittin app. After setup, verify auth, tables, storage bucket, and give me the SUPABASE_URL and SUPABASE_ANON_KEY values I should use to run the Flutter app.
```
