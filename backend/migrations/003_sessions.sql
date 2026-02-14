-- 003_sessions.sql

create table if not exists sessions (
  id text primary key,
  user_id text not null,
  device_id text not null unique,
  token_hash text not null,
  created_at_utc text not null,
  updated_at_utc text not null
);

create index if not exists sessions_token_hash_idx on sessions (token_hash);
