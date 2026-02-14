import { createServer } from 'node:http';
import { readFileSync, writeFileSync } from 'node:fs';
import { randomUUID } from 'node:crypto';
import { dirname, join } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const PORT = process.env.PORT || 8787;
const HOST = process.env.HOST || '127.0.0.1';
const __dirname = dirname(fileURLToPath(import.meta.url));
const defaultDataDir = join(__dirname, '../data');
const dataDir = process.env.STOIC_DATA_DIR ?? defaultDataDir;
const seedPath = process.env.STOIC_SEED_PATH ?? join(dataDir, 'daily_seed.json');
const checkinsPath = join(dataDir, 'checkins.json');
const favoritesPath = join(dataDir, 'favorites.json');
const analyticsPath = join(dataDir, 'analytics_events.json');

const seed = JSON.parse(readFileSync(seedPath, 'utf-8'));

function sendJson(res, statusCode, payload) {
  res.writeHead(statusCode, { 'Content-Type': 'application/json; charset=utf-8' });
  res.end(JSON.stringify(payload));
}

function loadCheckins() {
  try {
    return JSON.parse(readFileSync(checkinsPath, 'utf-8'));
  } catch {
    return [];
  }
}

function saveCheckins(checkins) {
  writeFileSync(checkinsPath, JSON.stringify(checkins, null, 2));
}

function loadFavorites() {
  try {
    return JSON.parse(readFileSync(favoritesPath, 'utf-8'));
  } catch {
    return [];
  }
}

function saveFavorites(favorites) {
  writeFileSync(favoritesPath, JSON.stringify(favorites, null, 2));
}

function loadAnalyticsEvents() {
  try {
    return JSON.parse(readFileSync(analyticsPath, 'utf-8'));
  } catch {
    return [];
  }
}

function appendAnalyticsEvent(eventName, properties) {
  const events = loadAnalyticsEvents();
  events.push({
    id: randomUUID(),
    event_name: eventName,
    event_version: 1,
    created_at_utc: new Date().toISOString(),
    ...properties
  });
  writeFileSync(analyticsPath, JSON.stringify(events, null, 2));
}

function stableHash(input) {
  let hash = 0;
  for (let i = 0; i < input.length; i += 1) hash = (hash * 31 + input.charCodeAt(i)) >>> 0;
  return hash;
}

function pickRecommendationForQuote({ quote, userContext, hash }) {
  const quotePool = seed.recommendations.filter((r) => r.quote_id === quote.id);
  const contextPool = userContext
    ? quotePool.filter((r) => r.context === userContext)
    : quotePool;
  const finalPool = contextPool.length > 0 ? contextPool : quotePool;

  if (finalPool.length === 0) {
    return seed.recommendations[hash % seed.recommendations.length];
  }

  const ordered = [...finalPool].sort((a, b) => a.id.localeCompare(b.id));
  return ordered[hash % ordered.length];
}

function pickDailyPair(dateLocal, timezone, userContext) {
  const hash = stableHash(`${dateLocal}:${timezone}:${userContext ?? ''}`);
  const quote = seed.quotes[hash % seed.quotes.length];
  const recommendation = pickRecommendationForQuote({ quote, userContext, hash });

  return {
    date_local: dateLocal,
    timezone,
    user_context: userContext ?? null,
    quote,
    recommendation
  };
}

function localDateFromTimezone(timezone) {
  try {
    const parts = new Intl.DateTimeFormat('en-US', {
      timeZone: timezone,
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    }).formatToParts(new Date());
    const year = parts.find((p) => p.type === 'year')?.value;
    const month = parts.find((p) => p.type === 'month')?.value;
    const day = parts.find((p) => p.type === 'day')?.value;
    if (!year || !month || !day) return null;
    return `${year}-${month}-${day}`;
  } catch {
    return null;
  }
}

function resolveDateLocal(dateLocal, timezone) {
  if (dateLocal) return dateLocal;
  return localDateFromTimezone(timezone);
}

function isoDateOffset(baseDate, daysOffset) {
  const date = new Date(`${baseDate}T00:00:00Z`);
  date.setUTCDate(date.getUTCDate() + daysOffset);
  return date.toISOString().slice(0, 10);
}

function parseBody(req) {
  return new Promise((resolve, reject) => {
    let raw = '';
    req.on('data', (chunk) => {
      raw += chunk;
    });
    req.on('end', () => {
      try {
        resolve(raw ? JSON.parse(raw) : {});
      } catch (err) {
        reject(err);
      }
    });
    req.on('error', reject);
  });
}

