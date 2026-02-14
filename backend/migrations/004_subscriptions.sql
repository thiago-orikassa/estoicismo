-- 004_subscriptions.sql

create table if not exists subscription_profiles (
  user_id text primary key,
  status text not null check (status in ('free', 'trial', 'active', 'canceled')),
  plan text check (plan in ('monthly', 'annual')),
  trial_started_at_utc text,
  trial_ends_at_utc text,
  next_billing_at_utc text,
  trial_used integer not null default 0,
  updated_at_utc text not null
);

create table if not exists subscription_restore_requests (
  id text primary key,
  user_id text not null,
  idempotency_key text not null,
  restored integer not null,
  created_at_utc text not null,
  unique (user_id, idempotency_key)
);
