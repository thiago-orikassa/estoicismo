import { createServer } from 'node:http';
import { readFileSync } from 'node:fs';
import { createHash, randomBytes, randomUUID } from 'node:crypto';
import { dirname, join } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { db, dbPath } from './db.mjs';
import { logger } from './logger.mjs';
import { sendPushNotification, FCM_DRY_RUN, PUSH_ENABLED } from './fcm.mjs';

const PORT = process.env.PORT || 8787;
const HOST = process.env.HOST || '127.0.0.1';
const __dirname = dirname(fileURLToPath(import.meta.url));
const defaultDataDir = join(__dirname, '../data');
const dataDir = process.env.STOIC_DATA_DIR ?? defaultDataDir;
const seedPath = process.env.STOIC_SEED_PATH ?? join(dataDir, 'daily_seed.json');
const observabilityToken = process.env.STOIC_OBSERVABILITY_TOKEN ?? '';

const seed = JSON.parse(readFileSync(seedPath, 'utf-8'));

// ── Security constants ────────────────────────────────────────────────────────

const MAX_BODY_BYTES = 100 * 1024; // 100 KB — protects against payload amplification

// Session TTL: 90 days. Keeps mobile users logged in long-term while bounding
// the blast radius of a leaked token.
const SESSION_TTL_MS = 90 * 24 * 60 * 60 * 1000;
function sessionExpiresAt() {
  return new Date(Date.now() + SESSION_TTL_MS).toISOString();
}

// Cryptographically-strong 256-bit session token (URL-safe hex).
function generateSessionToken() {
  return randomBytes(32).toString('hex');
}

// ── In-memory rate limiter ────────────────────────────────────────────────────
// Uses a fixed-window counter keyed on (route + IP). The Map is pruned every
// minute to prevent unbounded growth.

const _rateLimitCounters = new Map(); // key -> { count, resetAt }
setInterval(() => {
  const now = Date.now();
  for (const [key, entry] of _rateLimitCounters) {
    if (now > entry.resetAt) _rateLimitCounters.delete(key);
  }
}, 60_000).unref();

/**
 * Returns true if the request is within the allowed rate, false if it should
 * be rejected.
 * @param {string} routeKey - Identifies the endpoint (e.g. 'send-otp')
 * @param {string} ip       - Remote IP address
 * @param {number} limit    - Max allowed requests per window
 * @param {number} windowMs - Window duration in milliseconds
 */
function allowRequest(routeKey, ip, limit, windowMs) {
  const key = `${routeKey}:${ip}`;
  const now = Date.now();
  const entry = _rateLimitCounters.get(key);
  if (!entry || now > entry.resetAt) {
    _rateLimitCounters.set(key, { count: 1, resetAt: now + windowMs });
    return true;
  }
  if (entry.count >= limit) return false;
  entry.count += 1;
  return true;
}

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
  select user_id, expires_at_utc
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
    updated_at_utc,
    expires_at_utc
  ) values (?, ?, ?, ?, ?, ?, ?)
`);

const updateSessionToken = db.prepare(`
  update sessions
  set token_hash = ?, updated_at_utc = ?, expires_at_utc = ?
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

const selectSubscriptionProfileByUser = db.prepare(`
  select
    user_id,
    status,
    plan,
    trial_started_at_utc,
    trial_ends_at_utc,
    next_billing_at_utc,
    trial_used,
    updated_at_utc
  from subscription_profiles
  where user_id = ?
`);

const upsertSubscriptionProfile = db.prepare(`
  insert into subscription_profiles (
    user_id,
    status,
    plan,
    trial_started_at_utc,
    trial_ends_at_utc,
    next_billing_at_utc,
    trial_used,
    updated_at_utc
  ) values (?, ?, ?, ?, ?, ?, ?, ?)
  on conflict(user_id) do update set
    status = excluded.status,
    plan = excluded.plan,
    trial_started_at_utc = excluded.trial_started_at_utc,
    trial_ends_at_utc = excluded.trial_ends_at_utc,
    next_billing_at_utc = excluded.next_billing_at_utc,
    trial_used = excluded.trial_used,
    updated_at_utc = excluded.updated_at_utc
`);

const selectRestoreRequestByUserAndKey = db.prepare(`
  select restored, created_at_utc
  from subscription_restore_requests
  where user_id = ? and idempotency_key = ?
`);

