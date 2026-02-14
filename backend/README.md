# Backend (Sprint 1)

API mínima para destravar integração do app mobile no MVP.

## Endpoints
- `GET /health`
- `GET /v1/daily-package?date_local=YYYY-MM-DD&timezone=America/Sao_Paulo`
- `POST /v1/checkins`
- `GET /v1/favorites?user_id=<uuid>`
- `POST /v1/favorites`
- `DELETE /v1/favorites?user_id=<uuid>&quote_id=<id>`
- `GET /v1/history?timezone=America/Sao_Paulo&date_local=YYYY-MM-DD&days=30`

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
curl -X POST http://localhost:8787/v1/checkins \
  -H 'content-type: application/json' \
  -d '{"user_id":"11111111-1111-1111-1111-111111111111","date_local":"2026-02-14","applied":true,"timezone":"America/Sao_Paulo","note":"apliquei no trabalho"}'
```

## Exemplo favoritos
```bash
curl -X POST http://localhost:8787/v1/favorites \
  -H 'content-type: application/json' \
  -d '{"user_id":"11111111-1111-1111-1111-111111111111","quote_id":"q-mar-4"}'
```

## Observação
O seed atual usa trechos marcados como `probable` enquanto a curadoria literal (SC-02) é finalizada.
