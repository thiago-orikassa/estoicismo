import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, readFileSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

let server;
let baseUrl;
let seed;
let testUserId;
let authToken;

before(async () => {
  const dataDir = mkdtempSync(join(tmpdir(), 'estoicismo-test-'));
  const __dirname = dirname(fileURLToPath(import.meta.url));
  const seedSourcePath = join(__dirname, '../data/daily_seed.json');
  seed = JSON.parse(readFileSync(seedSourcePath, 'utf-8'));
  writeFileSync(join(dataDir, 'daily_seed.json'), JSON.stringify(seed, null, 2));

  process.env.STOIC_DATA_DIR = dataDir;
  process.env.STOIC_DB_PATH = join(dataDir, 'estoicismo.db');

  const mod = await import('../src/server.mjs');
  server = mod.server;
  server.listen(0, '127.0.0.1');
  await new Promise((resolve) => server.on('listening', resolve));
  const { port } = server.address();
  baseUrl = `http://127.0.0.1:${port}`;

  const sessionRes = await fetch(`${baseUrl}/v1/session`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ device_id: 'test-device-001' })
  });
  const sessionData = await sessionRes.json();
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
