# Status de Execução - 2026-02-14

## Tarefas concluídas hoje
- PS-01: escopo MVP congelado v1.
- PS-02: metas e baseline definidos.
- PS-03: priorização impacto x risco definida.
- PS-04: regras de monetização no MVP consolidadas (gatilhos, frequência, guardrails).
- SC-01: matriz editorial v1 criada.
- MA-01: arquitetura de pastas/camadas definida.
- MA-02: contratos de dados v1 definidos.
- MA-03: política offline/cache definida.
- MA-04: estratégia de feature flags de paywall implementada no app.
- QA-01: plano de testes v1 criado.
- SC-03: 40 recomendações práticas estruturadas e vinculadas.
- BE-02: endpoint `GET /v1/daily-package` implementado e validado.
- BE-04: endpoint `POST /v1/checkins` implementado e validado.
- BE-03: endpoints de favoritos e histórico implementados e validados.
- BE-05: scheduler diário idempotente implementado e validado em simulação de 7 dias.
- BE-07: contrato de assinatura publicado (`entitlement`, `trial/start`, `activate`, `restore` com idempotência).
- QA-02: eventos de funil instrumentados no backend com naming consistente.
- BE-08: endpoint `POST /v1/analytics/events` implementado com autenticação, versionamento e persistência.
- AN-01: base UI Android (Material 3) implementada em Flutter.
- IOS-01: base UI iOS (HIG/Cupertino + Dynamic Type base) implementada em Flutter.
- SC-02: catálogo editorial fechado com 90/90 referências canônicas e texto literal.
- SC-04: revisão de integridade concluída com curadoria final para MVP (`40 verified` / `50 rejected`).
- BE-01: provisionamento dev/stage padronizado com scripts e relatório de migração.
- BE-06: logs estruturados e endpoint de métricas operacionais publicados.

## Tarefas em andamento
- MA-05: orquestração de gatilhos de paywall em app (A/B/C) implementada com regra de frequência/cooldown, pendente validação E2E completa.
- MA-05 (parcial concluído em 2026-02-15): motor de elegibilidade centralizado + razão de bloqueio auditável + trigger de consistência no 3º dia ativo.

## Decisões editoriais confirmadas (SC-02)
- Fonte de verdade: 1 edição canônica por autor (preferência domínio público).
- Prioridade: cobertura por contexto do MVP com equilíbrio mínimo por autor.
- Tradução: 1 tradução consistente por autor em PT com referência explícita.
- Protocolo de verificação: `/Users/thiagoorikassa/Documents/Estoicismo/docs/execution/sc-02-protocolo-verificacao-v1.md`

## Evidências
- `/Users/thiagoorikassa/Documents/Estoicismo/docs/execution/*.md`
- `/Users/thiagoorikassa/Documents/Estoicismo/backend/migrations/001_init.sql`
- `/Users/thiagoorikassa/Documents/Estoicismo/backend/openapi/daily-package.openapi.yaml`
- `/Users/thiagoorikassa/Documents/Estoicismo/backend/src/server.mjs`
- `/Users/thiagoorikassa/Documents/Estoicismo/backend/src/logger.mjs`
- `/Users/thiagoorikassa/Documents/Estoicismo/backend/scripts/provision.mjs`
- `/Users/thiagoorikassa/Documents/Estoicismo/backend/scripts/start-profile.mjs`
- `/Users/thiagoorikassa/Documents/Estoicismo/backend/tests/server.test.mjs`
- `/Users/thiagoorikassa/Documents/Estoicismo/backend/migrations/004_subscriptions.sql`
- `/Users/thiagoorikassa/Documents/Estoicismo/backend/data/daily_seed.json`
- `/Users/thiagoorikassa/Documents/Estoicismo/backend/data/favorites.json`
- `/Users/thiagoorikassa/Documents/Estoicismo/backend/src/scheduler.mjs`
- `/Users/thiagoorikassa/Documents/Estoicismo/backend/data/scheduled_packages.json`
- `/Users/thiagoorikassa/Documents/Estoicismo/backend/data/analytics_events.json`
- `/Users/thiagoorikassa/Documents/Estoicismo/qa/plano-testes-v1.md`
- `/Users/thiagoorikassa/Documents/Estoicismo/qa/eventos-analytics-v1.md`
- `/Users/thiagoorikassa/Documents/Estoicismo/content/catalog/quotes_catalog_90.csv`
- `/Users/thiagoorikassa/Documents/Estoicismo/content/seeds/quotes_seed_review_v1.json`
- `/Users/thiagoorikassa/Documents/Estoicismo/content/seeds/quotes_seed_verified_v2.json`
- `/Users/thiagoorikassa/Documents/Estoicismo/docs/execution/sc-04-log-integridade-2026-02-14.md`
- `/Users/thiagoorikassa/Documents/Estoicismo/content/recommendations/recommendations_40.csv`
- `/Users/thiagoorikassa/Documents/Estoicismo/app/lib/main.dart`
- `/Users/thiagoorikassa/Documents/Estoicismo/app/lib/app_state.dart`
- `/Users/thiagoorikassa/Documents/Estoicismo/app/lib/core/paywall/paywall_flow.dart`
- `/Users/thiagoorikassa/Documents/Estoicismo/app/lib/core/paywall/paywall_policy.dart`
- `/Users/thiagoorikassa/Documents/Estoicismo/app/lib/features/daily_quote/presentation/home_screen.dart`
- `/Users/thiagoorikassa/Documents/Estoicismo/app/lib/features/daily_quote/data/daily_repository.dart`
- `/Users/thiagoorikassa/Documents/Estoicismo/app/test/core/paywall/paywall_policy_test.dart`
- `/Users/thiagoorikassa/Documents/Estoicismo/app/lib/features/history/presentation/history_screen.dart`
- `/Users/thiagoorikassa/Documents/Estoicismo/app/lib/features/favorites/presentation/favorites_screen.dart`
- `/Users/thiagoorikassa/Documents/Estoicismo/app/lib/features/settings/presentation/settings_screen.dart`
- `/Users/thiagoorikassa/Documents/Estoicismo/app/lib/core/networking/api_client.dart`
- `/Users/thiagoorikassa/Documents/Estoicismo/app/lib/core/theme/app_theme.dart`

## Validação técnica executada (2026-02-14)
- `npm test --prefix backend`: 15/15 testes passando (inclui assinatura, `/v1/analytics/events` e observabilidade backend).
- `cd app && flutter test`: 7/7 testes passando.
- `cd app && flutter analyze`: sem erros de compilação; pendências em lints informativos históricos.
- `cd app && flutter analyze lib/core/paywall lib/features/daily_quote/presentation/home_screen.dart lib/app_state.dart`: sem issues.

## Próximo bloco de execução
1. QA-05: suíte E2E de monetização (feature block -> paywall -> trial/compra/restore).
2. AN-04 + IOS-04: integração de compra/restore usando contrato BE-07.
3. AN-02 + IOS-02: fechar push/deeplink para habilitar QA-03.
4. QA-03: retomar E2E do fluxo diário em 7 ciclos com o novo seed de conteúdo.

## Bloqueio técnico atual
- Sem bloqueio técnico crítico de toolchain no momento (Flutter disponível no ambiente local).

## Atualização de escopo (2026-02-14)
- Revisão do `MVP Escopo Congelado v1`: assinatura e paywall v1 incluídos no MVP com guardrails de retenção e frequência.
- Pontos de entrada de monetização na UI permanecem ativos (Histórico, Favoritos e Ajustes), sem bloquear o ritual diário free.
