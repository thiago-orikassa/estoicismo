import { createServer } from 'node:http';
import { readFileSync } from 'node:fs';
import { createHash, randomUUID } from 'node:crypto';
import { dirname, join } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { db } from './db.mjs';

const PORT = process.env.PORT || 8787;
const HOST = process.env.HOST || '127.0.0.1';
const __dirname = dirname(fileURLToPath(import.meta.url));
const defaultDataDir = join(__dirname, '../data');
const dataDir = process.env.STOIC_DATA_DIR ?? defaultDataDir;
const seedPath = process.env.STOIC_SEED_PATH ?? join(dataDir, 'daily_seed.json');

const seed = JSON.parse(readFileSync(seedPath, 'utf-8'));

function sendJson(res, statusCode, payload) {
  res.writeHead(statusCode, { 'Content-Type': 'application/json; charset=utf-8' });
  res.end(JSON.stringify(payload));
}

const insertAnalyticsEvent = db.prepare(`
  insert into analytics_events (
    id,
    event_name,
    event_version,
    created_at_utc,
    properties_json
  ) values (?, ?, ?, ?, ?)
`);

const selectSessionByDeviceId = db.prepare(`
  select user_id
  from sessions
  where device_id = ?
`);

const selectSessionByToken = db.prepare(`
  select user_id
  from sessions
  where token_hash = ?
`);

const insertSession = db.prepare(`
  insert into sessions (
    id,
    user_id,
    device_id,
    token_hash,
    created_at_utc,
    updated_at_utc
  ) values (?, ?, ?, ?, ?, ?)
`);

const updateSessionToken = db.prepare(`
  update sessions
  set token_hash = ?, updated_at_utc = ?
  where device_id = ?
`);

const selectCheckinByUserAndDate = db.prepare(`
  select id, user_id, date_local, applied, note, timezone, created_at_utc, updated_at_utc
  from checkins
  where user_id = ? and date_local = ?
`);

const insertCheckin = db.prepare(`
  insert into checkins (
    id,
    user_id,
    date_local,
    applied,
    note,
    timezone,
    created_at_utc,
    updated_at_utc
  ) values (?, ?, ?, ?, ?, ?, ?, ?)
`);

const updateCheckin = db.prepare(`
  update checkins
  set applied = ?, note = ?, timezone = ?, updated_at_utc = ?
  where id = ?
`);

const listFavoritesByUser = db.prepare(`
  select id, user_id, quote_id, created_at_utc
  from favorites
  where user_id = ?
  order by created_at_utc desc
`);

const selectFavorite = db.prepare(`
  select id, user_id, quote_id, created_at_utc
  from favorites
  where user_id = ? and quote_id = ?
`);

const insertFavorite = db.prepare(`
  insert into favorites (id, user_id, quote_id, created_at_utc)
  values (?, ?, ?, ?)
`);

const deleteFavorite = db.prepare(`
  delete from favorites
  where user_id = ? and quote_id = ?
`);

const uuidRegex =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function isUuid(value) {
  return typeof value === 'string' && uuidRegex.test(value);
}

function isIsoDate(value) {
  return typeof value === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(value);
}

function normalizeCheckin(row) {
  if (!row) return null;
  return { ...row, applied: Boolean(row.applied) };
}

function appendAnalyticsEvent(eventName, properties) {
  const now = new Date().toISOString();
  insertAnalyticsEvent.run(
    randomUUID(),
    eventName,
    1,
    now,
    JSON.stringify(properties ?? {})
  );
}

function hashToken(token) {
  return createHash('sha256').update(token).digest('hex');
}

function readBearerToken(req) {
  const header = req.headers.authorization;
  if (!header) return null;
  const [scheme, token] = header.split(' ');
  if (scheme !== 'Bearer' || !token) return null;
  return token;
}

