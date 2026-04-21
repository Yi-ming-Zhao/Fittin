create table if not exists users (
  id text primary key,
  email text not null unique,
  password_hash text not null,
  display_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists plans (
  id text primary key,
  user_id text not null references users(id),
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

create table if not exists plan_instances (
  id text primary key,
  user_id text not null references users(id),
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

create table if not exists workout_logs (
  id text primary key,
  user_id text not null references users(id),
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

create table if not exists body_metrics (
  id text primary key,
  user_id text not null references users(id),
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

create table if not exists progress_photos (
  id text primary key,
  user_id text not null references users(id),
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
