import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, readFileSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

let server;
let baseUrl;
let seed;

before(async () => {
  const dataDir = mkdtempSync(join(tmpdir(), 'aethor-ritual-'));
  const __dirname = dirname(fileURLToPath(import.meta.url));
  const seedSourcePath = join(__dirname, '../data/daily_seed.json');
  seed = JSON.parse(readFileSync(seedSourcePath, 'utf-8'));
  writeFileSync(join(dataDir, 'daily_seed.json'), JSON.stringify(seed, null, 2));

  process.env.STOIC_DATA_DIR = dataDir;
  process.env.STOIC_DB_PATH = join(dataDir, 'aethor.db');
  process.env.STOIC_OBSERVABILITY_TOKEN = 'ritual-test-token';
  process.env.FCM_DRY_RUN = 'true';

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

function dateOffset(base, daysOffset) {
  const date = new Date(`${base}T00:00:00Z`);
  date.setUTCDate(date.getUTCDate() + daysOffset);
  return date.toISOString().slice(0, 10);
}

test('Ritual de 7 dias: push → deeplink → daily-package → check-in → favorito → analytics', async () => {
  const session = await createSession('ritual-device-001');
  const userId = session.user_id;
  const token = session.access_token;
  const timezone = 'America/Sao_Paulo';
  const startDate = '2026-02-09';

  // 0. Register FCM token for push notifications.
  const tokenRes = await fetch(`${baseUrl}/v1/push-tokens`, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      authorization: `Bearer ${token}`
    },
    body: JSON.stringify({ fcm_token: 'ritual-test-fcm-token', platform: 'android' })
  });
  assert.equal(tokenRes.status, 200, 'FCM token registration failed');

  const dailyDates = new Set();
  const checkinDates = [];
  const pushSentDays = [];

  for (let day = 0; day < 7; day++) {
    const dateLocal = dateOffset(startDate, day);

    // 1. Simulate push/send for this day (dry-run mode).
    const pushRes = await fetch(`${baseUrl}/v1/push/send`, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        'x-observability-token': 'ritual-test-token'
      },
      body: JSON.stringify({
        user_id: userId,
        title: 'Seu insight do dia',
        body: `Dia ${day + 1} do ritual`,
        data: {
          deeplink: `aethor://today?date_local=${dateLocal}&focus=checkin`,
          route: 'today',
          date_local: dateLocal,
          version: '1'
        }
      })
    });
    assert.equal(pushRes.status, 200, `push/send failed for day ${day}`);
    const pushData = await pushRes.json();
    assert.ok(pushData.dry_run === true || pushData.sent >= 0, `push response invalid for day ${day}`);
    pushSentDays.push(dateLocal);

    // 2. Track push_opened event (simulating user tapping the notification).
    const pushOpenedRes = await fetch(`${baseUrl}/v1/analytics/events`, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        authorization: `Bearer ${token}`
      },
      body: JSON.stringify({
        event_name: 'push_opened',
        properties: {
          event_version: 1,
          date_local: dateLocal,
          deeplink: `aethor://today?date_local=${dateLocal}&focus=checkin`,
          source: 'push_opened_background'
        }
      })
    });
    assert.equal(pushOpenedRes.status, 201, `push_opened event failed for day ${day}`);

    // 3. Fetch daily-package — must return a valid pair.
    const dailyRes = await fetch(
      `${baseUrl}/v1/daily-package?timezone=${timezone}&date_local=${dateLocal}`
    );
    assert.equal(dailyRes.status, 200, `daily-package failed for day ${day}`);
    const daily = await dailyRes.json();
    assert.equal(daily.date_local, dateLocal);
    assert.ok(daily.quote?.id, `missing quote for day ${day}`);
    assert.ok(daily.recommendation?.id, `missing recommendation for day ${day}`);

    // Track uniqueness — each date should produce a package (not necessarily unique quote).
    dailyDates.add(dateLocal);

    // 4. Submit a check-in.
    const checkinRes = await fetch(`${baseUrl}/v1/checkins`, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        authorization: `Bearer ${token}`
      },
      body: JSON.stringify({
        user_id: userId,
        date_local: dateLocal,
        applied: day % 2 === 0,
        timezone
      })
    });
    assert.ok(
      checkinRes.status === 200 || checkinRes.status === 201,
      `check-in failed for day ${day}`
    );
    checkinDates.push(dateLocal);

    // 5. Favorite first quote of first day.
    if (day === 0) {
      const favRes = await fetch(`${baseUrl}/v1/favorites`, {
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          authorization: `Bearer ${token}`
        },
        body: JSON.stringify({
          user_id: userId,
          quote_id: daily.quote.id
        })
      });
      assert.ok(
        favRes.status === 200 || favRes.status === 201,
        'favorite failed'
      );
    }

    // 6. Track daily_ritual_completed event.
    const analyticsRes = await fetch(`${baseUrl}/v1/analytics/events`, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        authorization: `Bearer ${token}`
      },
      body: JSON.stringify({
        event_name: 'daily_ritual_completed',
        properties: {
          event_version: 1,
          date_local: dateLocal,
          day_number: day + 1
        }
      })
    });
    assert.equal(analyticsRes.status, 201, `analytics event failed for day ${day}`);
  }

  // Validate: 7 unique dates, no duplicates.
  assert.equal(dailyDates.size, 7, 'should have 7 unique daily dates');
  assert.equal(checkinDates.length, 7, 'should have 7 check-ins');
  assert.equal(pushSentDays.length, 7, 'should have 7 push send days');

  // Validate: history returns all 7 days.
  const historyRes = await fetch(
    `${baseUrl}/v1/history?timezone=${timezone}&date_local=${dateOffset(startDate, 6)}&days=7`
  );
  assert.equal(historyRes.status, 200);
  const history = await historyRes.json();
  assert.equal(history.items.length, 7, 'history should have 7 items');

  // Validate: favorites persisted.
  const favListRes = await fetch(`${baseUrl}/v1/favorites?user_id=${userId}`, {
    headers: { authorization: `Bearer ${token}` }
  });
  assert.equal(favListRes.status, 200);
  const favData = await favListRes.json();
  assert.equal(favData.items.length, 1, 'should have 1 favorite');

  // Validate: metrics reflect the activity.
  const metricsRes = await fetch(`${baseUrl}/v1/observability/metrics`, {
    headers: { 'x-observability-token': 'ritual-test-token' }
  });
  assert.equal(metricsRes.status, 200);
  const metrics = await metricsRes.json();
  assert.ok(metrics.tables.checkins >= 7, 'should have >= 7 checkins');
  assert.ok(metrics.tables.favorites >= 1, 'should have >= 1 favorite');
  assert.ok(metrics.tables.analytics_events >= 14, 'should have >= 14 analytics events (7 push_opened + 7 ritual_completed)');
  assert.ok(metrics.tables.push_tokens >= 1, 'should have >= 1 push token');
  assert.ok(metrics.push.active_tokens >= 1, 'should have >= 1 active push token');
});
