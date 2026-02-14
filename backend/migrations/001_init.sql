-- 001_init.sql

create table if not exists quotes (
  id text primary key,
  author text not null check (author in ('seneca','epictetus','marcus_aurelius')),
  text text not null,
  source_work text not null,
  source_ref text not null,
  language text not null check (language in ('pt','en','es')),
  theme_primary text not null,
  theme_secondary text,
  context_tags text not null default '[]',
  authenticity_level text not null check (authenticity_level in ('verified','probable')),
  created_at text not null default (datetime('now'))
);

create table if not exists daily_recommendations (
  id text primary key,
  quote_id text not null references quotes(id),
  context text not null check (context in ('trabalho','relacionamentos','ansiedade','foco','decisao_dificil')),
  action_title text not null,
  action_steps text not null,
  estimated_minutes int not null check (estimated_minutes between 1 and 30),
  journal_prompt text not null,
  created_at text not null default (datetime('now'))
);

create table if not exists daily_packages (
  id text primary key,
  date_local text not null,
  timezone text not null,
  quote_id text not null references quotes(id),
  recommendation_id text not null references daily_recommendations(id),
  unique (date_local, timezone)
);

create table if not exists daily_checkins (
  id text primary key,
  user_id text not null,
  date_local text not null,
  applied boolean not null,
  note text,
  created_at_utc text not null default (datetime('now')),
  created_at_local text not null,
  unique (user_id, date_local)
);
