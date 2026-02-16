import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, readFileSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

let server;
let baseUrl;

before(async () => {
  const dataDir = mkdtempSync(join(tmpdir(), 'aethor-monetization-'));
  const __dirname = dirname(fileURLToPath(import.meta.url));
  const seedSourcePath = join(__dirname, '../data/daily_seed.json');
  const seed = JSON.parse(readFileSync(seedSourcePath, 'utf-8'));
  writeFileSync(join(dataDir, 'daily_seed.json'), JSON.stringify(seed, null, 2));

  process.env.STOIC_DATA_DIR = dataDir;
  process.env.STOIC_DB_PATH = join(dataDir, 'aethor.db');
  process.env.STOIC_OBSERVABILITY_TOKEN = 'monetization-test-token';

  const mod = await import('../src/server.mjs');
  server = mod.server;
  server.listen(0, '127.0.0.1');
  await new Promise((resolve) => server.on('listening', resolve));
  const { port } = server.address();
  baseUrl = `http://127.0.0.1:${port}`;
});

after(async () => {
  if (!server) return;
  await new Promise((resolve) => server.close(resolve));
});

async function createSession(deviceId) {
  const res = await fetch(`${baseUrl}/v1/session`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ device_id: deviceId })
  });
  assert.ok(res.status === 200 || res.status === 201);
  return res.json();
}

test('E2E monetização: free → trial → checkin → trial não repete → activate → purchase log → restore idempotente → daily-package continua', async () => {
  const session = await createSession('monetization-device-001');
  const token = session.access_token;
  const userId = session.user_id;

  // 1. Verify user starts as free with trial eligible.
  const entitlementRes1 = await fetch(`${baseUrl}/v1/subscription/entitlement`, {
    headers: { authorization: `Bearer ${token}` }
  });
  assert.equal(entitlementRes1.status, 200);
  const ent1 = await entitlementRes1.json();
  assert.equal(ent1.status, 'free');
  assert.equal(ent1.trial_eligible, true);

  // 2. Start trial.
  const trialRes = await fetch(`${baseUrl}/v1/subscription/trial/start`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${token}`
    },
    body: JSON.stringify({ plan: 'annual' })
  });
  assert.equal(trialRes.status, 201);
  const trialData = await trialRes.json();
  assert.equal(trialData.entitlement.status, 'trial');
  assert.equal(trialData.entitlement.plan, 'annual');
  assert.equal(trialData.entitlement.trial_eligible, false);
  assert.ok(trialData.entitlement.trial_ends_at_utc);

  // 3. Check-in during trial should work normally.
  const checkinRes = await fetch(`${baseUrl}/v1/checkins`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${token}`
    },
    body: JSON.stringify({
      user_id: userId,
      date_local: '2026-02-15',
      applied: true,
      timezone: 'America/Sao_Paulo'
    })
  });
  assert.ok(
    checkinRes.status === 200 || checkinRes.status === 201,
    'check-in during trial should succeed'
  );

  // 4. Trial should not be startable again (409 or 200 with existing state).
  const trialRetry = await fetch(`${baseUrl}/v1/subscription/trial/start`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${token}`
    },
    body: JSON.stringify({ plan: 'annual' })
  });
  // Should return 200 (already trial) — not create a new trial.
  assert.equal(trialRetry.status, 200);
  const retryData = await trialRetry.json();
  assert.equal(retryData.entitlement.status, 'trial');

  // 5. Activate subscription (simulates store purchase confirmation).
  const activateRes = await fetch(`${baseUrl}/v1/subscription/activate`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${token}`
    },
    body: JSON.stringify({ plan: 'annual' })
  });
  assert.equal(activateRes.status, 200);
  const activateData = await activateRes.json();
  assert.equal(activateData.entitlement.status, 'active');
  assert.equal(activateData.entitlement.plan, 'annual');
  assert.ok(activateData.entitlement.next_billing_at_utc);

  // 6. Log purchase token.
  const purchaseLogRes = await fetch(`${baseUrl}/v1/purchases/log`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${token}`
    },
    body: JSON.stringify({
      product_id: 'aethor_pro_annual',
      platform: 'ios',
      purchase_token: 'sandbox-receipt-001',
      transaction_id: 'txn-monetization-001'
    })
  });
  assert.equal(purchaseLogRes.status, 201);
  const logData = await purchaseLogRes.json();
  assert.equal(logData.logged, true);

  // 7. Restore (first call).
  const restore1 = await fetch(`${baseUrl}/v1/subscription/restore`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${token}`
    },
    body: JSON.stringify({ idempotency_key: 'monetization-restore-001' })
  });
  assert.equal(restore1.status, 200);
  const restore1Data = await restore1.json();
  assert.equal(restore1Data.restored, true);
  assert.equal(restore1Data.idempotent, false);

  // 8. Restore idempotent (same key).
  const restore2 = await fetch(`${baseUrl}/v1/subscription/restore`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${token}`
    },
    body: JSON.stringify({ idempotency_key: 'monetization-restore-001' })
  });
  assert.equal(restore2.status, 200);
  const restore2Data = await restore2.json();
  assert.equal(restore2Data.restored, true);
  assert.equal(restore2Data.idempotent, true);

  // 9. Daily-package should still work after all monetization operations.
  const dailyRes = await fetch(
    `${baseUrl}/v1/daily-package?timezone=America/Sao_Paulo&date_local=2026-02-15`
  );
  assert.equal(dailyRes.status, 200);
  const daily = await dailyRes.json();
  assert.ok(daily.quote?.id, 'daily-package should still return quote');
  assert.ok(daily.recommendation?.id, 'daily-package should still return recommendation');

  // 10. After activate, trial should return 409 (trial_already_used).
  // First we need a new user to test this scenario cleanly.
  const session2 = await createSession('monetization-device-002');
  const token2 = session2.access_token;

  // Start and use trial.
  await fetch(`${baseUrl}/v1/subscription/trial/start`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${token2}`
    },
    body: JSON.stringify({ plan: 'annual' })
  });

  // Activate (ends trial).
  await fetch(`${baseUrl}/v1/subscription/activate`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${token2}`
    },
    body: JSON.stringify({ plan: 'monthly' })
  });

  // Entitlement should show trial_used = true, trial_eligible = false.
  const ent2Res = await fetch(`${baseUrl}/v1/subscription/entitlement`, {
    headers: { authorization: `Bearer ${token2}` }
  });
  const ent2 = await ent2Res.json();
  assert.equal(ent2.status, 'active');
  assert.equal(ent2.trial_eligible, false);
});