const server = createServer(async (req, res) => {
  const url = new URL(req.url, `http://${req.headers.host}`);

  if (req.method === 'GET' && url.pathname === '/health') {
    return sendJson(res, 200, { ok: true, service: 'estoicismo-backend' });
  }

  if (req.method === 'GET' && url.pathname === '/v1/daily-package') {
    const dateLocalParam = url.searchParams.get('date_local');
    const timezone = url.searchParams.get('timezone');
    const userContext = url.searchParams.get('user_context');

    if (!timezone) {
      return sendJson(res, 400, {
        error: 'missing_required_query_params',
        required: ['timezone']
      });
    }

    const dateLocal = resolveDateLocal(dateLocalParam, timezone);
    if (!dateLocal) {
      return sendJson(res, 400, {
        error: 'invalid_timezone',
        message: 'timezone must be a valid IANA timezone'
      });
    }

    const pack = pickDailyPair(dateLocal, timezone, userContext);
    appendAnalyticsEvent('daily_package_viewed', {
      date_local: dateLocal,
      timezone,
      user_context: userContext,
      author: pack.quote.author,
      context: pack.recommendation.context
    });
    return sendJson(res, 200, pack);
  }

  if (req.method === 'POST' && url.pathname === '/v1/checkins') {
    try {
      const body = await parseBody(req);

      const required = ['user_id', 'date_local', 'applied', 'timezone'];
      const missing = required.filter((key) => body[key] === undefined || body[key] === null);
      if (missing.length > 0) {
        return sendJson(res, 400, { error: 'missing_required_fields', missing });
      }

      if (typeof body.applied !== 'boolean') {
        return sendJson(res, 400, { error: 'invalid_applied', message: 'applied must be boolean' });
      }

      const checkins = loadCheckins();
      const existing = checkins.find(
        (c) => c.user_id === body.user_id && c.date_local === body.date_local
      );

      const now = new Date();
      const entry = {
        id: existing?.id ?? randomUUID(),
        user_id: body.user_id,
        date_local: body.date_local,
        applied: body.applied,
        note: body.note ?? null,
        timezone: body.timezone,
        created_at_utc: existing?.created_at_utc ?? now.toISOString(),
        updated_at_utc: now.toISOString()
      };

      const next = existing
        ? checkins.map((c) => (c.id === existing.id ? entry : c))
        : [...checkins, entry];

      saveCheckins(next);
      appendAnalyticsEvent('checkin_submitted', {
        user_id: body.user_id,
        date_local: body.date_local,
        timezone: body.timezone,
        applied: body.applied
      });

      return sendJson(res, existing ? 200 : 201, entry);
    } catch {
      return sendJson(res, 400, { error: 'invalid_json' });
    }
  }

  if (req.method === 'GET' && url.pathname === '/v1/favorites') {
    const userId = url.searchParams.get('user_id');
    if (!userId) {
      return sendJson(res, 400, { error: 'missing_required_query_params', required: ['user_id'] });
    }

    const favorites = loadFavorites().filter((f) => f.user_id === userId);
    return sendJson(res, 200, { items: favorites });
  }

  if (req.method === 'POST' && url.pathname === '/v1/favorites') {
    try {
      const body = await parseBody(req);
      const required = ['user_id', 'quote_id'];
      const missing = required.filter((key) => body[key] === undefined || body[key] === null);
      if (missing.length > 0) {
        return sendJson(res, 400, { error: 'missing_required_fields', missing });
      }

      const quoteExists = seed.quotes.some((q) => q.id === body.quote_id);
      if (!quoteExists) {
        return sendJson(res, 404, { error: 'quote_not_found' });
      }

      const favorites = loadFavorites();
      const existing = favorites.find(
        (f) => f.user_id === body.user_id && f.quote_id === body.quote_id
      );
      if (existing) {
        return sendJson(res, 200, existing);
      }

      const now = new Date().toISOString();
      const entry = {
        id: randomUUID(),
        user_id: body.user_id,
        quote_id: body.quote_id,
        created_at_utc: now
      };
      saveFavorites([...favorites, entry]);
      appendAnalyticsEvent('quote_favorited', {
        user_id: body.user_id,
        quote_id: body.quote_id
      });
      return sendJson(res, 201, entry);
    } catch {
      return sendJson(res, 400, { error: 'invalid_json' });
    }
  }

  if (req.method === 'DELETE' && url.pathname === '/v1/favorites') {
    const userId = url.searchParams.get('user_id');
    const quoteId = url.searchParams.get('quote_id');
    if (!userId || !quoteId) {
      return sendJson(res, 400, {
        error: 'missing_required_query_params',
        required: ['user_id', 'quote_id']
      });
    }

    const favorites = loadFavorites();
    const next = favorites.filter((f) => !(f.user_id === userId && f.quote_id === quoteId));
    const removed = favorites.length - next.length;
    saveFavorites(next);
    if (removed > 0) {
      appendAnalyticsEvent('quote_unfavorited', {
        user_id: userId,
        quote_id: quoteId
      });
    }
    return sendJson(res, 200, { removed });
  }

  if (req.method === 'GET' && url.pathname === '/v1/history') {
    const timezone = url.searchParams.get('timezone');
    const dateLocalParam = url.searchParams.get('date_local');
    const userContext = url.searchParams.get('user_context');
    const daysRaw = url.searchParams.get('days') ?? '30';
    const days = Number(daysRaw);

    if (!timezone) {
      return sendJson(res, 400, {
        error: 'missing_required_query_params',
        required: ['timezone']
      });
    }

    const dateLocal = resolveDateLocal(dateLocalParam, timezone);
    if (!dateLocal) {
      return sendJson(res, 400, {
        error: 'invalid_timezone',
        message: 'timezone must be a valid IANA timezone'
      });
    }

    if (!Number.isInteger(days) || days < 1 || days > 30) {
      return sendJson(res, 400, {
        error: 'invalid_days',
        message: 'days must be an integer between 1 and 30'
      });
    }

    const items = [];
    for (let offset = 0; offset < days; offset += 1) {
      const day = isoDateOffset(dateLocal, -offset);
      items.push(pickDailyPair(day, timezone, userContext));
    }
    return sendJson(res, 200, { items });
  }

  return sendJson(res, 404, { error: 'not_found' });
});

export { server };

const isMain =
  process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href;

if (isMain) {
  server.listen(PORT, HOST, () => {
    // eslint-disable-next-line no-console
    console.log(`estoicismo-backend listening on ${HOST}:${PORT}`);
  });
}
