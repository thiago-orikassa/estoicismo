const serviceName = process.env.STOIC_SERVICE_NAME ?? 'aethor-backend';
const runtimeEnv = process.env.STOIC_RUNTIME_ENV ?? process.env.NODE_ENV ?? 'dev';

function sanitizeValue(value) {
  if (value === undefined) return null;
  if (value instanceof Error) {
    return {
      name: value.name,
      message: value.message,
      stack: value.stack
    };
  }
  return value;
}

function log(level, event, fields = {}) {
  const payload = {
    timestamp_utc: new Date().toISOString(),
    level,
    service: serviceName,
    runtime_env: runtimeEnv,
    event
  };

  for (const [key, value] of Object.entries(fields)) {
    payload[key] = sanitizeValue(value);
  }

  process.stdout.write(`${JSON.stringify(payload)}\n`);
}

const logger = {
  info(event, fields) {
    log('info', event, fields);
  },
  warn(event, fields) {
    log('warn', event, fields);
  },
  error(event, fields) {
    log('error', event, fields);
  }
};

export { logger, runtimeEnv };
