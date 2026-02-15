import { copyFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const backendRoot = resolve(__dirname, '..');

const profile = process.argv[2] ?? 'dev';
if (!['dev', 'stage'].includes(profile)) {
  // eslint-disable-next-line no-console
  console.error('usage: node scripts/provision.mjs <dev|stage>');
  process.exit(1);
}

const runtimeRoot = resolve(backendRoot, '.runtime', profile);
const dataDir = join(runtimeRoot, 'data');
const dbPath = join(dataDir, 'estoicismo.db');
const seedPath = join(dataDir, 'daily_seed.json');
const sourceSeedPath = process.env.STOIC_SEED_SOURCE_PATH ?? join(backendRoot, 'data', 'daily_seed.json');

mkdirSync(dataDir, { recursive: true });

if (!existsSync(sourceSeedPath)) {
  // eslint-disable-next-line no-console
  console.error(`seed source not found: ${sourceSeedPath}`);
  process.exit(1);
}

if (!existsSync(seedPath)) {
  copyFileSync(sourceSeedPath, seedPath);
}

for (const filename of ['analytics_events.json', 'checkins.json', 'favorites.json', 'scheduled_packages.json']) {
  const filePath = join(dataDir, filename);
  if (!existsSync(filePath)) {
    writeFileSync(filePath, '[]\n');
  }
}

process.env.STOIC_RUNTIME_ENV = profile;
process.env.STOIC_DATA_DIR = dataDir;
process.env.STOIC_DB_PATH = dbPath;
process.env.STOIC_SEED_PATH = seedPath;

const { db } = await import('../src/db.mjs');
const migrations = db
  .prepare('select id, applied_at_utc from schema_migrations order by id asc')
  .all();

const seed = JSON.parse(readFileSync(seedPath, 'utf-8'));
const quoteCount = Array.isArray(seed.quotes) ? seed.quotes.length : 0;
const recommendationCount = Array.isArray(seed.recommendations) ? seed.recommendations.length : 0;

db.close();

const report = {
  profile,
  runtime_root: runtimeRoot,
  data_dir: dataDir,
  db_path: dbPath,
  seed_path: seedPath,
  seed_quote_count: quoteCount,
  seed_recommendation_count: recommendationCount,
  migrations_applied: migrations.map((item) => item.id),
  migrated_at_utc: new Date().toISOString()
};

const reportPath = join(runtimeRoot, 'provision-report.json');
writeFileSync(reportPath, `${JSON.stringify(report, null, 2)}\n`);

// eslint-disable-next-line no-console
console.log(JSON.stringify(report, null, 2));
