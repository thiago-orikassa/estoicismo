#!/usr/bin/env node

/**
 * Observability Check — QA-06
 *
 * Queries /v1/observability/metrics and validates that key operational
 * counters are present and non-negative.
 *
 * Usage:
 *   node backend/scripts/observability-check.mjs [base_url]
 *
 * Environment:
 *   STOIC_OBSERVABILITY_TOKEN — token to authenticate with metrics endpoint
 *   BASE_URL — defaults to http://127.0.0.1:8787
 */

const baseUrl = process.argv[2] || process.env.BASE_URL || 'http://127.0.0.1:8787';
const token = process.env.STOIC_OBSERVABILITY_TOKEN || '';

async function main() {
  console.log(`[observability-check] Querying ${baseUrl}/v1/observability/metrics`);

  const headers = {};
  if (token) {
    headers['x-observability-token'] = token;
  }

  let res;
  try {
    res = await fetch(`${baseUrl}/v1/observability/metrics`, { headers });
  } catch (err) {
    console.error(`[FAIL] Cannot reach server: ${err.message}`);
    process.exit(1);
  }

  if (res.status !== 200) {
    console.error(`[FAIL] Metrics endpoint returned status ${res.status}`);
    process.exit(1);
  }

  const metrics = await res.json();
  const issues = [];

  // Validate required fields exist.
  if (!metrics.generated_at_utc) {
    issues.push('Missing generated_at_utc');
  }

  if (!metrics.tables || typeof metrics.tables !== 'object') {
    issues.push('Missing or invalid tables object');
  } else {
    const requiredTables = [
      'sessions',
      'checkins',
      'favorites',
      'analytics_events',
      'subscription_profiles',
      'push_tokens'
    ];
    for (const table of requiredTables) {
      const count = metrics.tables[table];
      if (count === undefined || count === null) {
        issues.push(`Missing table count: ${table}`);
      } else if (typeof count !== 'number' || count < 0) {
        issues.push(`Invalid table count for ${table}: ${count}`);
      }
    }
  }

  if (!metrics.subscriptions || typeof metrics.subscriptions !== 'object') {
    issues.push('Missing or invalid subscriptions object');
  } else {
    const expectedStatuses = ['free', 'trial', 'active', 'canceled'];
    for (const status of expectedStatuses) {
      if (metrics.subscriptions[status] === undefined) {
        issues.push(`Missing subscription status: ${status}`);
      }
    }
  }

  if (!Array.isArray(metrics.analytics_events_by_name)) {
    issues.push('Missing or invalid analytics_events_by_name array');
  }

  // Print results.
  console.log('\n--- Operational Metrics ---');
  console.log(`Generated at: ${metrics.generated_at_utc}`);

  if (metrics.tables) {
    console.log('\nTables:');
    for (const [table, count] of Object.entries(metrics.tables)) {
      console.log(`  ${table}: ${count}`);
    }
  }

  if (metrics.subscriptions) {
    console.log('\nSubscription profiles by status:');
    for (const [status, count] of Object.entries(metrics.subscriptions)) {
      console.log(`  ${status}: ${count}`);
    }
  }

  if (metrics.analytics_events_by_name?.length > 0) {
    console.log('\nTop analytics events:');
    for (const entry of metrics.analytics_events_by_name.slice(0, 10)) {
      console.log(`  ${entry.event_name}: ${entry.total}`);
    }
  }

  console.log('');

  if (issues.length > 0) {
    console.error(`[FAIL] ${issues.length} issue(s) found:`);
    for (const issue of issues) {
      console.error(`  - ${issue}`);
    }
    process.exit(1);
  }

  console.log('[OK] All observability checks passed.');
  process.exit(0);
}

main();
