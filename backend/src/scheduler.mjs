import { readFileSync, writeFileSync } from 'node:fs';
import { randomUUID } from 'node:crypto';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const defaultDataDir = join(__dirname, '../data');
const dataDir = process.env.STOIC_DATA_DIR ?? defaultDataDir;
const seedPath = process.env.STOIC_SEED_PATH ?? join(dataDir, 'daily_seed.json');
const schedulePath = join(dataDir, 'scheduled_packages.json');

const seed = JSON.parse(readFileSync(seedPath, 'utf-8'));

function loadScheduled() {
  try {
    return JSON.parse(readFileSync(schedulePath, 'utf-8'));
  } catch {
    return [];
  }
}

function saveScheduled(items) {
  writeFileSync(schedulePath, JSON.stringify(items, null, 2));
}

function pickDailyPair(dateLocal, timezone) {
  const base = `${dateLocal}:${timezone}`;
  let hash = 0;
  for (let i = 0; i < base.length; i += 1) hash = (hash * 31 + base.charCodeAt(i)) >>> 0;

  const quote = seed.quotes[hash % seed.quotes.length];
  const linked = seed.recommendations.find((r) => r.quote_id === quote.id);
  const recommendation = linked ?? seed.recommendations[hash % seed.recommendations.length];

  return {
    date_local: dateLocal,
    timezone,
    quote,
    recommendation
  };
}

function isoDateOffset(baseDate, daysOffset) {
  const date = new Date(`${baseDate}T00:00:00Z`);
  date.setUTCDate(date.getUTCDate() + daysOffset);
  return date.toISOString().slice(0, 10);
}

function generate({ timezone, startDate, days }) {
  const scheduled = loadScheduled();
  const created = [];
  const skipped = [];

  for (let i = 0; i < days; i += 1) {
    const dateLocal = isoDateOffset(startDate, i);
    const exists = scheduled.find((p) => p.date_local === dateLocal && p.timezone === timezone);
    if (exists) {
      skipped.push({ date_local: dateLocal, timezone });
      continue;
    }

    const pack = pickDailyPair(dateLocal, timezone);
    const entry = {
      id: randomUUID(),
      created_at_utc: new Date().toISOString(),
      ...pack
    };
    scheduled.push(entry);
    created.push(entry);
  }

  saveScheduled(scheduled);
  return { created, skipped, total: scheduled.length };
}

/**
 * Build a push notification preview for a given timezone and date.
 * Uses the scheduled_packages.json if available, otherwise generates on-the-fly.
 */
function sendDailyPush(timezone) {
  const now = new Date();
  const parts = new Intl.DateTimeFormat('en-US', {
    timeZone: timezone,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).formatToParts(now);
  const year = parts.find((p) => p.type === 'year')?.value;
  const month = parts.find((p) => p.type === 'month')?.value;
  const day = parts.find((p) => p.type === 'day')?.value;
  const dateLocal = `${year}-${month}-${day}`;

  const scheduled = loadScheduled();
  const existing = scheduled.find(
    (p) => p.date_local === dateLocal && p.timezone === timezone
  );
  const pack = existing ?? pickDailyPair(dateLocal, timezone);

  const title = 'Seu insight do dia';
  const body = `${pack.quote.author}: ${pack.quote.text.slice(0, 80)}${
    pack.quote.text.length > 80 ? '...' : ''
  }`;
  const data = {
    deeplink: `aethor://today?date_local=${dateLocal}&focus=checkin`,
    route: 'today',
    date_local: dateLocal,
    version: '1',
  };

  return { title, body, data, dateLocal, pack };
}

export { generate, pickDailyPair, sendDailyPush };

const timezone = process.argv[2] ?? 'America/Sao_Paulo';
const startDate = process.argv[3] ?? new Date().toISOString().slice(0, 10);
const days = Number(process.argv[4] ?? 7);

if (!Number.isInteger(days) || days < 1 || days > 30) {
  // eslint-disable-next-line no-console
  console.error('days must be integer between 1 and 30');
  process.exit(1);
}

const result = generate({ timezone, startDate, days });
// eslint-disable-next-line no-console
console.log(JSON.stringify({
  timezone,
  start_date: startDate,
  days,
  created_count: result.created.length,
  skipped_count: result.skipped.length,
  total_scheduled: result.total
}, null, 2));
