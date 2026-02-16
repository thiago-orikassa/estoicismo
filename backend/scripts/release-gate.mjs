#!/usr/bin/env node

/**
 * Release Gate — QA-04
 *
 * Runs backend tests, Flutter tests/analysis, checks Firebase configs,
 * validates seed data, and prints a GO/NO-GO verdict.
 *
 * Usage:
 *   node backend/scripts/release-gate.mjs
 *
 * Exit codes:
 *   0 — GO (all checks passed)
 *   1 — NO-GO (one or more checks failed)
 */

import { execSync } from 'node:child_process';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const backendDir = join(__dirname, '..');
const projectRoot = join(backendDir, '..');
const appDir = join(projectRoot, 'app');
const qaDir = join(projectRoot, 'qa');

const checks = [];

function runCheck(name, fn) {
  try {
    fn();
    checks.push({ name, status: 'PASS' });
    console.log(`  [PASS] ${name}`);
  } catch (err) {
    checks.push({ name, status: 'FAIL', error: err.message });
    console.error(`  [FAIL] ${name}: ${err.message}`);
  }
}

function await_import_fs() {
  return require_fs();
}

function require_fs() {
  return {
    readdirSync: (dir) => {
      const result = execSync(`ls "${dir}"`, { encoding: 'utf-8' });
      return result.trim().split('\n').filter(Boolean);
    },
    existsSync: (path) => {
      try {
        execSync(`test -f "${path}"`, { stdio: 'pipe' });
        return true;
      } catch {
        return false;
      }
    }
  };
}

console.log('=== Release Gate ===\n');

// 1. Backend tests.
runCheck('Backend tests (npm test)', () => {
  execSync('npm test', {
    cwd: backendDir,
    stdio: 'pipe',
    timeout: 120_000
  });
});

// 2. Check that migrations are ordered.
runCheck('Migrations order', () => {
  const { readdirSync } = await_import_fs();
  const migrationsDir = join(backendDir, 'migrations');
  const files = readdirSync(migrationsDir)
    .filter((f) => f.endsWith('.sql'))
    .sort();
  if (files.length === 0) {
    throw new Error('No migration files found');
  }
  for (const file of files) {
    if (!/^\d{3}_\w+\.sql$/.test(file)) {
      throw new Error(`Migration file does not match pattern: ${file}`);
    }
  }
});

// 3. Check required backend files exist.
runCheck('Required backend files exist', () => {
  const { existsSync } = await_import_fs();
  const requiredFiles = [
    join(backendDir, 'src/server.mjs'),
    join(backendDir, 'src/db.mjs'),
    join(backendDir, 'src/fcm.mjs'),
    join(backendDir, 'data/daily_seed.json'),
    join(backendDir, 'package.json')
  ];
  for (const file of requiredFiles) {
    if (!existsSync(file)) {
      throw new Error(`Missing required file: ${file}`);
    }
  }
});

// 4. Check Firebase config: google-services.json
runCheck('Firebase config: google-services.json', () => {
  const { existsSync } = await_import_fs();
  const path = join(appDir, 'android/app/google-services.json');
  if (!existsSync(path)) {
    throw new Error(`Missing Firebase Android config: ${path}`);
  }
});

// 5. Check Firebase config: GoogleService-Info.plist
runCheck('Firebase config: GoogleService-Info.plist', () => {
  const { existsSync } = await_import_fs();
  const path = join(appDir, 'ios/Runner/GoogleService-Info.plist');
  if (!existsSync(path)) {
    throw new Error(`Missing Firebase iOS config: ${path}`);
  }
});

// 6. Flutter analyze.
runCheck('Flutter analyze (no fatal infos)', () => {
  execSync('flutter analyze --no-fatal-infos', {
    cwd: appDir,
    stdio: 'pipe',
    timeout: 120_000
  });
});

// 7. Flutter tests.
runCheck('Flutter tests', () => {
  execSync('flutter test', {
    cwd: appDir,
    stdio: 'pipe',
    timeout: 180_000
  });
});

// 8. Backend ritual-7day E2E test.
runCheck('Ritual 7-day E2E test', () => {
  execSync('node --test tests/ritual-7day.test.mjs', {
    cwd: backendDir,
    stdio: 'pipe',
    timeout: 60_000
  });
});

// 9. Validate seed data.
runCheck('Seed data validation', () => {
  execSync('node qa/validate_seed.mjs', {
    cwd: projectRoot,
    stdio: 'pipe',
    timeout: 30_000
  });
});

// Print verdict.
console.log('\n=== Verdict ===\n');

const passed = checks.filter((c) => c.status === 'PASS').length;
const failed = checks.filter((c) => c.status === 'FAIL').length;

console.log(`  Checks: ${checks.length} total, ${passed} passed, ${failed} failed\n`);

if (failed > 0) {
  console.log('  NO-GO — Fix failing checks before release.\n');
  console.log('  Failed checks:');
  for (const c of checks.filter((c) => c.status === 'FAIL')) {
    console.log(`    - ${c.name}: ${c.error}`);
  }
  console.log('');
  process.exit(1);
} else {
  console.log('  GO — All release gate checks passed.\n');
  process.exit(0);
}
