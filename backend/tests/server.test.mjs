import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, readFileSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { DatabaseSync } from 'node:sqlite';

let server;
let baseUrl;
let seed;
let testUserId;
let authToken;
const observabilityToken = 'test-observability-token';

async function createSession(deviceId) {
  const sessionRes = await fetch(`${baseUrl}/v1/session`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ device_id: deviceId })
  });
  assert.ok(sessionRes.status === 200 || sessionRes.status === 201);
  return sessionRes.json();
}

before(async () => {
  const dataDir = mkdtempSync(join(tmpdir(), 'aethor-test-'));
  const __dirname = dirname(fileURLToPath(import.meta.url));
  const seedSourcePath = join(__dirname, '../data/daily_seed.json');
  seed = JSON.parse(readFileSync(seedSourcePath, 'utf-8'));
  writeFileSync(join(dataDir, 'daily_seed.json'), JSON.stringify(seed, null, 2));

  process.env.STOIC_DATA_DIR = dataDir;
  process.env.STOIC_DB_PATH = join(dataDir, 'aethor.db');
  process.env.STOIC_OBSERVABILITY_TOKEN = observabilityToken;
  process.env.FCM_DRY_RUN = 'true';

  const mod = await import('../src/server.mjs');
  server = mod.server;
  server.listen(0, '127.0.0.1');
  await new Promise((resolve) => server.on('listening', resolve));
  const { port } = server.address();
  baseUrl = `http://127.0.0.1:${port}`;

  const sessionData = await createSession('test-device-001');
  testUserId = sessionData.user_id;
  authToken = sessionData.access_token;
});

after(async () => {
  if (!server) return;
  await new Promise((resolve) => server.close(resolve));
});

test('GET /health responde ok', async () => {
  const res = await fetch(`${baseUrl}/health`);
  assert.equal(res.status, 200);
  const data = await res.json();
  assert.equal(data.ok, true);
});

test('GET /v1/observability/metrics exige token quando configurado', async () => {
  const res = await fetch(`${baseUrl}/v1/observability/metrics`);
  assert.equal(res.status, 401);
  const data = await res.json();
  assert.equal(data.error, 'unauthorized');
});

test('GET /v1/observability/metrics retorna métricas operacionais', async () => {
  const res = await fetch(`${baseUrl}/v1/observability/metrics`, {
    headers: {
      'x-observability-token': observabilityToken
    }
  });
  assert.equal(res.status, 200);
  const data = await res.json();
  assert.ok(data.generated_at_utc);
  assert.equal(typeof data.tables.sessions, 'number');
  assert.equal(typeof data.tables.analytics_events, 'number');
  assert.ok(Array.isArray(data.analytics_events_by_name));
});

test('GET /v1/daily-package exige timezone', async () => {
  const res = await fetch(`${baseUrl}/v1/daily-package`);
  assert.equal(res.status, 400);
  const data = await res.json();
  assert.equal(data.error, 'missing_required_query_params');
});

test('GET /v1/daily-package retorna pacote diário', async () => {
  const res = await fetch(
    `${baseUrl}/v1/daily-package?timezone=America/Sao_Paulo&date_local=2026-02-14`
  );
  assert.equal(res.status, 200);
  const data = await res.json();
  assert.equal(data.date_local, '2026-02-14');
  assert.ok(data.quote?.id);
  assert.ok(data.recommendation?.id);
});

test('POST /v1/checkins valida payload', async () => {
  const res = await fetch(`${baseUrl}/v1/checkins`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${authToken}`
    },
    body: JSON.stringify({ user_id: testUserId })
  });
  assert.equal(res.status, 400);
  const data = await res.json();
  assert.equal(data.error, 'missing_required_fields');
});

test('POST /v1/checkins cria check-in', async () => {
  const res = await fetch(`${baseUrl}/v1/checkins`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${authToken}`
    },
    body: JSON.stringify({
      user_id: testUserId,
      date_local: '2026-02-14',
      applied: true,
      timezone: 'America/Sao_Paulo'
    })
  });
  assert.equal(res.status, 201);
  const data = await res.json();
  assert.equal(data.applied, true);
  assert.equal(data.user_id, testUserId);
});

test('GET /v1/subscription/entitlement retorna estado free inicial', async () => {
  const session = await createSession('test-device-subscription-entitlement');
  const res = await fetch(`${baseUrl}/v1/subscription/entitlement`, {
    headers: {
      authorization: `Bearer ${session.access_token}`
    }
  });
  assert.equal(res.status, 200);
  const data = await res.json();
  assert.equal(data.user_id, session.user_id);
  assert.equal(data.status, 'free');
  assert.equal(data.plan, null);
  assert.equal(data.trial_eligible, true);
});

