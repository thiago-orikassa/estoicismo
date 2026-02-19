create table if not exists push_tokens (
  id text primary key,
  user_id text not null,
  fcm_token text not null,
  platform text not null default 'android',
  created_at_utc text not null,
  updated_at_utc text not null,
  unique(user_id, fcm_token)
);
