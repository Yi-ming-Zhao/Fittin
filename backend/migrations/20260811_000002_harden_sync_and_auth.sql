begin;

update users
   set email = lower(btrim(email)),
       updated_at = now()
 where email <> lower(btrim(email));

create unique index if not exists users_email_normalized_uidx
    on users (lower(btrim(email)));

create index if not exists plans_sync_cursor_idx
    on plans (user_id, updated_at, id);
create index if not exists plan_instances_sync_cursor_idx
    on plan_instances (user_id, updated_at, id);
create index if not exists workout_logs_sync_cursor_idx
    on workout_logs (user_id, updated_at, id);
create index if not exists body_metrics_sync_cursor_idx
    on body_metrics (user_id, updated_at, id);
create index if not exists progress_photos_sync_cursor_idx
    on progress_photos (user_id, updated_at, id);

create table if not exists auth_sessions (
  id text primary key,
  user_id text not null references users(id) on delete cascade,
  issued_at timestamptz not null default now(),
  expires_at timestamptz not null,
  revoked_at timestamptz,
  device_id text
);

create index if not exists auth_sessions_active_user_idx
    on auth_sessions (user_id, expires_at)
    where revoked_at is null;

commit;
