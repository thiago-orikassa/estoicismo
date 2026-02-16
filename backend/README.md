# Backend (Sprint 1)

API mínima para destravar integração do app mobile no MVP.

## Persistência
- SQLite (arquivo local): `backend/data/aethor.db` por padrão.
- Variáveis:
  - `STOIC_DATA_DIR` (default: `backend/data`)
  - `STOIC_DB_PATH` (default: `<STOIC_DATA_DIR>/aethor.db`)
  - `STOIC_SEED_PATH` (default: `<STOIC_DATA_DIR>/daily_seed.json`)
  - `STOIC_RUNTIME_ENV` (ex.: `dev`, `stage`)
  - `STOIC_OBSERVABILITY_TOKEN` (opcional, protege endpoint de métricas)

## Endpoints
- `GET /health`
- `GET /v1/observability/metrics`
- `POST /v1/session`
- `GET /v1/daily-package?date_local=YYYY-MM-DD&timezone=America/Sao_Paulo`
- `POST /v1/checkins`
- `GET /v1/favorites?user_id=<uuid>`
- `POST /v1/favorites`
- `DELETE /v1/favorites?user_id=<uuid>&quote_id=<id>`
- `GET /v1/history?timezone=America/Sao_Paulo&date_local=YYYY-MM-DD&days=30`

## Autenticação (MVP)
- Crie/renove sessão com `POST /v1/session` e guarde o `access_token`.
- Envie `Authorization: Bearer <access_token>` em `checkins` e `favorites`.

## Rodar local
```bash
cd /Users/thiagoorikassa/Documents/Estoicismo/backend
npm start
```

## Provisionamento padronizado (BE-01)
Provisiona runtime local com migrações aplicadas e seed pronto.

```bash
cd /Users/thiagoorikassa/Documents/Estoicismo/backend
npm run provision:dev
npm run provision:stage
```

Relatórios são gravados em:
- `backend/.runtime/dev/provision-report.json`
- `backend/.runtime/stage/provision-report.json`

## Start por perfil (dev/stage)
```bash
cd /Users/thiagoorikassa/Documents/Estoicismo/backend
npm run start:dev
# ou
npm run start:stage
```

## Simular scheduler diário (idempotente)
```bash
npm run schedule -- America/Sao_Paulo 2026-02-14 7
```
Executar novamente com os mesmos parâmetros não duplica pacotes.

## Observabilidade (BE-06)
Logs estruturados JSON são emitidos para stdout:
- `server_bootstrap`
- `server_listening`
- `http_request_completed`

Métricas operacionais:
- Endpoint: `GET /v1/observability/metrics`
- Se `STOIC_OBSERVABILITY_TOKEN` estiver definido, enviar header:
  - `x-observability-token: <token>`

## Exemplo check-in
```bash
TOKEN=$(curl -s http://localhost:8787/v1/session \
  -H 'content-type: application/json' \
  -d '{"device_id":"ios-device-001"}' | jq -r .access_token)

curl -X POST http://localhost:8787/v1/checkins \
  -H 'content-type: application/json' \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"user_id":"11111111-1111-1111-8111-111111111111","date_local":"2026-02-14","applied":true,"timezone":"America/Sao_Paulo","note":"apliquei no trabalho"}'
```

## Exemplo favoritos
```bash
TOKEN=$(curl -s http://localhost:8787/v1/session \
  -H 'content-type: application/json' \
  -d '{"device_id":"ios-device-001"}' | jq -r .access_token)

curl -X POST http://localhost:8787/v1/favorites \
  -H 'content-type: application/json' \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"user_id":"11111111-1111-1111-8111-111111111111","quote_id":"q-mar-4"}'
```
