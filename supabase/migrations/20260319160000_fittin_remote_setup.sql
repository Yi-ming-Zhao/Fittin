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

alter table public.plans enable row level security;
alter table public.plan_instances enable row level security;
alter table public.workout_logs enable row level security;
alter table public.body_metrics enable row level security;
alter table public.progress_photos enable row level security;

drop policy if exists "plans own rows" on public.plans;
create policy "plans own rows" on public.plans
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "plan_instances own rows" on public.plan_instances;
create policy "plan_instances own rows" on public.plan_instances
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "workout_logs own rows" on public.workout_logs;
create policy "workout_logs own rows" on public.workout_logs
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "body_metrics own rows" on public.body_metrics;
create policy "body_metrics own rows" on public.body_metrics
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "progress_photos own rows" on public.progress_photos;
create policy "progress_photos own rows" on public.progress_photos
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

insert into storage.buckets (id, name, public)
values ('progress-photos', 'progress-photos', false)
on conflict (id) do nothing;

drop policy if exists "authenticated users can read own progress photos" on storage.objects;
create policy "authenticated users can read own progress photos"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'progress-photos'
  and (storage.foldername(name))[1] = 'users'
  and (storage.foldername(name))[2] = auth.uid()::text
);

drop policy if exists "authenticated users can upload own progress photos" on storage.objects;
create policy "authenticated users can upload own progress photos"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'progress-photos'
  and (storage.foldername(name))[1] = 'users'
  and (storage.foldername(name))[2] = auth.uid()::text
);

drop policy if exists "authenticated users can update own progress photos" on storage.objects;
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

drop policy if exists "authenticated users can delete own progress photos" on storage.objects;
create policy "authenticated users can delete own progress photos"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'progress-photos'
  and (storage.foldername(name))[1] = 'users'
  and (storage.foldername(name))[2] = auth.uid()::text
);
