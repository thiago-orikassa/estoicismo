/**
 * Teste direto de APNs — bypassa Firebase completamente.
 * Envia push direto para o device via APNs HTTP/2 com JWT Auth.
 *
 * Uso:
 *   node scripts/test-apns-direct.mjs \
 *     --key /caminho/para/AuthKey_L8JK5M5W9K.p8 \
 *     --device-token 8ED4F6F4BA1C2EFD32AC9D74DA9CB3684C610D53903F26D20C23D2B08D23A49C
 */

import { createSign } from 'node:crypto';
import { readFileSync } from 'node:fs';
import http2 from 'node:http2';

const TEAM_ID = 'CK8Q479NZG';
const KEY_ID = 'U7NMZ968M3';
const BUNDLE_ID = 'com.thiago.aethorApp';
// Parse args
const args = process.argv.slice(2);
const keyIndex = args.indexOf('--key');
const tokenIndex = args.indexOf('--device-token');
const isSandbox = args.includes('--sandbox');

const APNS_HOST = isSandbox ? 'api.sandbox.push.apple.com' : 'api.push.apple.com';

if (keyIndex === -1 || tokenIndex === -1) {
  console.error('Uso: node test-apns-direct.mjs --key <path-to.p8> --device-token <hex-token>');
  process.exit(1);
}

const keyPath = args[keyIndex + 1];
const deviceToken = args[tokenIndex + 1];

// Carrega a chave .p8
const privateKey = readFileSync(keyPath, 'utf-8');

// Gera JWT para autenticação APNs
function makeJwt() {
  const now = Math.floor(Date.now() / 1000);
  const header = Buffer.from(JSON.stringify({ alg: 'ES256', kid: KEY_ID })).toString('base64url');
  const payload = Buffer.from(JSON.stringify({ iss: TEAM_ID, iat: now })).toString('base64url');
  const unsigned = `${header}.${payload}`;
  const sign = createSign('SHA256');
  sign.update(unsigned);
  const signature = sign.sign({ key: privateKey, dsaEncoding: 'ieee-p1363' }, 'base64url');
  return `${unsigned}.${signature}`;
}

const jwt = makeJwt();

// Debug: decode and print JWT parts to verify format
const [jwtHeader, jwtPayload] = jwt.split('.');
console.log('JWT Header:', JSON.parse(Buffer.from(jwtHeader, 'base64url').toString()));
console.log('JWT Payload:', JSON.parse(Buffer.from(jwtPayload, 'base64url').toString()));
console.log('JWT Signature length (bytes):', Buffer.from(jwt.split('.')[2], 'base64url').length, '(expected 64)');

const body = JSON.stringify({
  aps: {
    alert: { title: 'Teste APNs Direto', body: 'Se você está vendo isso, APNs funciona!' },
    sound: 'default',
  },
});

console.log(`\nEnviando para APNs...`);
console.log(`  Device token: ${deviceToken.slice(0, 16)}...`);
console.log(`  Bundle ID: ${BUNDLE_ID}`);
console.log(`  Team ID: ${TEAM_ID}`);
console.log(`  Key ID: ${KEY_ID}`);
console.log(`  Host: ${APNS_HOST}\n`);

const session = http2.connect(`https://${APNS_HOST}`);

session.on('error', (err) => {
  console.error('❌ Erro de conexão:', err.message);
  session.destroy();
});

const req = session.request({
  ':method': 'POST',
  ':path': `/3/device/${deviceToken}`,
  'authorization': `bearer ${jwt}`,
  'apns-topic': BUNDLE_ID,
  'apns-push-type': 'alert',
  'apns-expiration': '0',
  'apns-priority': '10',
  'content-type': 'application/json',
  'content-length': Buffer.byteLength(body),
});

let responseBody = '';
req.on('response', (headers) => {
  const status = headers[':status'];
  req.setEncoding('utf8');
  req.on('data', (chunk) => { responseBody += chunk; });
  req.on('end', () => {
    session.destroy();
    if (status === 200) {
      console.log('✅ APNs aceitou a mensagem (status 200)');
      console.log('   A notificação deve aparecer no iPhone em instantes.');
    } else {
      console.log(`❌ APNs rejeitou com status ${status}`);
      if (responseBody) {
        try {
          const err = JSON.parse(responseBody);
          console.log(`   Reason: ${err.reason}`);
          console.log('\n--- Diagnóstico ---');
          const reasons = {
            BadDeviceToken: 'Token inválido ou expirado. Reinstale o app para obter um novo token.',
            DeviceTokenNotForTopic: 'Bundle ID incorreto ou token é de outro ambiente (dev vs prod).',
            InvalidProviderToken: 'Team ID ou Key ID incorreto na chave .p8.',
            ExpiredProviderToken: 'JWT expirou. Tente novamente.',
            BadCertificate: 'Certificado inválido.',
            Unregistered: 'App desinstalado do device ou token expirado.',
            TopicDisallowed: 'Bundle ID não tem Push Notifications habilitado no Apple Developer.',
          };
          if (reasons[err.reason]) {
            console.log(`   👉 ${reasons[err.reason]}`);
          }
        } catch {
          console.log(`   Body: ${responseBody}`);
        }
      }
    }
  });
});

req.write(body);
req.end();
