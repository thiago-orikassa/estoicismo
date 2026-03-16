/**
 * Railway production startup script.
 *
 * Provisions the database (migrations + seed) on first run,
 * then starts the HTTP server.
 *
 * Environment variables set by Railway:
 *   PORT — HTTP port (required)
 *
 * Additional env vars to configure in Railway dashboard:
 *   HOST=0.0.0.0
 *   STOIC_RUNTIME_ENV=production
 *   JWT_SECRET=<random secret>
 */

import { copyFileSync, existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawn } from 'node:child_process';

const __dirname = dirname(fileURLToPath(import.meta.url));
const backendRoot = resolve(__dirname, '..');

// Data directory: use STOIC_DATA_DIR env var, or default to ./data inside the app
const dataDir = process.env.STOIC_DATA_DIR ?? join(backendRoot, 'data');
const dbPath = process.env.STOIC_DB_PATH ?? join(dataDir, 'aethor.db');
const seedSourcePath = join(backendRoot, 'data', 'daily_seed.json');
const seedPath = process.env.STOIC_SEED_PATH ?? join(dataDir, 'daily_seed.json');

// Ensure data directory exists
mkdirSync(dataDir, { recursive: true });

// Always copy seed from deployment — ensures the volume has the latest translations/content
if (existsSync(seedSourcePath)) {
  copyFileSync(seedSourcePath, seedPath);
  console.log(`[startup] seed updated at ${seedPath}`);
}

// Initialize empty JSON files if missing
for (const filename of ['analytics_events.json', 'checkins.json', 'favorites.json', 'scheduled_packages.json']) {
  const filePath = join(dataDir, filename);
  if (!existsSync(filePath)) {
    writeFileSync(filePath, '[]\n');
  }
}

// Set env vars for server
process.env.STOIC_DATA_DIR = dataDir;
process.env.STOIC_DB_PATH = dbPath;
process.env.STOIC_SEED_PATH = seedPath;
process.env.HOST = process.env.HOST ?? '0.0.0.0';
process.env.STOIC_RUNTIME_ENV = process.env.STOIC_RUNTIME_ENV ?? 'production';

// Run migrations by importing db module
console.log('[startup] running migrations...');
const { db } = await import('../src/db.mjs');
const migrations = db.prepare('select id from schema_migrations order by id asc').all();
console.log(`[startup] migrations applied: ${migrations.map(m => m.id).join(', ')}`);
db.close();

console.log(`[startup] starting server on ${process.env.HOST}:${process.env.PORT ?? 8787}`);

// Start the server as a child process
const server = spawn(process.execPath, ['--experimental-sqlite', join(backendRoot, 'src', 'server.mjs')], {
  env: process.env,
  stdio: 'inherit',
});

server.on('exit', (code) => process.exit(code ?? 0));
