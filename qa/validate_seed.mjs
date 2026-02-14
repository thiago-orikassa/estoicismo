import { readFileSync } from 'node:fs';
import { join } from 'node:path';

const seedPath = join(process.cwd(), 'backend', 'data', 'daily_seed.json');
const seed = JSON.parse(readFileSync(seedPath, 'utf-8'));

const allowedAuthenticity = new Set(['verified', 'probable']);
const allowedContexts = new Set([
  'trabalho',
  'relacionamentos',
  'ansiedade',
  'foco',
  'decisao_dificil'
]);

const errors = [];

function fail(message) {
  errors.push(message);
}

function isBlank(value) {
  return value === null || value === undefined || String(value).trim().length === 0;
}

if (!Array.isArray(seed.quotes) || seed.quotes.length === 0) {
  fail('quotes: seed sem itens.');
}

if (!Array.isArray(seed.recommendations) || seed.recommendations.length === 0) {
  fail('recommendations: seed sem itens.');
}

const quoteIds = new Set();
for (const quote of seed.quotes ?? []) {
  if (isBlank(quote.id)) fail('quote: id ausente.');
  if (isBlank(quote.author)) fail(`quote ${quote.id}: author ausente.`);
  if (isBlank(quote.text)) fail(`quote ${quote.id}: text ausente.`);
  if (isBlank(quote.source_work)) fail(`quote ${quote.id}: source_work ausente.`);
  if (isBlank(quote.source_ref)) fail(`quote ${quote.id}: source_ref ausente.`);
  if (!allowedAuthenticity.has(quote.authenticity_level)) {
    fail(`quote ${quote.id}: authenticity_level invalido (${quote.authenticity_level}).`);
  }
  if (!Array.isArray(quote.context_tags)) {
    fail(`quote ${quote.id}: context_tags invalido.`);
  }
  quoteIds.add(quote.id);
}

for (const rec of seed.recommendations ?? []) {
  if (isBlank(rec.id)) fail('recommendation: id ausente.');
  if (isBlank(rec.quote_id)) fail(`recommendation ${rec.id}: quote_id ausente.`);
  if (!quoteIds.has(rec.quote_id)) {
    fail(`recommendation ${rec.id}: quote_id nao existe (${rec.quote_id}).`);
  }
  if (!allowedContexts.has(rec.context)) {
    fail(`recommendation ${rec.id}: context invalido (${rec.context}).`);
  }
  if (isBlank(rec.action_title)) {
    fail(`recommendation ${rec.id}: action_title ausente.`);
  }
  if (!Array.isArray(rec.action_steps) || rec.action_steps.length === 0) {
    fail(`recommendation ${rec.id}: action_steps vazio.`);
  }
  if (typeof rec.estimated_minutes !== 'number' || rec.estimated_minutes < 1 || rec.estimated_minutes > 30) {
    fail(`recommendation ${rec.id}: estimated_minutes fora do intervalo.`);
  }
  if (isBlank(rec.journal_prompt)) {
    fail(`recommendation ${rec.id}: journal_prompt ausente.`);
  }
}

if (errors.length > 0) {
  // eslint-disable-next-line no-console
  console.error('Erros de validacao de seed:');
  for (const error of errors) {
    // eslint-disable-next-line no-console
    console.error(`- ${error}`);
  }
  process.exit(1);
}

// eslint-disable-next-line no-console
console.log('Seed validada com sucesso.');
