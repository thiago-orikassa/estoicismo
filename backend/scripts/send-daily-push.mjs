#!/usr/bin/env node

/**
 * Send Daily Push — Envia push de lembrete diário para todos os tokens ativos.
 *
 * Usage:
 *   node backend/scripts/send-daily-push.mjs "America/Sao_Paulo"
 *
 * Lógica:
 *   1. Carrega conteúdo agendado (scheduled_packages.json) ou gera on-the-fly.
 *   2. Para cada token ativo, envia push via FCM com deep link para /today.
 *   3. Loga relatório de entrega.
 *
 * Para o MVP: envio fixo por timezone (07:30 America/Sao_Paulo).
 * Preferência de horário por usuário fica para pós-MVP.
 */

import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { readFileSync } from 'node:fs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const backendDir = join(__dirname, '..');

// Set up environment so db.mjs finds the right data.
const defaultDataDir = join(backendDir, 'data');
process.env.STOIC_DATA_DIR = process.env.STOIC_DATA_DIR ?? defaultDataDir;
process.env.STOIC_DB_PATH = process.env.STOIC_DB_PATH ?? join(defaultDataDir, 'aethor.db');

const { db } = await import('../src/db.mjs');
const { sendPushNotification, FCM_DRY_RUN, PUSH_ENABLED } = await import('../src/fcm.mjs');
const { logger } = await import('../src/logger.mjs');

const timezone = process.argv[2] ?? 'America/Sao_Paulo';
const seedPath = process.env.STOIC_SEED_PATH ?? join(defaultDataDir, 'daily_seed.json');
const seed = JSON.parse(readFileSync(seedPath, 'utf-8'));

function localDateFromTimezone(tz) {
  try {
    const parts = new Intl.DateTimeFormat('en-US', {
      timeZone: tz,
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
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

function stableHash(input) {
  let hash = 0;
  for (let i = 0; i < input.length; i += 1) hash = (hash * 31 + input.charCodeAt(i)) >>> 0;
  return hash;
}

function pickDailyQuotePreview(dateLocal) {
  const hash = stableHash(`${dateLocal}:${timezone}:`);
  const quote = seed.quotes[hash % seed.quotes.length];
  return quote;
}

async function main() {
  const dateLocal = localDateFromTimezone(timezone);
  if (!dateLocal) {
    console.error(`Invalid timezone: ${timezone}`);
    process.exit(1);
  }

  logger.info('send_daily_push_start', { timezone, dateLocal, dry_run: FCM_DRY_RUN, push_enabled: PUSH_ENABLED });

  const quote = pickDailyQuotePreview(dateLocal);
  const title = 'Seu insight do dia';
  const body = `${quote.author}: ${quote.text.slice(0, 80)}${quote.text.length > 80 ? '...' : ''}`;
  const data = {
    deeplink: `aethor://today?date_local=${dateLocal}&focus=checkin`,
    route: 'today',
    date_local: dateLocal,
    version: '1',
  };

  const selectActiveTokens = db.prepare(`
    select fcm_token, platform, user_id
    from push_tokens
    where active = 1
  `);

  const deactivateToken = db.prepare(`
    update push_tokens
    set active = 0, updated_at_utc = ?
    where fcm_token = ?
  `);

  const markDelivery = db.prepare(`
    update push_tokens
    set last_delivery_at_utc = ?, failure_count = 0, updated_at_utc = ?
    where fcm_token = ?
  `);

  const tokens = selectActiveTokens.all();
  let sent = 0;
  let failed = 0;
  let invalidRemoved = 0;

  for (const row of tokens) {
    const result = await sendPushNotification({
      fcmToken: row.fcm_token,
      title,
      body,
      data,
    });

    const now = new Date().toISOString();
    if (result.success) {
      sent += 1;
      markDelivery.run(now, now, row.fcm_token);
    } else {
      failed += 1;
      if (result.unregistered) {
        deactivateToken.run(now, row.fcm_token);
        invalidRemoved += 1;
      }
    }
  }

  const report = {
    timezone,
    date_local: dateLocal,
    total_tokens: tokens.length,
    sent,
    failed,
    invalid_tokens_removed: invalidRemoved,
    dry_run: FCM_DRY_RUN || !PUSH_ENABLED,
    quote_preview: `${quote.author}: ${quote.text.slice(0, 60)}...`,
  };

  logger.info('send_daily_push_complete', report);
  console.log(JSON.stringify(report, null, 2));
}

main().catch((err) => {
  console.error('send-daily-push failed:', err.message);
  process.exit(1);
});
