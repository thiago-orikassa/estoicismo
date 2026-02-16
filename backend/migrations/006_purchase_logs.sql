create table if not exists purchase_logs (
  id text primary key,
  user_id text not null,
  product_id text not null,
  platform text not null,
  purchase_token text,
  transaction_id text,
  created_at_utc text not null
);
