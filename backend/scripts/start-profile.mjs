import { spawn } from 'node:child_process';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const backendRoot = resolve(__dirname, '..');

const profile = process.argv[2] ?? 'dev';
if (!['dev', 'stage'].includes(profile)) {
  // eslint-disable-next-line no-console
  console.error('usage: node scripts/start-profile.mjs <dev|stage>');
  process.exit(1);
}

const runtimeRoot = resolve(backendRoot, '.runtime', profile);
const dataDir = join(runtimeRoot, 'data');

const env = {
  ...process.env,
  STOIC_RUNTIME_ENV: profile,
  STOIC_DATA_DIR: dataDir,
  STOIC_DB_PATH: join(dataDir, 'aethor.db'),
  STOIC_SEED_PATH: join(dataDir, 'daily_seed.json'),
  HOST: profile === 'stage' ? process.env.HOST ?? '0.0.0.0' : process.env.HOST ?? '127.0.0.1',
  PORT: process.env.PORT ?? (profile === 'stage' ? '8788' : '8787')
};

const child = spawn(process.execPath, ['src/server.mjs'], {
  cwd: backendRoot,
  env,
  stdio: 'inherit'
});

child.on('exit', (code) => {
  process.exit(code ?? 0);
});
