# SC-04 Log de Integridade Filosofica - 2026-02-14

## Escopo
Revisao editorial do catalogo SC-02 para publicacao de um conjunto de maior qualidade no MVP, com foco em:
- fidelidade filosofica;
- clareza para consumo rapido (<30s);
- adequacao de linguagem para usuarios PT-BR;
- evitacao de trechos fragmentarios ou de baixa aplicabilidade pratica.

## Criterios aplicados
1. Fonte canonica obrigatoria e referencia valida (work/ref/url).
2. Clareza textual para leitura rapida no card principal.
3. Aderencia ao ritual diario (acao pratica e reflexao aplicavel no dia).
4. Exclusao de trechos com baixa adequacao de UX/editorial para o MVP.

## Decisao de curadoria
- `verified`: 40 citacoes (pool de producao).
- `rejected`: 50 citacoes (mantidas no catalogo para historico, fora do pool MVP).
- `pending_*`: 0.

## Remapeamentos de recomendacoes (qualidade de retorno)
Para melhorar qualidade no app sem quebrar semantica dos fluxos, 6 recomendacoes foram relinkadas para citacoes mais fortes:

| recommendation_id | antigo | novo |
| --- | --- | --- |
| REC-007 | SEN-7 | SEN-11 |
| REC-008 | SEN-8 | SEN-12 |
| REC-022 | EPI-12 | EPI-21 |
| REC-028 | EPI-18 | EPI-23 |
| REC-036 | MAR-6 | MAR-11 |
| REC-040 | MAR-10 | MAR-12 |

## Artefatos publicados
- Catalogo final SC-04: `content/catalog/quotes_catalog_90.csv`
  - Status final por item: `verified` ou `rejected`.
- Recomendacoes atualizadas: `content/recommendations/recommendations_40.csv`
  - 40 recomendacoes com links coerentes ao pool aprovado.
- Seed editorial verificado v2: `content/seeds/quotes_seed_verified_v2.json`
  - Campos completos de verificacao editorial.
- Seed de producao backend: `backend/data/daily_seed.json`
  - 40 quotes em PT curado + 40 recommendations, `authenticity_level=verified`.

## Resultado para usuarios (MVP)
- Mais variedade: 4x mais opcoes no retorno diario (de 10 para 40 quotes).
- Melhor consistencia linguistica: 100% PT no seed de producao.
- Melhor qualidade media: retirada de trechos fragmentarios/menos aplicaveis.

## Evidencia de execucao
- Script de curadoria SC-04: `scripts/content/execute_sc04_curation.py`
- Execucao registrada em terminal (2026-02-14):
  - `recommendations_remapped=6`
  - `curated_verified=40`
  - `catalog_rejected=50`
