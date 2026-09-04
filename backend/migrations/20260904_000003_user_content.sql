begin;

create table if not exists user_content (
  id text primary key,
  user_id text not null references users(id) on delete cascade,
  kind text not null check (kind in (
    'customExercise',
    'cardioActivity',
    'cardioRecord',
    'cardioImportFingerprint',
    'customThemePalette'
  )),
  payload_json text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  version integer not null default 1 check (version > 0),
  last_modified_by_device_id text
);

create index if not exists user_content_sync_cursor_idx
    on user_content (user_id, updated_at, id);
create index if not exists user_content_kind_idx
    on user_content (user_id, kind)
    where deleted_at is null;

commit;
