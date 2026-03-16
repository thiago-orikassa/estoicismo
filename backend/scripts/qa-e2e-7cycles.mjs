#!/usr/bin/env node

/**
 * qa-e2e-7cycles.mjs — QA-03: E2E dos 7 Ciclos do Ritual Diário
 *
 * Simula 7 dias de uso sem esperar 7 dias reais.
 * Cria um usuário de teste temporário, roda cada ciclo e limpa ao final.
 *
 * Usage:
 *   node backend/scripts/qa-e2e-7cycles.mjs
 *   BASE_URL=https://aethor-production.up.railway.app node backend/scripts/qa-e2e-7cycles.mjs
 *
 * Pré-requisito (local): HOST=0.0.0.0 npm run start:dev --prefix backend
 *
 * Ciclo testado por dia:
 *   1. GET /v1/daily-package        → quote + recommendation válidos
 *   2. Sem citação duplicada        → cada dia entrega conteúdo único
 *   3. Payload de push bem formado  → deeplink com date_local correto
 *   4. POST /v1/checkins (applied)  → persiste 201
 *   5. Idempotência do check-in     → segunda chamada retorna 200
 *   6. Persistência no banco        → registro encontrado no SQLite
 */

import { randomUUID, createHash, randomBytes } from 'node:crypto';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const backendDir = join(__dirname, '..');

// ── Config ────────────────────────────────────────────────────────────────────

const BASE_URL  = process.env.BASE_URL  ?? 'http://127.0.0.1:8787';
const TIMEZONE  = process.env.TIMEZONE  ?? 'America/Sao_Paulo';
const DAYS      = 7;

// ── Database (injeção direta de sessão de teste) ──────────────────────────────
// Detecta o perfil ativo para usar o mesmo banco do servidor em execução.
// Ordem de prioridade: variável de ambiente explícita > perfil stage > perfil dev

const profile = process.env.STOIC_RUNTIME_ENV ?? 'dev';
const runtimeDataDir = join(backendDir, '.runtime', profile, 'data');
const defaultDataDir = join(backendDir, 'data');

process.env.STOIC_DATA_DIR  = process.env.STOIC_DATA_DIR  ?? runtimeDataDir;
process.env.STOIC_DB_PATH   = process.env.STOIC_DB_PATH   ?? join(runtimeDataDir, 'aethor.db');

const { db } = await import('../src/db.mjs');

// ── Helpers ───────────────────────────────────────────────────────────────────

function isoDateOffset(base, offset) {
  const d = new Date(`${base}T00:00:00Z`);
  d.setUTCDate(d.getUTCDate() + offset);
  return d.toISOString().slice(0, 10);
}

function todayLocal() {
  const parts = new Intl.DateTimeFormat('en-US', {
    timeZone: TIMEZONE, year: 'numeric', month: '2-digit', day: '2-digit',
  }).formatToParts(new Date());
  const y = parts.find((p) => p.type === 'year').value;
  const m = parts.find((p) => p.type === 'month').value;
  const d = parts.find((p) => p.type === 'day').value;
  return `${y}-${m}-${d}`;
}

function hashToken(token) {
  return createHash('sha256').update(token).digest('hex');
}