test('POST /v1/subscription/trial/start cria trial anual', async () => {
  const session = await createSession('test-device-subscription-trial');
  const res = await fetch(`${baseUrl}/v1/subscription/trial/start`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${session.access_token}`
    },
    body: JSON.stringify({ plan: 'annual' })
  });
  assert.equal(res.status, 201);
  const data = await res.json();
  assert.equal(data.entitlement.user_id, session.user_id);
  assert.equal(data.entitlement.status, 'trial');
  assert.equal(data.entitlement.plan, 'annual');
  assert.equal(data.entitlement.trial_eligible, false);
  assert.ok(data.entitlement.trial_ends_at_utc);
});

test('POST /v1/subscription/activate e restore com idempotência', async () => {
  const session = await createSession('test-device-subscription-restore');

  const activateRes = await fetch(`${baseUrl}/v1/subscription/activate`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${session.access_token}`
    },
    body: JSON.stringify({ plan: 'monthly' })
  });
  assert.equal(activateRes.status, 200);
  const activateData = await activateRes.json();
  assert.equal(activateData.entitlement.status, 'active');
  assert.equal(activateData.entitlement.plan, 'monthly');
  assert.ok(activateData.entitlement.next_billing_at_utc);

  const firstRestore = await fetch(`${baseUrl}/v1/subscription/restore`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${session.access_token}`
    },
    body: JSON.stringify({ idempotency_key: 'restore-key-001' })
  });
  assert.equal(firstRestore.status, 200);
  const firstRestoreData = await firstRestore.json();
  assert.equal(firstRestoreData.restored, true);
  assert.equal(firstRestoreData.idempotent, false);
  assert.equal(firstRestoreData.entitlement.status, 'active');

  const secondRestore = await fetch(`${baseUrl}/v1/subscription/restore`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${session.access_token}`
    },
    body: JSON.stringify({ idempotency_key: 'restore-key-001' })
  });
  assert.equal(secondRestore.status, 200);
  const secondRestoreData = await secondRestore.json();
  assert.equal(secondRestoreData.restored, true);
  assert.equal(secondRestoreData.idempotent, true);
});

test('POST /v1/analytics/events exige autenticação', async () => {
  const res = await fetch(`${baseUrl}/v1/analytics/events`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({
      event_name: 'paywall_viewed',
      properties: { event_version: 1 }
    })
  });
  assert.equal(res.status, 401);
  const data = await res.json();
  assert.equal(data.error, 'unauthorized');
});

test('POST /v1/analytics/events persiste evento versionado', async () => {
  const res = await fetch(`${baseUrl}/v1/analytics/events`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${authToken}`
    },
    body: JSON.stringify({
      event_name: 'paywall_viewed',
      properties: {
        user_id: 'spoofed-user',
        event_version: 2,
        trigger_type: 'feature_block',
        paywall_variant: 'A',
        plan_selected: 'annual',
        price_displayed: 'R$ 149,00/ano',
        trial_eligible: true
      }
    })
  });
  assert.equal(res.status, 201);
  const payload = await res.json();
  assert.equal(payload.event_name, 'paywall_viewed');
  assert.equal(payload.event_version, 2);

  const analyticsDb = new DatabaseSync(process.env.STOIC_DB_PATH);
  const row = analyticsDb
    .prepare(
      `select event_name, event_version, properties_json
       from analytics_events
       where event_name = ?
       order by created_at_utc desc
       limit 1`
    )
    .get('paywall_viewed');
  analyticsDb.close();

  assert.equal(row.event_name, 'paywall_viewed');
  assert.equal(row.event_version, 2);
  const properties = JSON.parse(row.properties_json);
  assert.equal(properties.user_id, testUserId);
  assert.equal(properties.trigger_type, 'feature_block');
  assert.equal(properties.event_version, 2);
});

test('POST /v1/favorites exige quote existente', async () => {
  const res = await fetch(`${baseUrl}/v1/favorites`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${authToken}`
    },
    body: JSON.stringify({ user_id: testUserId, quote_id: 'quote-inexistente' })
  });
  assert.equal(res.status, 404);
  const data = await res.json();
  assert.equal(data.error, 'quote_not_found');
});

