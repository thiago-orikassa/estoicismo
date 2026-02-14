import { mkdirSync, readdirSync, readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { DatabaseSync } from 'node:sqlite';

const __dirname = dirname(fileURLToPath(import.meta.url));
const defaultDataDir = join(__dirname, '../data');
const dataDir = process.env.STOIC_DATA_DIR ?? defaultDataDir;
const dbPath = process.env.STOIC_DB_PATH ?? join(dataDir, 'estoicismo.db');

mkdirSync(dataDir, { recursive: true });

const db = new DatabaseSync(dbPath);
db.exec('pragma journal_mode = WAL');
db.exec('pragma foreign_keys = ON');
db.exec('pragma busy_timeout = 5000');

db.exec(`
  create table if not exists schema_migrations (
    id text primary key,
    applied_at_utc text not null
  )
`);

function applyMigrations() {
  const migrationsDir = join(__dirname, '../migrations');
  const files = readdirSync(migrationsDir)
    .filter((file) => file.endsWith('.sql'))
    .sort();

  const appliedRows = db.prepare('select id from schema_migrations').all();
  const applied = new Set(appliedRows.map((row) => row.id));

  for (const file of files) {
    if (applied.has(file)) continue;
    const sql = readFileSync(join(migrationsDir, file), 'utf-8');
    const now = new Date().toISOString();
    try {
      db.exec('begin');
      db.exec(sql);
      db.prepare('insert into schema_migrations (id, applied_at_utc) values (?, ?)').run(
        file,
        now
      );
      db.exec('commit');
    } catch (err) {
      try {
        db.exec('rollback');
      } catch {
        // ignore rollback errors
      }
      throw err;
    }
  }
}

applyMigrations();

export { db, dbPath };
