# Conteúdo Editorial

## Arquivos
- `catalog/quotes_catalog_90.csv`: catálogo de 90 referências para extração literal de citações.
- `recommendations/recommendations_40.csv`: 40 recomendações práticas vinculadas a referências.
- `seeds/`: reservado para seeds validados (`authenticity_level=verified`).
  - `seeds/quotes_seed_verified_v1.json`: lote inicial verificado (10/90).
  - `seeds/quotes_seed_review_v1.json`: seed completo (90/90) para revisão editorial.
  - `seeds/quotes_seed_verified_v2.json`: seed editorial final do MVP (40/90 aprovadas).
- `docs/execution/sc-02-protocolo-verificacao-v1.md`: protocolo de verificação editorial.
- `docs/execution/sc-02-log-verificacao-2026-02-14.md`: log do lote verificado.
- `docs/execution/sc-04-log-integridade-2026-02-14.md`: log da curadoria final de integridade filosófica.

## Status
- SC-02: concluído (90/90 com referência canônica e texto literal extraído).
- SC-03: concluído (40 recomendações práticas com contexto, passos e journaling).
- SC-04: concluído (40 `verified` para produção e 50 `rejected` por critérios editoriais de MVP).