test('POST /v1/favorites cria favorito e lista', async () => {
  const quoteId = seed.quotes[0]?.id;
  assert.ok(quoteId, 'seed sem quotes');

  const createRes = await fetch(`${baseUrl}/v1/favorites`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${authToken}`
    },
    body: JSON.stringify({ user_id: testUserId, quote_id: quoteId })
  });
  assert.equal(createRes.status, 201);

  const listRes = await fetch(`${baseUrl}/v1/favorites?user_id=${testUserId}`, {
    headers: {
      authorization: `Bearer ${authToken}`
    }
  });
  assert.equal(listRes.status, 200);
  const data = await listRes.json();
  assert.equal(data.items.length, 1);
  assert.equal(data.items[0].quote_id, quoteId);
});

test('GET /v1/history valida days', async () => {
  const res = await fetch(
    `${baseUrl}/v1/history?timezone=America/Sao_Paulo&days=31`
  );
  assert.equal(res.status, 400);
  const data = await res.json();
  assert.equal(data.error, 'invalid_days');
});

test('POST /v1/push-tokens exige autenticação', async () => {
  const res = await fetch(`${baseUrl}/v1/push-tokens`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ fcm_token: 'abc123', platform: 'android' })
  });
  assert.equal(res.status, 401);
  const data = await res.json();
  assert.equal(data.error, 'unauthorized');
});

test('POST /v1/push-tokens registra token FCM', async () => {
  const res = await fetch(`${baseUrl}/v1/push-tokens`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${authToken}`
    },
    body: JSON.stringify({ fcm_token: 'test-fcm-token-001', platform: 'ios' })
  });
  assert.equal(res.status, 200);
  const data = await res.json();
  assert.equal(data.user_id, testUserId);
  assert.equal(data.platform, 'ios');
  assert.equal(data.registered, true);
});

test('POST /v1/push-tokens upsert sem duplicar', async () => {
  const res = await fetch(`${baseUrl}/v1/push-tokens`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${authToken}`
    },
    body: JSON.stringify({ fcm_token: 'test-fcm-token-001', platform: 'android' })
  });
  assert.equal(res.status, 200);
  const data = await res.json();
  assert.equal(data.registered, true);

  const analyticsDb = new DatabaseSync(process.env.STOIC_DB_PATH);
  const count = analyticsDb
    .prepare('select count(*) as total from push_tokens where user_id = ?')
    .get(testUserId);
  analyticsDb.close();
  assert.equal(Number(count.total), 1);
});

test('POST /v1/push/send com tokens retorna relatório de entrega (dry-run)', async () => {
  // First register a token for the test user (already done in earlier test).
  const res = await fetch(`${baseUrl}/v1/push/send`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      'x-observability-token': observabilityToken,
    },
    body: JSON.stringify({
      user_id: testUserId,
      title: 'Seu insight do dia',
      body: 'Sêneca: O sofrimento começa na imaginação.',
      data: { deeplink: 'aethor://today?date_local=2026-02-15&focus=checkin' },
    }),
  });
  assert.equal(res.status, 200);
  const data = await res.json();
  assert.equal(data.dry_run, true);
  assert.equal(typeof data.token_count, 'number');
  assert.ok(data.token_count >= 1, 'should have at least 1 token');
});

test('POST /v1/push/send sem tokens retorna sent=0', async () => {
  // Create a fresh user with no tokens registered.
  const session = await createSession('test-device-push-no-tokens');
  const res = await fetch(`${baseUrl}/v1/push/send`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      'x-observability-token': observabilityToken,
    },
    body: JSON.stringify({
      user_id: session.user_id,
      title: 'Test',
      body: 'Test body',
    }),
  });
  assert.equal(res.status, 200);
  const data = await res.json();
  assert.equal(data.sent, 0);
  assert.equal(data.reason, 'no_tokens');
});

test('POST /v1/push/send com token inactive não é incluído', async () => {
  // Register a token and then deactivate it directly in the DB.
  const session = await createSession('test-device-push-inactive');
  await fetch(`${baseUrl}/v1/push-tokens`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${session.access_token}`,
    },
    body: JSON.stringify({ fcm_token: 'inactive-token-001', platform: 'android' }),
  });

  // Deactivate the token directly.
  const analyticsDb = new DatabaseSync(process.env.STOIC_DB_PATH);
  analyticsDb
    .prepare('update push_tokens set active = 0 where fcm_token = ?')
    .run('inactive-token-001');
  analyticsDb.close();

  const res = await fetch(`${baseUrl}/v1/push/send`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      'x-observability-token': observabilityToken,
    },
    body: JSON.stringify({
      user_id: session.user_id,
      title: 'Test',
      body: 'Test inactive',
    }),
  });
  assert.equal(res.status, 200);
  const data = await res.json();
  assert.equal(data.sent, 0);
  assert.equal(data.reason, 'no_tokens');
});

test('POST /v1/purchases/log registra compra', async () => {
  const res = await fetch(`${baseUrl}/v1/purchases/log`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${authToken}`
    },
    body: JSON.stringify({
      product_id: 'aethor_pro_annual',
      platform: 'ios',
      purchase_token: 'sandbox-receipt-token-001',
      transaction_id: 'txn-001'
    })
  });
  assert.equal(res.status, 201);
  const data = await res.json();
  assert.equal(data.user_id, testUserId);
  assert.equal(data.product_id, 'aethor_pro_annual');
  assert.equal(data.logged, true);
});
