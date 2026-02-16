#!/usr/bin/env node
/**
 * validate-seed.mjs
 * Valida que o daily_seed.json contém todos os campos obrigatórios.
 * Deve rodar antes de qualquer deploy ou start.
 *
 * Uso: node scripts/validate-seed.mjs
 * Exit code 0 = ok, 1 = campos faltantes
 */

import { readFileSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const seedPath = process.env.STOIC_SEED_PATH ?? join(__dirname, '../data/daily_seed.json');

const REQUIRED_QUOTE_FIELDS = [
  'id', 'author', 'text', 'source_work', 'source_ref',
  'language', 'theme_primary', 'behavior_intent', 'context_tags',
  'authenticity_level',
];

const REQUIRED_RECOMMENDATION_FIELDS = [
  'id', 'quote_id', 'context', 'action_title', 'action_steps',
  'estimated_minutes', 'journal_prompt',
  'quote_link_explanation', 'expected_outcome', 'completion_criteria',
];

let exitCode = 0;

try {
  const seed = JSON.parse(readFileSync(seedPath, 'utf-8'));

  if (!Array.isArray(seed.quotes) || seed.quotes.length === 0) {
    console.error('✗ seed.quotes está vazio ou ausente');
    process.exit(1);
  }

  if (!Array.isArray(seed.recommendations) || seed.recommendations.length === 0) {
    console.error('✗ seed.recommendations está vazio ou ausente');
    process.exit(1);
  }

  const quoteIds = new Set(seed.quotes.map(q => q.id));

  for (const quote of seed.quotes) {
    for (const field of REQUIRED_QUOTE_FIELDS) {
      const val = quote[field];
      if (val === undefined || val === null || (typeof val === 'string' && val.trim() === '')) {
        console.error(`✗ Quote "${quote.id}": campo obrigatório "${field}" ausente ou vazio`);
        exitCode = 1;
      }
    }
  }

  for (const rec of seed.recommendations) {
    for (const field of REQUIRED_RECOMMENDATION_FIELDS) {
      const val = rec[field];
      if (val === undefined || val === null || (typeof val === 'string' && val.trim() === '')) {
        console.error(`✗ Recommendation "${rec.id}": campo obrigatório "${field}" ausente ou vazio`);
        exitCode = 1;
      }
    }

    if (rec.quote_id && !quoteIds.has(rec.quote_id)) {
      console.error(`✗ Recommendation "${rec.id}": quote_id "${rec.quote_id}" não existe em quotes`);
      exitCode = 1;
    }

    if (Array.isArray(rec.action_steps) && rec.action_steps.length === 0) {
      console.error(`✗ Recommendation "${rec.id}": action_steps está vazio`);
      exitCode = 1;
    }
  }

  if (exitCode === 0) {
    console.log(`✓ Seed válido: ${seed.quotes.length} quotes, ${seed.recommendations.length} recomendações`);
  }
} catch (err) {
  console.error(`✗ Erro ao ler/parsear seed: ${err.message}`);
  exitCode = 1;
}

process.exit(exitCode);