function requireSession(req) {
  const token = readBearerToken(req);
  if (!token) return null;
  const tokenHash = hashToken(token);
  return selectSessionByToken.get(tokenHash);
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

function isValidTimezone(timezone) {
  try {
    new Intl.DateTimeFormat('en-US', { timeZone: timezone });
    return true;
  } catch {
    return false;
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

  if (req.method === 'POST' && url.pathname === '/v1/session') {
    try {
      const body = await parseBody(req);
      const deviceId = body.device_id;

      if (typeof deviceId !== 'string' || deviceId.trim().length === 0) {
        return sendJson(res, 400, {
          error: 'invalid_device_id',
          message: 'device_id must be non-empty string'
        });
      }

      if (deviceId.length > 128) {
        return sendJson(res, 400, {
          error: 'invalid_device_id',
          message: 'device_id must be <= 128 chars'
        });
      }

      const existing = selectSessionByDeviceId.get(deviceId);
      const token = randomUUID();
      const tokenHash = hashToken(token);
      const now = new Date().toISOString();

      if (existing) {
        updateSessionToken.run(tokenHash, now, deviceId);
        return sendJson(res, 200, {
          user_id: existing.user_id,
          access_token: token
        });
      }

      const userId = randomUUID();
      insertSession.run(randomUUID(), userId, deviceId, tokenHash, now, now);
      return sendJson(res, 201, { user_id: userId, access_token: token });
    } catch {
      return sendJson(res, 400, { error: 'invalid_json' });
    }
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

      if (!isUuid(body.user_id)) {
        return sendJson(res, 400, { error: 'invalid_user_id', message: 'user_id must be uuid' });
      }

      if (!isIsoDate(body.date_local)) {
        return sendJson(res, 400, {
          error: 'invalid_date_local',
          message: 'date_local must be YYYY-MM-DD'
        });
      }

      if (!isValidTimezone(body.timezone)) {
        return sendJson(res, 400, {
          error: 'invalid_timezone',
          message: 'timezone must be a valid IANA timezone'
        });
      }

      if (typeof body.applied !== 'boolean') {
        return sendJson(res, 400, { error: 'invalid_applied', message: 'applied must be boolean' });
      }

      const session = requireSession(req);
      if (!session) {
        return sendJson(res, 401, { error: 'unauthorized' });
      }
      if (session.user_id !== body.user_id) {
        return sendJson(res, 403, { error: 'user_mismatch' });
      }

      const existing = selectCheckinByUserAndDate.get(body.user_id, body.date_local);
      const now = new Date().toISOString();

      if (existing) {
        updateCheckin.run(
          body.applied ? 1 : 0,
          body.note ?? null,
          body.timezone,
          now,
          existing.id
        );
      } else {
        insertCheckin.run(
          randomUUID(),
          body.user_id,
          body.date_local,
          body.applied ? 1 : 0,
          body.note ?? null,
          body.timezone,
          now,
          now
        );
      }

      const stored = normalizeCheckin(
        selectCheckinByUserAndDate.get(body.user_id, body.date_local)
      );
      appendAnalyticsEvent('checkin_submitted', {
        user_id: body.user_id,
        date_local: body.date_local,
        timezone: body.timezone,
        applied: body.applied
      });

      return sendJson(res, existing ? 200 : 201, stored);
    } catch {
      return sendJson(res, 400, { error: 'invalid_json' });
    }
  }

  if (req.method === 'GET' && url.pathname === '/v1/favorites') {
    const userId = url.searchParams.get('user_id');
    if (!userId) {
      return sendJson(res, 400, { error: 'missing_required_query_params', required: ['user_id'] });
    }
    if (!isUuid(userId)) {
      return sendJson(res, 400, { error: 'invalid_user_id', message: 'user_id must be uuid' });
    }

    const session = requireSession(req);
    if (!session) {
      return sendJson(res, 401, { error: 'unauthorized' });
    }
    if (session.user_id !== userId) {
      return sendJson(res, 403, { error: 'user_mismatch' });
    }

    const favorites = listFavoritesByUser.all(userId);
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
      if (!isUuid(body.user_id)) {
        return sendJson(res, 400, { error: 'invalid_user_id', message: 'user_id must be uuid' });
      }
      if (typeof body.quote_id !== 'string' || body.quote_id.trim().length === 0) {
        return sendJson(res, 400, { error: 'invalid_quote_id', message: 'quote_id must be string' });
      }

      const session = requireSession(req);
      if (!session) {
        return sendJson(res, 401, { error: 'unauthorized' });
      }
      if (session.user_id !== body.user_id) {
        return sendJson(res, 403, { error: 'user_mismatch' });
      }

      const quoteExists = seed.quotes.some((q) => q.id === body.quote_id);
      if (!quoteExists) {
        return sendJson(res, 404, { error: 'quote_not_found' });
      }

      const existing = selectFavorite.get(body.user_id, body.quote_id);
      if (existing) {
        return sendJson(res, 200, existing);
      }

      const now = new Date().toISOString();
      insertFavorite.run(randomUUID(), body.user_id, body.quote_id, now);
      const entry = selectFavorite.get(body.user_id, body.quote_id);
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
    if (!isUuid(userId)) {
      return sendJson(res, 400, { error: 'invalid_user_id', message: 'user_id must be uuid' });
    }

    const session = requireSession(req);
    if (!session) {
      return sendJson(res, 401, { error: 'unauthorized' });
    }
    if (session.user_id !== userId) {
      return sendJson(res, 403, { error: 'user_mismatch' });
    }

    const result = deleteFavorite.run(userId, quoteId);
    const removed = result?.changes ?? 0;
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
