begin;

alter table auth_sessions
    add column if not exists refresh_token_hash bytea,
    add column if not exists previous_refresh_token_hash bytea,
    add column if not exists refresh_token_rotated_at timestamptz,
    add column if not exists last_refreshed_at timestamptz,
    add column if not exists refresh_reuse_detected_at timestamptz,
    add column if not exists rotation_counter bigint not null default 0;

create unique index if not exists auth_sessions_refresh_token_hash_uidx
    on auth_sessions (refresh_token_hash)
    where refresh_token_hash is not null and revoked_at is null;

commit;
