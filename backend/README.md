# Backend (Sprint 1)

API mínima para destravar integração do app mobile no MVP.

## Persistência
- SQLite (arquivo local): `backend/data/estoicismo.db` por padrão.
- Variáveis:
  - `STOIC_DATA_DIR` (default: `backend/data`)
  - `STOIC_DB_PATH` (default: `<STOIC_DATA_DIR>/estoicismo.db`)
  - `STOIC_SEED_PATH` (default: `<STOIC_DATA_DIR>/daily_seed.json`)

## Endpoints
- `GET /health`
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

## Simular scheduler diário (idempotente)
```bash
npm run schedule -- America/Sao_Paulo 2026-02-14 7
```
Executar novamente com os mesmos parâmetros não duplica pacotes.

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

## Observação
O seed atual usa trechos marcados como `probable` enquanto a curadoria literal (SC-02) é finalizada.