const insertRestoreRequest = db.prepare(`
  insert into subscription_restore_requests (
    id,
    user_id,
    idempotency_key,
    restored,
    created_at_utc
  ) values (?, ?, ?, ?, ?)
`);

const countSchemaMigrations = db.prepare(`
  select count(*) as total
  from schema_migrations
`);

const countSessions = db.prepare(`
  select count(*) as total
  from sessions
`);

const countCheckins = db.prepare(`
  select count(*) as total
  from checkins
`);

const countFavorites = db.prepare(`
  select count(*) as total
  from favorites
`);

const countAnalyticsEvents = db.prepare(`
  select count(*) as total
  from analytics_events
`);

const countAnalyticsEventsByName = db.prepare(`
  select event_name, count(*) as total
  from analytics_events
  group by event_name
  order by total desc, event_name asc
`);

const countSubscriptionProfiles = db.prepare(`
  select count(*) as total
  from subscription_profiles
`);

const countSubscriptionProfilesByStatus = db.prepare(`
  select status, count(*) as total
  from subscription_profiles
  group by status
`);

const upsertPushToken = db.prepare(`
  insert into push_tokens (id, user_id, fcm_token, platform, created_at_utc, updated_at_utc)
  values (?, ?, ?, ?, ?, ?)
  on conflict(user_id, fcm_token) do update set
    platform = excluded.platform,
    updated_at_utc = excluded.updated_at_utc
`);

const countPushTokens = db.prepare(`
  select count(*) as total
  from push_tokens
`);

const selectPushTokensByUser = db.prepare(`
  select fcm_token, platform
  from push_tokens
  where user_id = ?
`);

const selectActivePushTokensByUser = db.prepare(`
  select fcm_token, platform
  from push_tokens
  where user_id = ? and active = 1
`);

const selectAllActiveTokens = db.prepare(`
  select pt.fcm_token, pt.platform, pt.user_id
  from push_tokens pt
  where pt.active = 1
`);

const deactivatePushToken = db.prepare(`
  update push_tokens
  set active = 0, updated_at_utc = ?
  where fcm_token = ?
`);

const markPushTokenDelivery = db.prepare(`
  update push_tokens
  set last_delivery_at_utc = ?, failure_count = 0, updated_at_utc = ?
  where fcm_token = ?
`);

const incrementPushTokenFailure = db.prepare(`
  update push_tokens
  set failure_count = failure_count + 1, updated_at_utc = ?
  where fcm_token = ?
`);

const countActivePushTokens = db.prepare(`
  select count(*) as total
  from push_tokens
  where active = 1
`);

const countPushTokensByPlatform = db.prepare(`
  select platform, count(*) as total
  from push_tokens
  where active = 1
  group by platform
`);

const insertPurchaseLog = db.prepare(`
  insert into purchase_logs (id, user_id, product_id, platform, purchase_token, transaction_id, created_at_utc)
  values (?, ?, ?, ?, ?, ?, ?)
`);

const selectUserIdentity = db.prepare(`
  select user_id from user_identities where provider = ? and provider_id = ?
`);

const insertUserIdentity = db.prepare(`
  insert into user_identities (id, user_id, provider, provider_id, email, created_at_utc)
  values (?, ?, ?, ?, ?, ?)
`);

const selectAuthCodeByEmail = db.prepare(`
  select id, code_hash, expires_at_utc, used
  from auth_codes
  where email = ? and used = 0
  order by created_at_utc desc
  limit 1
`);

const insertAuthCode = db.prepare(`
  insert into auth_codes (id, email, code_hash, expires_at_utc, used, created_at_utc)
  values (?, ?, ?, ?, 0, ?)
`);

const markAuthCodeUsed = db.prepare(`
  update auth_codes set used = 1 where id = ?
`);

