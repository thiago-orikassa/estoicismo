/**
 * FCM HTTP v1 Client
 *
 * Authenticates via JWT using the service account private key,
 * exchanges for an OAuth2 access token, and sends push notifications
 * through the FCM HTTP v1 API.
 *
 * Zero external dependencies — uses only node:crypto and node:https.
 */

import { createSign } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { logger } from './logger.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const FCM_DRY_RUN = process.env.FCM_DRY_RUN === 'true';
const PUSH_ENABLED = process.env.PUSH_ENABLED !== 'false';

let serviceAccount = null;
let cachedAccessToken = null;
let tokenExpiresAt = 0;

function loadServiceAccount() {
  if (serviceAccount) return serviceAccount;
  const secretPath =
    process.env.FCM_SERVICE_ACCOUNT_PATH ??
    join(__dirname, '../secrets/fcm-service-account.json');
  try {
    serviceAccount = JSON.parse(readFileSync(secretPath, 'utf-8'));
    return serviceAccount;
  } catch {
    return null;
  }
}

function createJwt(sa) {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: 'RS256', typ: 'JWT' };
  const payload = {
    iss: sa.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 3600,
  };

  const b64 = (obj) =>
    Buffer.from(JSON.stringify(obj)).toString('base64url');

  const unsigned = `${b64(header)}.${b64(payload)}`;
  const sign = createSign('RSA-SHA256');
  sign.update(unsigned);
  const signature = sign.sign(sa.private_key, 'base64url');

  return `${unsigned}.${signature}`;
}

async function getAccessToken() {
  if (cachedAccessToken && Date.now() < tokenExpiresAt - 60_000) {
    return cachedAccessToken;
  }

  const sa = loadServiceAccount();
  if (!sa) return null;

  const jwt = createJwt(sa);
  const body = new URLSearchParams({
    grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
    assertion: jwt,
  });

  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: body.toString(),
  });

  if (!res.ok) {
    const text = await res.text();
    logger.error('fcm_oauth_token_error', { status: res.status, body: text });
    return null;
  }

  const data = await res.json();
  cachedAccessToken = data.access_token;
  tokenExpiresAt = Date.now() + (data.expires_in ?? 3600) * 1000;
  return cachedAccessToken;
}

/**
 * Send a push notification to a single FCM token.
 *
 * @param {object} options
 * @param {string} options.fcmToken  - The device FCM token.
 * @param {string} options.title     - Notification title.
 * @param {string} options.body      - Notification body.
 * @param {object} [options.data]    - Arbitrary data payload.
 * @returns {Promise<{success: boolean, error?: string, unregistered?: boolean}>}
 */
async function sendPushNotification({ fcmToken, title, body, data = {} }) {
  if (!PUSH_ENABLED) {
    return { success: true, dry_run: true };
  }

  if (FCM_DRY_RUN) {
    logger.info('fcm_dry_run', { fcmToken, title });
    return { success: true, dry_run: true };
  }

  const sa = loadServiceAccount();
  if (!sa) {
    return { success: false, error: 'no_service_account' };
  }

  const accessToken = await getAccessToken();
  if (!accessToken) {
    return { success: false, error: 'no_access_token' };
  }

  const projectId = sa.project_id;
  const url = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

  const payload = {
    message: {
      token: fcmToken,
      notification: { title, body },
      data: Object.fromEntries(
        Object.entries(data).map(([k, v]) => [k, String(v)])
      ),
      android: {
        notification: { channel_id: 'daily_reminder' },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
            'content-available': 1,
          },
        },
      },
    },
  };

  try {
    const res = await fetch(url, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
    });

    if (res.ok) {
      return { success: true };
    }

    const errorBody = await res.json().catch(() => ({}));
    const errorCode = errorBody?.error?.details?.[0]?.errorCode ?? '';

    if (errorCode === 'UNREGISTERED' || res.status === 404) {
      return { success: false, error: 'UNREGISTERED', unregistered: true };
    }

    logger.error('fcm_send_error', {
      status: res.status,
      error: errorBody,
      fcmToken: fcmToken.slice(0, 12) + '...',
    });
    return { success: false, error: `http_${res.status}` };
  } catch (err) {
    logger.error('fcm_send_exception', { message: err.message });
    return { success: false, error: err.message };
  }
}

/**
 * Send a push notification to all active tokens for a given user.
 *
 * @param {object} options
 * @param {string} options.userId
 * @param {string} options.title
 * @param {string} options.body
 * @param {object} [options.data]
 * @param {object} options.db - Object with prepared statements:
 *   - selectActiveTokensByUser(userId) → [{fcm_token, platform}]
 *   - deactivateToken(fcmToken) → void
 * @returns {Promise<{sent: number, failed: number, invalid_tokens_removed: number}>}
 */
async function sendToUser({ userId, title, body, data = {}, db }) {
  const tokens = db.selectActiveTokensByUser(userId);
  let sent = 0;
  let failed = 0;
  let invalidTokensRemoved = 0;

  for (const row of tokens) {
    const result = await sendPushNotification({
      fcmToken: row.fcm_token,
      title,
      body,
      data,
    });

    if (result.success) {
      sent += 1;
      if (db.markDelivery) {
        db.markDelivery(row.fcm_token);
      }
    } else {
      failed += 1;
      if (result.unregistered) {
        db.deactivateToken(row.fcm_token);
        invalidTokensRemoved += 1;
      }
    }
  }

  return { sent, failed, invalid_tokens_removed: invalidTokensRemoved };
}

export { sendPushNotification, sendToUser, loadServiceAccount, FCM_DRY_RUN, PUSH_ENABLED };
