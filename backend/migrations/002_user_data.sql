-- 002_user_data.sql

create table if not exists checkins (
  id uuid primary key,
  user_id uuid not null,
  date_local date not null,
  applied boolean not null,
  note text,
  timezone text not null,
  created_at_utc timestamptz not null,
  updated_at_utc timestamptz not null,
  unique (user_id, date_local)
);

create table if not exists favorites (
  id uuid primary key,
  user_id uuid not null,
  quote_id text not null,
  created_at_utc timestamptz not null,
  unique (user_id, quote_id)
);

create table if not exists analytics_events (
  id uuid primary key,
  event_name text not null,
  event_version int not null,
  created_at_utc timestamptz not null,
  properties_json text not null
);