const selectSessionByUserId = db.prepare(`
  select id, device_id from sessions where user_id = ? limit 1
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

function isSubscriptionPlan(value) {
  return value === 'monthly' || value === 'annual';
}

function plusDays(days) {
  const date = new Date();
  date.setUTCDate(date.getUTCDate() + days);
  return date.toISOString();
}

function normalizeSubscriptionProfile(row) {
  if (!row) return null;
  return {
    ...row,
    trial_used: Boolean(row.trial_used)
  };
}

function toEntitlement(userId, row) {
  const profile = normalizeSubscriptionProfile(row);
  const status = profile?.status ?? 'free';
  const plan = profile?.plan ?? null;
  const trialEligible = !Boolean(profile?.trial_used) && status === 'free';
  return {
    user_id: userId,
    status,
    plan,
    trial_eligible: trialEligible,
    trial_ends_at_utc: profile?.trial_ends_at_utc ?? null,
    next_billing_at_utc: profile?.next_billing_at_utc ?? null
  };
}

function persistSubscriptionProfile({
  userId,
  status,
  plan,
  trialStartedAtUtc = null,
  trialEndsAtUtc = null,
  nextBillingAtUtc = null,
  trialUsed = false
}) {
  const now = new Date().toISOString();
  upsertSubscriptionProfile.run(
    userId,
    status,
    plan,
    trialStartedAtUtc,
    trialEndsAtUtc,
    nextBillingAtUtc,
    trialUsed ? 1 : 0,
    now
  );
}

function isPlainObject(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

function appendAnalyticsEvent(eventName, properties, eventVersion = 1) {
  const now = new Date().toISOString();
  insertAnalyticsEvent.run(
    randomUUID(),
    eventName,
    eventVersion,
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

function requireSession(req, requestMeta) {
  const token = readBearerToken(req);
  if (!token) return null;
  const tokenHash = hashToken(token);
  const session = selectSessionByToken.get(tokenHash);
  if (!session) return null;
  if (session.expires_at_utc && new Date(session.expires_at_utc) < new Date()) return null;
  if (session.user_id && requestMeta) {
    requestMeta.userId = session.user_id;
  }
  return session;
}

function isObservabilityAuthorized(req) {
  if (!observabilityToken) return true;
  const providedToken = req.headers['x-observability-token'];
  return typeof providedToken === 'string' && providedToken === observabilityToken;
}

function collectOperationalMetrics() {
  const subscriptionsByStatus = {
    free: 0,
    trial: 0,
    active: 0,
    canceled: 0
  };
  for (const row of countSubscriptionProfilesByStatus.all()) {
    subscriptionsByStatus[row.status] = Number(row.total ?? 0);
  }

  const tokensByPlatform = {};
  for (const row of countPushTokensByPlatform.all()) {
    tokensByPlatform[row.platform] = Number(row.total ?? 0);
  }

  return {
    generated_at_utc: new Date().toISOString(),
    storage: {
      data_dir: dataDir,
      db_path: dbPath,
      seed_path: seedPath
    },
    tables: {
      schema_migrations: Number(countSchemaMigrations.get().total ?? 0),
      sessions: Number(countSessions.get().total ?? 0),
      checkins: Number(countCheckins.get().total ?? 0),
      favorites: Number(countFavorites.get().total ?? 0),
      analytics_events: Number(countAnalyticsEvents.get().total ?? 0),
      subscription_profiles: Number(countSubscriptionProfiles.get().total ?? 0),
      push_tokens: Number(countPushTokens.get().total ?? 0)
    },
    subscriptions: subscriptionsByStatus,
    push: {
      total_tokens: Number(countPushTokens.get().total ?? 0),
      active_tokens: Number(countActivePushTokens.get().total ?? 0),
      tokens_by_platform: tokensByPlatform,
    },
    analytics_events_by_name: countAnalyticsEventsByName.all().map((row) => ({
      event_name: row.event_name,
      total: Number(row.total ?? 0)
    }))
  };
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
    let size = 0;
    req.on('data', (chunk) => {
      size += chunk.length;
      if (size > MAX_BODY_BYTES) {
        req.destroy();
        return reject(Object.assign(new Error('payload_too_large'), { statusCode: 413 }));
      }
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

let _appleKeysCache = null;
let _appleKeysCacheExpiry = 0;

async function getApplePublicKeys() {
  if (_appleKeysCache && Date.now() < _appleKeysCacheExpiry) {
    return _appleKeysCache;
  }
  const res = await fetch('https://appleid.apple.com/auth/keys');
  const { keys } = await res.json();
  _appleKeysCache = keys;
  _appleKeysCacheExpiry = Date.now() + 3_600_000;
  return keys;
}

async function verifyAppleJwt(identityToken) {
  const parts = identityToken.split('.');
  if (parts.length !== 3) throw new Error('invalid_jwt_format');
  const [headerB64, payloadB64, signatureB64] = parts;

  const header = JSON.parse(Buffer.from(headerB64, 'base64url').toString('utf-8'));
  const keys = await getApplePublicKeys();
  const jwk = keys.find((k) => k.kid === header.kid);
  if (!jwk) throw new Error('key_not_found');

  const { webcrypto } = await import('node:crypto');
  const publicKey = await webcrypto.subtle.importKey(
    'jwk', jwk,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false, ['verify']
  );

  const signingInput = `${headerB64}.${payloadB64}`;
  const signature = Buffer.from(signatureB64, 'base64url');
  const valid = await webcrypto.subtle.verify(
    { name: 'RSASSA-PKCS1-v1_5' },
    publicKey,
    signature,
    Buffer.from(signingInput)
  );

  if (!valid) throw new Error('invalid_signature');

  return JSON.parse(Buffer.from(payloadB64, 'base64url').toString('utf-8'));
}

const server = createServer(async (req, res) => {
  const url = new URL(req.url, `http://${req.headers.host}`);
  const requestMeta = {
    requestId: randomUUID(),
    userId: null
  };
  const startedAtNs = process.hrtime.bigint();
  res.setHeader('x-request-id', requestMeta.requestId);
  res.on('finish', () => {
    const elapsedNs = process.hrtime.bigint() - startedAtNs;
    const durationMs = Number(elapsedNs) / 1_000_000;
    logger.info('http_request_completed', {
      request_id: requestMeta.requestId,
      method: req.method,
      path: url.pathname,
      status_code: res.statusCode,
      duration_ms: Number(durationMs.toFixed(2)),
      remote_ip: req.socket.remoteAddress ?? null,
      user_id: requestMeta.userId
    });
  });

  if (req.method === 'GET' && url.pathname === '/health') {
    return sendJson(res, 200, { ok: true, service: 'aethor-backend' });
  }

  // Apple App Site Association — required for Universal Links (iOS deeplinks via https://)
  // Apple fetches this file from https://aethor.app/.well-known/apple-app-site-association
  if (
    req.method === 'GET' &&
    (url.pathname === '/.well-known/apple-app-site-association' ||
      url.pathname === '/apple-app-site-association')
  ) {
    const aasa = {
      applinks: {
        apps: [],
        details: [
          {
            appID: 'CK8Q479NZG.com.thiago.aethorApp',
            paths: ['/today', '/history', '/favorites', '/settings', '/today/*'],
          },
        ],
      },
    };
    res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' });
    return res.end(JSON.stringify(aasa));
  }

  if (req.method === 'GET' && url.pathname === '/v1/observability/metrics') {
    if (!isObservabilityAuthorized(req)) {
      logger.warn('observability_metrics_unauthorized', {
        request_id: requestMeta.requestId
      });
      return sendJson(res, 401, { error: 'unauthorized' });
    }
    return sendJson(res, 200, collectOperationalMetrics());
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
      const token = generateSessionToken();
      const tokenHash = hashToken(token);
      const now = new Date().toISOString();
      const expiresAt = sessionExpiresAt();

      if (existing) {
        updateSessionToken.run(tokenHash, now, expiresAt, deviceId);
        return sendJson(res, 200, {
          user_id: existing.user_id,
          access_token: token
        });
      }

      const userId = randomUUID();
      insertSession.run(randomUUID(), userId, deviceId, tokenHash, now, now, expiresAt);
      return sendJson(res, 201, { user_id: userId, access_token: token });
    } catch {
      return sendJson(res, 400, { error: 'invalid_json' });
    }
  }

  if (req.method === 'GET' && url.pathname === '/v1/subscription/entitlement') {
    const session = requireSession(req, requestMeta);
    if (!session) {
      return sendJson(res, 401, { error: 'unauthorized' });
    }
    const profile = selectSubscriptionProfileByUser.get(session.user_id);
    return sendJson(res, 200, toEntitlement(session.user_id, profile));
  }

  if (req.method === 'POST' && url.pathname === '/v1/subscription/trial/start') {
    const session = requireSession(req, requestMeta);
    if (!session) {
      return sendJson(res, 401, { error: 'unauthorized' });
    }

    try {
      const body = await parseBody(req);
      const plan = body.plan ?? 'annual';
      if (plan !== 'annual') {
        return sendJson(res, 400, {
          error: 'invalid_plan_for_trial',
          message: 'trial is available only for annual plan'
        });
      }

      const current = normalizeSubscriptionProfile(
        selectSubscriptionProfileByUser.get(session.user_id)
      );
      if (current?.status === 'active' || current?.status === 'trial') {
        return sendJson(res, 200, {
          entitlement: toEntitlement(session.user_id, current)
        });
      }

      if (current?.trial_used) {
        return sendJson(res, 409, {
          error: 'trial_already_used',
          entitlement: toEntitlement(session.user_id, current)
        });
      }

      const now = new Date().toISOString();
      const trialEndsAtUtc = plusDays(7);
      persistSubscriptionProfile({
        userId: session.user_id,
        status: 'trial',
        plan: 'annual',
        trialStartedAtUtc: now,
        trialEndsAtUtc,
        nextBillingAtUtc: null,
        trialUsed: true
      });

      appendAnalyticsEvent('trial_started', {
        user_id: session.user_id,
        plan_selected: 'annual',
        trial_eligible: true,
        event_version: 1
      });

      const updated = selectSubscriptionProfileByUser.get(session.user_id);
      return sendJson(res, 201, {
        entitlement: toEntitlement(session.user_id, updated)
      });
    } catch {
      return sendJson(res, 400, { error: 'invalid_json' });
    }
  }

  if (req.method === 'POST' && url.pathname === '/v1/subscription/activate') {
    const session = requireSession(req, requestMeta);
    if (!session) {
      return sendJson(res, 401, { error: 'unauthorized' });
    }

    try {
      const body = await parseBody(req);
      const plan = body.plan;
      if (!isSubscriptionPlan(plan)) {
        return sendJson(res, 400, {
          error: 'invalid_plan',
          message: 'plan must be monthly or annual'
        });
      }

      const current = normalizeSubscriptionProfile(
        selectSubscriptionProfileByUser.get(session.user_id)
      );
      const trialUsed = Boolean(current?.trial_used);
      const nextBillingAtUtc = plusDays(plan === 'monthly' ? 30 : 365);

      persistSubscriptionProfile({
        userId: session.user_id,
        status: 'active',
        plan,
        trialStartedAtUtc: null,
        trialEndsAtUtc: null,
        nextBillingAtUtc,
        trialUsed
      });

      appendAnalyticsEvent('subscription_activated', {
        user_id: session.user_id,
        plan_selected: plan,
        trial_eligible: !trialUsed && plan === 'annual',
        event_version: 1
      });

      const updated = selectSubscriptionProfileByUser.get(session.user_id);
      return sendJson(res, 200, {
        entitlement: toEntitlement(session.user_id, updated)
      });
    } catch {
      return sendJson(res, 400, { error: 'invalid_json' });
    }
  }

  if (req.method === 'POST' && url.pathname === '/v1/subscription/restore') {
    const session = requireSession(req, requestMeta);
    if (!session) {
      return sendJson(res, 401, { error: 'unauthorized' });
    }

    try {
      const body = await parseBody(req);
      const key =
        typeof body.idempotency_key === 'string' ? body.idempotency_key.trim() : '';
      if (key.length === 0 || key.length > 128) {
        return sendJson(res, 400, {
          error: 'invalid_idempotency_key',
          message: 'idempotency_key must be non-empty string (<= 128 chars)'
        });
      }

      const existing = selectRestoreRequestByUserAndKey.get(session.user_id, key);
      if (existing) {
        const current = selectSubscriptionProfileByUser.get(session.user_id);
        return sendJson(res, 200, {
          restored: Boolean(existing.restored),
          idempotent: true,
          entitlement: toEntitlement(session.user_id, current)
        });
      }

      const current = normalizeSubscriptionProfile(
        selectSubscriptionProfileByUser.get(session.user_id)
      );
      const restored = current?.status === 'active' || current?.status === 'trial';
      const now = new Date().toISOString();

      insertRestoreRequest.run(randomUUID(), session.user_id, key, restored ? 1 : 0, now);
      appendAnalyticsEvent(
        restored ? 'restore_purchase_success' : 'restore_purchase_failed',
        {
          user_id: session.user_id,
          restored,
          idempotency_key: key,
          event_version: 1
        }
      );

      return sendJson(res, 200, {
        restored,
        idempotent: false,
        entitlement: toEntitlement(session.user_id, current)
      });
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

  if (req.method === 'POST' && url.pathname === '/v1/analytics/events') {
    const session = requireSession(req, requestMeta);
    if (!session) {
      return sendJson(res, 401, { error: 'unauthorized' });
    }

    try {
      const body = await parseBody(req);
      const eventName = typeof body.event_name === 'string' ? body.event_name.trim() : '';
      if (eventName.length === 0 || eventName.length > 64) {
        return sendJson(res, 400, {
          error: 'invalid_event_name',
          message: 'event_name must be non-empty string (<= 64 chars)'
        });
      }

      if (!isPlainObject(body.properties)) {
        return sendJson(res, 400, {
          error: 'invalid_properties',
          message: 'properties must be a JSON object'
        });
      }

      const requestedVersion = body.properties.event_version;
      const eventVersion = requestedVersion === undefined ? 1 : Number(requestedVersion);
      if (!Number.isInteger(eventVersion) || eventVersion < 1 || eventVersion > 999) {
        return sendJson(res, 400, {
          error: 'invalid_event_version',
          message: 'event_version must be an integer between 1 and 999'
        });
      }

      const normalizedProperties = {
        ...body.properties,
        user_id: session.user_id,
        event_version: eventVersion
      };
      appendAnalyticsEvent(eventName, normalizedProperties, eventVersion);
      return sendJson(res, 201, {
        event_name: eventName,
        event_version: eventVersion
      });
    } catch {
      return sendJson(res, 400, { error: 'invalid_json' });
    }
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

      const session = requireSession(req, requestMeta);
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

    const session = requireSession(req, requestMeta);
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

      const session = requireSession(req, requestMeta);
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

    const session = requireSession(req, requestMeta);
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

  if (req.method === 'POST' && url.pathname === '/v1/push-tokens') {
    const session = requireSession(req, requestMeta);
    if (!session) {
      return sendJson(res, 401, { error: 'unauthorized' });
    }

    try {
      const body = await parseBody(req);
      const fcmToken = typeof body.fcm_token === 'string' ? body.fcm_token.trim() : '';
      if (fcmToken.length === 0 || fcmToken.length > 4096) {
        return sendJson(res, 400, {
          error: 'invalid_fcm_token',
          message: 'fcm_token must be non-empty string (<= 4096 chars)'
        });
      }

      const platform = typeof body.platform === 'string' ? body.platform.trim() : 'android';
      if (platform !== 'android' && platform !== 'ios') {
        return sendJson(res, 400, {
          error: 'invalid_platform',
          message: 'platform must be android or ios'
        });
      }

      const now = new Date().toISOString();
      upsertPushToken.run(randomUUID(), session.user_id, fcmToken, platform, now, now);

      return sendJson(res, 200, {
        user_id: session.user_id,
        platform,
        registered: true
      });
    } catch {
      return sendJson(res, 400, { error: 'invalid_json' });
    }
  }

  if (req.method === 'POST' && url.pathname === '/v1/push/send') {
    if (!isObservabilityAuthorized(req)) {
      return sendJson(res, 401, { error: 'unauthorized' });
    }

    try {
      const body = await parseBody(req);
      const userId = body.user_id;
      const title = body.title ?? '';
      const bodyText = body.body ?? '';
      const data = body.data ?? {};

      if (!isUuid(userId)) {
        return sendJson(res, 400, {
          error: 'invalid_user_id',
          message: 'user_id must be uuid'
        });
      }

      const tokens = selectActivePushTokensByUser.all(userId);
      if (tokens.length === 0) {
        return sendJson(res, 200, { sent: 0, failed: 0, invalid_tokens_removed: 0, reason: 'no_tokens' });
      }

      if (FCM_DRY_RUN || !PUSH_ENABLED) {
        return sendJson(res, 200, {
          sent: 0,
          failed: 0,
          invalid_tokens_removed: 0,
          dry_run: true,
          token_count: tokens.length,
          payload: { title, body: bodyText, data }
        });
      }

      let sent = 0;
      let failed = 0;
      let invalidTokensRemoved = 0;
      const now = new Date().toISOString();

      for (const row of tokens) {
        const result = await sendPushNotification({
          fcmToken: row.fcm_token,
          title,
          body: bodyText,
          data,
        });

        if (result.success) {
          sent += 1;
          markPushTokenDelivery.run(now, now, row.fcm_token);
        } else {
          failed += 1;
          if (result.unregistered) {
            deactivatePushToken.run(now, row.fcm_token);
            invalidTokensRemoved += 1;
          } else {
            incrementPushTokenFailure.run(now, row.fcm_token);
          }
        }
      }

      return sendJson(res, 200, { sent, failed, invalid_tokens_removed: invalidTokensRemoved });
    } catch {
      return sendJson(res, 400, { error: 'invalid_json' });
    }
  }

  if (req.method === 'POST' && url.pathname === '/v1/purchases/log') {
    const session = requireSession(req, requestMeta);
    if (!session) {
      return sendJson(res, 401, { error: 'unauthorized' });
    }

    try {
      const body = await parseBody(req);
      const productId = typeof body.product_id === 'string' ? body.product_id.trim() : '';
      const platform = typeof body.platform === 'string' ? body.platform.trim() : '';
      const purchaseToken = typeof body.purchase_token === 'string' ? body.purchase_token : null;
      const transactionId = typeof body.transaction_id === 'string' ? body.transaction_id : null;

      if (productId.length === 0) {
        return sendJson(res, 400, {
          error: 'invalid_product_id',
          message: 'product_id must be non-empty string'
        });
      }

      if (platform !== 'android' && platform !== 'ios') {
        return sendJson(res, 400, {
          error: 'invalid_platform',
          message: 'platform must be android or ios'
        });
      }

      const now = new Date().toISOString();
      insertPurchaseLog.run(
        randomUUID(),
        session.user_id,
        productId,
        platform,
        purchaseToken,
        transactionId,
        now
      );

      return sendJson(res, 201, {
        user_id: session.user_id,
        product_id: productId,
        platform,
        logged: true
      });
    } catch {
      return sendJson(res, 400, { error: 'invalid_json' });
    }
  }

  if (req.method === 'POST' && url.pathname === '/v1/auth/send-otp') {
    // 5 OTP requests per IP per 15 minutes — prevents email spam abuse.
    const ip = req.socket.remoteAddress ?? 'unknown';
    if (!allowRequest('send-otp', ip, 5, 15 * 60_000)) {
      return sendJson(res, 429, { error: 'too_many_requests', retry_after_seconds: 900 });
    }

    try {
      const body = await parseBody(req);
      const email = typeof body.email === 'string' ? body.email.toLowerCase().trim() : '';
      if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        return sendJson(res, 400, { error: 'invalid_email' });
      }

      // Find or create user identity for this email
      let identity = selectUserIdentity.get('email', email);
      const now = new Date().toISOString();
      if (!identity) {
        const userId = randomUUID();
        insertUserIdentity.run(randomUUID(), userId, 'email', email, email, now);
        identity = { user_id: userId };
      }

      // Generate 6-digit code and store hash
      const code = String(Math.floor(100000 + Math.random() * 900000));
      const codeHash = createHash('sha256').update(code).digest('hex');
      const expiresAt = new Date(Date.now() + 10 * 60 * 1000).toISOString();
      insertAuthCode.run(randomUUID(), email, codeHash, expiresAt, now);

      // Send email via Resend
      const resendApiKey = process.env.RESEND_API_KEY;
      if (resendApiKey) {
        await fetch('https://api.resend.com/emails', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${resendApiKey}`
          },
          body: JSON.stringify({
            from: 'Aethor <noreply@aethor.co>',
            to: [email],
            subject: 'Seu código de acesso Aethor',
            text: `Seu código de acesso é: ${code}\n\nEste código expira em 10 minutos.`
          })
        });
      } else {
        logger.info('otp_code_dev', { email, code });
      }

      return sendJson(res, 200, { ok: true });
    } catch {
      return sendJson(res, 400, { error: 'invalid_json' });
    }
  }

  if (req.method === 'POST' && url.pathname === '/v1/auth/verify-otp') {
    // 10 attempts per IP per 15 minutes — prevents brute-force of 6-digit codes.
    const ip = req.socket.remoteAddress ?? 'unknown';
    if (!allowRequest('verify-otp', ip, 10, 15 * 60_000)) {
      return sendJson(res, 429, { error: 'too_many_requests', retry_after_seconds: 900 });
    }

    try {
      const body = await parseBody(req);
      const email = typeof body.email === 'string' ? body.email.toLowerCase().trim() : '';
      const code = typeof body.code === 'string' ? body.code.trim() : '';

      if (!email || !code) {
        return sendJson(res, 400, { error: 'missing_fields' });
      }

      const record = selectAuthCodeByEmail.get(email);
      if (!record) {
        return sendJson(res, 401, { error: 'invalid_code' });
      }

      if (new Date(record.expires_at_utc) < new Date()) {
        return sendJson(res, 410, { error: 'expired_code' });
      }

      const codeHash = createHash('sha256').update(code).digest('hex');
      if (codeHash !== record.code_hash) {
        return sendJson(res, 401, { error: 'invalid_code' });
      }

      markAuthCodeUsed.run(record.id);

      const identity = selectUserIdentity.get('email', email);
      if (!identity) {
        return sendJson(res, 500, { error: 'identity_not_found' });
      }
      const userId = identity.user_id;

      const token = generateSessionToken();
      const tokenHash = hashToken(token);
      const now = new Date().toISOString();
      const expiresAt = sessionExpiresAt();
      const existingSession = selectSessionByUserId.get(userId);
      if (existingSession) {
        updateSessionToken.run(tokenHash, now, expiresAt, existingSession.device_id);
      } else {
        insertSession.run(randomUUID(), userId, `email:${userId}`, tokenHash, now, now, expiresAt);
      }

      return sendJson(res, 200, { user_id: userId, access_token: token });
    } catch {
      return sendJson(res, 400, { error: 'invalid_json' });
    }
  }

  if (req.method === 'POST' && url.pathname === '/v1/auth/oauth') {
    // 20 attempts per IP per 15 minutes — prevents token stuffing.
    const ip = req.socket.remoteAddress ?? 'unknown';
    if (!allowRequest('auth-oauth', ip, 20, 15 * 60_000)) {
      return sendJson(res, 429, { error: 'too_many_requests', retry_after_seconds: 900 });
    }

    try {
      const body = await parseBody(req);
      const provider = typeof body.provider === 'string' ? body.provider : '';
      const identityToken = typeof body.identity_token === 'string' ? body.identity_token : '';
      const emailFromBody = typeof body.email === 'string' ? body.email.toLowerCase().trim() : '';

      if (!['apple', 'google'].includes(provider) || !identityToken) {
        return sendJson(res, 400, { error: 'invalid_request' });
      }

      let providerId, providerEmail;

      if (provider === 'google') {
        const verifyRes = await fetch(
          `https://oauth2.googleapis.com/tokeninfo?id_token=${encodeURIComponent(identityToken)}`
        );
        if (!verifyRes.ok) {
          return sendJson(res, 401, { error: 'invalid_token' });
        }
        const tokenInfo = await verifyRes.json();
        providerId = tokenInfo.sub;
        providerEmail = tokenInfo.email || emailFromBody;
      } else {
        // Apple: verify JWT using Apple's JWKS via Node.js webcrypto
        try {
          const applePayload = await verifyAppleJwt(identityToken);
          providerId = applePayload.sub;
          providerEmail = applePayload.email || emailFromBody;
        } catch {
          return sendJson(res, 401, { error: 'invalid_token' });
        }
      }

      if (!providerId) {
        return sendJson(res, 401, { error: 'invalid_token' });
      }

      const existingIdentity = selectUserIdentity.get(provider, providerId);
      const now = new Date().toISOString();
      let userId;

      if (existingIdentity) {
        userId = existingIdentity.user_id;
      } else {
        const session = requireSession(req, requestMeta);
        userId = session?.user_id ?? randomUUID();
        insertUserIdentity.run(randomUUID(), userId, provider, providerId, providerEmail, now);
      }

      const token = generateSessionToken();
      const tokenHash = hashToken(token);
      const expiresAt = sessionExpiresAt();
      const existingSession = selectSessionByUserId.get(userId);
      if (existingSession) {
        updateSessionToken.run(tokenHash, now, expiresAt, existingSession.device_id);
      } else {
        insertSession.run(randomUUID(), userId, `${provider}:${userId}`, tokenHash, now, now, expiresAt);
      }

      return sendJson(res, 200, { user_id: userId, access_token: token });
    } catch {
      return sendJson(res, 400, { error: 'invalid_json' });
    }
  }

  return sendJson(res, 404, { error: 'not_found' });
});

export { server };

const isMain =
  process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href;

if (isMain) {
  logger.info('server_bootstrap', {
    host: HOST,
    port: Number(PORT),
    data_dir: dataDir,
    db_path: dbPath,
    seed_path: seedPath,
    observability_metrics_protected: Boolean(observabilityToken)
  });
  server.listen(PORT, HOST, () => {
    logger.info('server_listening', {
      host: HOST,
      port: Number(PORT)
    });
  });
}