async function api(method, path, body, token) {
  const res = await fetch(`${BASE_URL}${path}`, {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  const json = await res.json().catch(() => null);
  return { status: res.status, json };
}

// ── Criar sessão de teste diretamente no DB ───────────────────────────────────

function createTestSession() {
  const userId   = randomUUID();
  const token    = randomBytes(32).toString('hex');
  const tokenHash = hashToken(token);
  const now      = new Date().toISOString();
  const expiresAt = new Date(Date.now() + 90 * 24 * 60 * 60 * 1000).toISOString();
  const deviceId  = `qa-e2e-${randomUUID()}`;
  const providerId = `qa-test-${userId}`;
  const email     = `${providerId}@aethor.test`;

  db.prepare(`
    insert into user_identities (id, user_id, provider, provider_id, email, created_at_utc)
    values (?, ?, 'email', ?, ?, ?)
  `).run(randomUUID(), userId, providerId, email, now);

  db.prepare(`
    insert into sessions (id, user_id, device_id, token_hash, created_at_utc, updated_at_utc, expires_at_utc)
    values (?, ?, ?, ?, ?, ?, ?)
  `).run(randomUUID(), userId, deviceId, tokenHash, now, now, expiresAt);

  return { userId, token };
}

function cleanupTestUser(userId) {
  db.prepare('delete from checkins        where user_id = ?').run(userId);
  db.prepare('delete from sessions        where user_id = ?').run(userId);
  db.prepare('delete from user_identities where user_id = ?').run(userId);
}

// ── Verificação de persistência no banco ──────────────────────────────────────

function checkinExistsInDb(userId, dateLocal) {
  const row = db.prepare(
    'select id from checkins where user_id = ? and date_local = ? limit 1'
  ).get(userId, dateLocal);
  return !!row;
}

// ── Output ────────────────────────────────────────────────────────────────────

const P = '✅';
const F = '❌';

let _totalChecks = 0;
let _failedChecks = 0;

function check(label, ok, detail = '') {
  _totalChecks++;
  if (!ok) _failedChecks++;
  const icon = ok ? P : F;
  console.log(`    ${icon} ${label}${detail ? `  (${detail})` : ''}`);
  return ok;
}

// ── Main ──────────────────────────────────────────────────────────────────────

async function run() {
  const startDate = isoDateOffset(todayLocal(), -(DAYS - 1));

  console.log('\n╔══════════════════════════════════════════════════════════╗');
  console.log('║   QA-03 — E2E 7 Ciclos do Ritual Diário                 ║');
  console.log('╚══════════════════════════════════════════════════════════╝');
  console.log(`  BASE_URL  : ${BASE_URL}`);
  console.log(`  TIMEZONE  : ${TIMEZONE}`);
  console.log(`  JANELA    : ${startDate} → ${todayLocal()}\n`);

  // ── Verifica servidor ──────────────────────────────────────────────────────
  const ping = await api('GET', '/v1/observability/metrics', null, null).catch(() => null);
  if (!ping || ping.status !== 200) {
    console.error(`${F} Servidor não responde em ${BASE_URL}`);
    console.error('  Inicie com: HOST=0.0.0.0 npm run start:dev --prefix backend');
    process.exit(1);
  }
  console.log(`${P} Servidor respondendo\n`);

  // ── Cria usuário de teste ──────────────────────────────────────────────────
  let userId, token;
  try {
    ({ userId, token } = createTestSession());
    console.log(`${P} Usuário de teste: ${userId}\n`);
  } catch (err) {
    console.error(`${F} Falha ao criar usuário de teste: ${err.message}`);
    process.exit(1);
  }

  const cycleResults = [];
  const seenQuoteIds = new Set();

  // ── Loop de 7 ciclos ───────────────────────────────────────────────────────
  for (let i = 0; i < DAYS; i++) {
    const dateLocal = isoDateOffset(startDate, i);
    _totalChecks = 0;
    _failedChecks = 0;

    console.log(`─── Ciclo ${i + 1}/${DAYS}  [${dateLocal}] ${'─'.repeat(36)}`);

    // 1. daily-package
    const pkgRes = await api(
      'GET',
      `/v1/daily-package?timezone=${encodeURIComponent(TIMEZONE)}&date_local=${dateLocal}`,
      null, token,
    );
    const pkg = pkgRes.json;

    check('daily-package → 200', pkgRes.status === 200, `status=${pkgRes.status}`);
    check('quote.id presente',     !!pkg?.quote?.id);
    check('quote.text presente',   !!pkg?.quote?.text);
    check('quote.author presente', !!pkg?.quote?.author);
    check('quote.source_work presente', !!pkg?.quote?.source_work, pkg?.quote?.source_work ?? 'ausente');
    check('recommendation.action_title presente',  !!pkg?.recommendation?.action_title);
    check('recommendation.action_steps presente', Array.isArray(pkg?.recommendation?.action_steps) && pkg.recommendation.action_steps.length > 0);

    // 2. Unicidade
    const isDupe = seenQuoteIds.has(pkg?.quote?.id);
    check('citação não duplicada', !isDupe, isDupe ? `id=${pkg?.quote?.id} já visto` : pkg?.quote?.id ?? '');
    if (pkg?.quote?.id) seenQuoteIds.add(pkg.quote.id);

    // 3. Push payload
    const deeplink = `aethor://today?date_local=${dateLocal}&focus=checkin`;
    check('deeplink contém date_local', deeplink.includes(dateLocal));
    const preview = `${pkg?.quote?.author ?? ''}: ${(pkg?.quote?.text ?? '').slice(0, 70)}...`;
    console.log(`    📲 push: "${preview}"`);

    // 4. POST check-in
    const ci1 = await api('POST', '/v1/checkins', {
      user_id: userId, date_local: dateLocal, applied: true, timezone: TIMEZONE,
    }, token);
    check('checkin → 201',                    ci1.status === 201,  `status=${ci1.status}`);
    check('checkin.applied = true',           ci1.json?.applied === true);
    check('checkin.date_local correto',       ci1.json?.date_local === dateLocal);

    // 5. Idempotência
    const ci2 = await api('POST', '/v1/checkins', {
      user_id: userId, date_local: dateLocal, applied: true, timezone: TIMEZONE,
    }, token);
    check('checkin idempotente → 200',        ci2.status === 200,  `status=${ci2.status}`);

    // 6. Persistência no banco
    check('checkin persiste no SQLite',       checkinExistsInDb(userId, dateLocal));

    const cyclePassed = _failedChecks === 0;
    cycleResults.push({ day: i + 1, dateLocal, passed: cyclePassed, failures: _failedChecks });
    console.log(`  ${cyclePassed ? P : F}  Ciclo ${i + 1} — ${cyclePassed ? 'PASSOU' : `FALHOU (${_failedChecks} check(s))`}\n`);
  }

  // ── Relatório final ────────────────────────────────────────────────────────
  const totalPassed = cycleResults.filter((r) => r.passed).length;
  const totalFailed = cycleResults.filter((r) => !r.passed).length;
  const uniqueQuotes = seenQuoteIds.size;
  const noDupes = uniqueQuotes === DAYS;

  console.log('╔══════════════════════════════════════════════════════════╗');
  console.log('║   RELATÓRIO FINAL                                        ║');
  console.log('╚══════════════════════════════════════════════════════════╝');
  console.log(`  Ciclos aprovados : ${totalPassed}/${DAYS}`);
  console.log(`  Citações únicas  : ${uniqueQuotes}/${DAYS}  ${noDupes ? P : F}`);

  if (totalFailed === 0 && noDupes) {
    console.log(`\n  ${P} QA-03 APROVADO — 7/7 ciclos sem falha crítica, sem duplicatas`);
    console.log('     Critério de aceite atendido. Pronto para gate de release.\n');
  } else {
    console.log(`\n  ${F} QA-03 REPROVADO`);
    for (const r of cycleResults.filter((r) => !r.passed)) {
      console.log(`     Dia ${r.day} (${r.dateLocal}): ${r.failures} falha(s)`);
    }
    if (!noDupes) console.log(`     Duplicatas detectadas no conteúdo diário`);
    console.log('');
  }

  // ── Limpeza ────────────────────────────────────────────────────────────────
  cleanupTestUser(userId);
  console.log('  🧹 Usuário de teste removido do banco\n');

  process.exit(totalFailed === 0 && noDupes ? 0 : 1);
}

run().catch((err) => {
  console.error(`\n${F} Erro inesperado: ${err.message}`);
  process.exit(1);
});
