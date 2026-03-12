-- Add expiry column to sessions.
-- Existing sessions get a 90-day window from now so they remain valid.
alter table sessions add column expires_at_utc text;
update sessions set expires_at_utc = datetime('now', '+90 days');
