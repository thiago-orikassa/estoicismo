# Política Offline e Cache de 7 Dias (MA-03)

Data: 2026-02-14

## Objetivo
Garantir consumo diário mesmo sem rede.

## Política
- Persistir sempre os últimos 7 pacotes diários no SQLite.
- Ao abrir app:
  1. tenta rede
  2. se falhar, usa cache do dia
  3. se dia indisponível, usa item mais recente e exibe aviso discreto

## Expiração
- TTL padrão: 24h para tentativa de refresh de item do dia.
- Purga: remover itens com > 10 dias.

## Integridade
- hash do payload para detectar corrupção.
- fallback para leitura local apenas (sem bloquear UI).
