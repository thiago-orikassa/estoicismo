# SC-02 Log de Verificacao - 2026-02-14

## Fontes canonicas
- Seneca: *Moral Letters to Lucilius* (trad. Richard M. Gummere, Loeb, via Wikisource).
- Epictetus: *The Discourses of Epictetus; with the Encheiridion and Fragments* (trad. George Long, 1877, via Wikisource).
- Marcus Aurelius: *The Thoughts of the Emperor Marcus Aurelius Antoninus* (trad. George Long, 1889, via Wikisource).

## Registros verificados (lote 10)

| catalog_id | autor | source_ref | status | nota |
| --- | --- | --- | --- | --- |
| SEN-1 | seneca | Letter 1 | verified | Texto e referencia confirmados na edicao Gummere. |
| SEN-2 | seneca | Letter 2 | verified | Texto e referencia confirmados na edicao Gummere. |
| SEN-9 | seneca | Letter 9 | verified | Texto e referencia confirmados na edicao Gummere. |
| EPI-1 | epictetus | Section 1 | verified | Texto e referencia confirmados na traducao George Long. |
| EPI-5 | epictetus | Section 5 | verified | Texto e referencia confirmados na traducao George Long. |
| EPI-20 | epictetus | Section 20 | verified | Texto e referencia confirmados na traducao George Long. |
| MAR-1 | marcus_aurelius | Book 2.1 | verified | Texto e referencia confirmados na traducao George Long. |
| MAR-2 | marcus_aurelius | Book 4.3 | verified | Texto e referencia confirmados na traducao George Long. |
| MAR-3 | marcus_aurelius | Book 6.19 | verified | Texto e referencia confirmados na traducao George Long. |
| MAR-4 | marcus_aurelius | Book 5.16 | verified | Texto e referencia confirmados na traducao George Long. |

## Lote extraido automaticamente (80 registros)

- Origem: Wikisource canonical render (`action=render`) por referencia.
- Status aplicado no catalogo: `pending_review` (nao promovido para `verified` sem revisao cruzada humana).
- Arquivo atualizado: `content/catalog/quotes_catalog_90.csv`.
- Seed consolidado para revisao: `content/seeds/quotes_seed_review_v1.json`.

### Ajustes de referencia executados

No conjunto de Marcus Aurelius, as referencias `Book 2.18` ate `Book 2.30` nao existem na edicao George Long de Book II (encerra em 2.17). Para manter rastreabilidade canônica, os IDs foram remapeados para `Book 3.1` ate `Book 3.13`:

| catalog_id | referencia antiga | referencia nova |
| --- | --- | --- |
| MAR-18 | Book 2.18 | Book 3.1 |
| MAR-19 | Book 2.19 | Book 3.2 |
| MAR-20 | Book 2.20 | Book 3.3 |
| MAR-21 | Book 2.21 | Book 3.4 |
| MAR-22 | Book 2.22 | Book 3.5 |
| MAR-23 | Book 2.23 | Book 3.6 |
| MAR-24 | Book 2.24 | Book 3.7 |
| MAR-25 | Book 2.25 | Book 3.8 |
| MAR-26 | Book 2.26 | Book 3.9 |
| MAR-27 | Book 2.27 | Book 3.10 |
| MAR-28 | Book 2.28 | Book 3.11 |
| MAR-29 | Book 2.29 | Book 3.12 |
| MAR-30 | Book 2.30 | Book 3.13 |

## Consolidado SC-02 (2026-02-14)

- Total catalogo: 90/90 linhas com `quote_text` preenchido.
- Distribuicao final apos SC-04:
  - `verified`: 40
  - `rejected`: 50
- Resultado: sem status pendente no catalogo (`pending_* = 0`).
- Referencia de curadoria final: `docs/execution/sc-04-log-integridade-2026-02-14.md`.
