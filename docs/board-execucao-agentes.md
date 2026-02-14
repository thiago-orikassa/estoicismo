# Board de Execução por Agentes

Baseado em:
- `/Users/thiagoorikassa/Documents/Estoicismo/docs/roadmap-execucao.md`
- `/Users/thiagoorikassa/Documents/Estoicismo/docs/execution/contexto-paywall-v1.md`
- `/Users/thiagoorikassa/Documents/Estoicismo/docs/execution/mvp-escopo-v1.md`
- `/Users/thiagoorikassa/Documents/Estoicismo/AGENTS.md`

## Convenções
- Prioridade: P0 (crítico), P1 (alto), P2 (médio)
- Esforço: S (<= 1 dia), M (2-3 dias), L (4-5 dias)
- Status inicial: `TODO`
- Dependências: IDs de tarefas prévias

## 1) Backlog Operacional (quebrado por agente)

| ID | Agente | Tarefa | Prioridade | Esforço | Dependências | Critério de aceite | Status |
|---|---|---|---|---|---|---|---|
| PS-01 | Product Strategist | Fechar escopo MVP congelado (v1) | P0 | S | - | Documento de escopo com "in/out" assinado | DONE |
| PS-02 | Product Strategist | Definir metas D1/D7 + baseline esperado | P0 | S | PS-01 | Metas registradas com fórmula de cálculo | DONE |
| PS-03 | Product Strategist | Priorizar backlog por impacto x risco | P0 | S | PS-01 | Ranking de tarefas P0/P1 aprovado | DONE |
| PS-04 | Product Strategist | Consolidar regras de monetização no MVP (gatilhos, frequência e guardrails de retenção) | P0 | S | PS-01, PS-02 | Regras publicadas e alinhadas no board + escopo MVP | DONE |
| SC-01 | Stoic Content Curator | Criar matriz editorial (autor x tema x contexto) | P0 | M | PS-01 | Matriz publicada com cobertura mínima por célula | DONE |
| SC-02 | Stoic Content Curator | Curar 90 citações com fonte verificável | P0 | L | SC-01 | 100% com referência catalogada e validade | DONE |
| SC-03 | Stoic Content Curator | Criar 40 recomendações práticas vinculadas | P0 | M | SC-01 | Cada recomendação com princípio + ação + critério | DONE |
| SC-04 | Stoic Content Curator | Revisão de integridade filosófica | P0 | M | SC-02, SC-03 | Checklist sem pendências críticas | DONE |
| SC-05 | Stoic Content Curator | Expandir catálogo com autores estoicos adicionais (Zenão, Cleantes, Crisipo, Musônio Rufo, Hierócles, Posidônio) | P2 | L | SC-02 | Autores adicionados com fonte canônica definida e 100% das citações com referência | TODO |
| MA-01 | Mobile Architect | Definir arquitetura de pastas e camadas | P0 | S | PS-01 | Estrutura documentada com exemplos | DONE |
| MA-02 | Mobile Architect | Contratos de dados (Quote, Recommendation, Check-in) | P0 | M | MA-01, SC-01 | Schemas versionados + validações mínimas | DONE |
| MA-03 | Mobile Architect | Estratégia offline e cache de 7 dias | P0 | M | MA-01 | Fluxo offline documentado + política de expiração | DONE |
| MA-04 | Mobile Architect | Definir estratégia de feature flags | P0 | S | MA-01 | Plano de toggles por funcionalidade crítica | DONE |
| MA-05 | Mobile Architect | Orquestrar gatilhos de paywall no app (A/B/C) com regra de frequência e cooldown | P0 | M | MA-04, PS-04 | Gatilhos implementados e auditáveis por logs/eventos | IN PROGRESS |
| BE-01 | Backend and Data Engineer | Provisionar backend e banco base | P0 | M | MA-02 | Ambientes dev/stage com migrações iniciais | IN PROGRESS |
| BE-02 | Backend and Data Engineer | API pacote diário por timezone | P0 | M | BE-01, SC-02, SC-03 | Endpoint retorna citação + recomendação válidas | DONE |
| BE-03 | Backend and Data Engineer | API de favoritos e histórico | P0 | M | BE-01 | CRUD funcional com paginação | DONE |
| BE-04 | Backend and Data Engineer | API de check-in diário | P0 | S | BE-01 | Persistência com timestamp local e UTC | DONE |
| BE-05 | Backend and Data Engineer | Scheduler diário confiável | P0 | M | BE-02 | Entrega diária sem duplicidade em teste de 7 dias | DONE |
| BE-06 | Backend and Data Engineer | Telemetria backend e logs estruturados | P1 | S | BE-01 | Logs e métricas de erro disponíveis | TODO |
| BE-07 | Backend and Data Engineer | Expor entitlement de assinatura + elegibilidade de trial + restauração | P0 | M | BE-01, MA-05 | Contrato de assinatura disponível e validado em staging | DONE |
| BE-08 | Backend and Data Engineer | Instrumentar eventos de monetização no backend (`paywall_*`, `trial_*`, `subscription_*`) | P0 | S | BE-06, PS-04 | Eventos publicados com propriedades mínimas e versionamento | DONE |
| AN-01 | Android Specialist | Base UI Android (Material 3) | P1 | M | MA-01 | Home, histórico e ajustes com padrões M3 | DONE |
| AN-02 | Android Specialist | Fluxo push Android (FCM + permissões) | P0 | M | BE-05 | Push entregue e aberto com deeplink correto | TODO |
| AN-03 | Android Specialist | Acessibilidade Android (fonte/contraste/leitura) | P1 | S | AN-01 | Checklist de acessibilidade sem bloqueadores | TODO |
| AN-04 | Android Specialist | Integrar compra e restore Android (Billing) com retorno para feature bloqueada | P0 | M | MA-05, BE-07 | Trial/compra/restore concluídos com retorno ao contexto correto | TODO |
| IOS-01 | iOS Specialist | Base UI iOS (HIG + Dynamic Type) | P1 | M | MA-01 | Home, histórico e ajustes com padrões HIG | DONE |
| IOS-02 | iOS Specialist | Fluxo push iOS (APNs/FCM + permissões) | P0 | M | BE-05 | Push entregue e aberto com deeplink correto | TODO |
| IOS-03 | iOS Specialist | Acessibilidade iOS (Dynamic Type/VoiceOver) | P1 | S | IOS-01 | Checklist sem bloqueadores críticos | TODO |
| IOS-04 | iOS Specialist | Integrar compra e restore iOS (StoreKit) com retorno para feature bloqueada | P0 | M | MA-05, BE-07 | Trial/compra/restore concluídos com retorno ao contexto correto | TODO |
| QA-01 | QA and Analytics Lead | Plano de testes e estratégia de regressão | P0 | S | PS-01, MA-01 | Plano com suíte mínima por fluxo crítico | DONE |
| QA-02 | QA and Analytics Lead | Instrumentação do funil diário | P0 | S | PS-02, BE-04 | Eventos publicados com naming consistente | DONE |
| QA-03 | QA and Analytics Lead | Testes E2E do fluxo diário (7 dias simulados) | P0 | M | BE-05, AN-02, IOS-02 | Execução sem falha crítica por 7 ciclos | TODO |
| QA-04 | QA and Analytics Lead | Gate de release beta | P0 | S | QA-03 | Crash-free >99,5% e checklist final aprovado | TODO |
| QA-05 | QA and Analytics Lead | Testes E2E de monetização com guardrails de retenção | P0 | M | MA-05, BE-07, AN-04, IOS-04 | Fluxo paywall/trial/restore sem quebra do ritual diário free | TODO |
| QA-06 | QA and Analytics Lead | Dashboard e alertas de monetização (trial, conversão, impacto em D7/check-in) | P0 | S | BE-08, QA-05 | Painel ativo com regras de corte automatizáveis | TODO |

## 2) Board Kanban Atual (Release MVP)

## TODO
- SC-05
- BE-06
- AN-02
- AN-03
- AN-04
- IOS-02
- IOS-03
- IOS-04
- QA-03
- QA-04
- QA-05
- QA-06

## IN PROGRESS
- BE-01
- MA-05

## BLOCKED
- (usar para dependências não resolvidas)

## REVIEW
- (tarefas prontas aguardando validação de aceite)

## DONE
- PS-01, PS-02, PS-03, PS-04
- SC-01, SC-02, SC-03, SC-04
- MA-01, MA-02, MA-03, MA-04
- BE-02, BE-03, BE-04, BE-05, BE-07, BE-08
- QA-01, QA-02
- AN-01, IOS-01

## 3) Plano de passagem para release MVP (2026-02-14)

## Bloco A (2026-02-16 a 2026-02-20) - Base e conteúdo
- SC-02 (curadoria final das 90 citações com fonte).
- SC-04 (revisão de integridade filosófica).
- BE-01 (provisionamento dev/stage e migrações).
- BE-06 (telemetria backend e logs estruturados).

Meta do bloco A:
- Conteúdo e infraestrutura fechados para iniciar E2E sem ambiguidades.

## Bloco B (2026-02-23 a 2026-02-27) - Push e ritual diário
- AN-02 (push Android com deeplink).
- IOS-02 (push iOS com deeplink).
- QA-03 (execução de 7 dias simulados do fluxo diário).

Meta do bloco B:
- Ritual diário comprovado em iOS/Android com push entregue e abertura correta.

## Bloco C (2026-03-02 a 2026-03-06) - Monetização E2E e gate beta
- MA-05 (validação final de gatilhos A/B/C com frequência e cooldown).
- AN-04 e IOS-04 (trial/compra/restore com retorno ao contexto de bloqueio).
- QA-05 (E2E monetização sem regressão do fluxo free).
- QA-06 (dashboards e alertas de monetização/guardrails).
- QA-04 (gate de release beta: go/no-go).

Meta do bloco C:
- Release Candidate pronto em 2026-03-06.

## Janela de release
- Beta fechado: 2026-03-09 a 2026-03-11 (condicionado ao QA-04 aprovado).

## Gate de Go/No-Go (obrigatório)
- SC-02 e SC-04 concluídos sem pendências críticas.
- QA-03 validado em 7/7 ciclos sem erro crítico.
- AN-02 e IOS-02 com push + deeplink funcionando.
- AN-04 e IOS-04 com trial/compra/restore estáveis.
- QA-05 e QA-06 concluídos com monitoramento ativo.
- Crash-free > 99,5% no beta.
- Sem queda acima dos limites de guardrail (D7 e check-in) definidos em PS-04.

## 4) Rituais de operação entre agentes
- Daily (15 min): bloqueios e dependências por ID.
- Refinamento 2x/semana (30 min): quebrar P1 em tarefas de no máximo 3 dias.
- Review semanal (45 min): validar critérios de aceite e evidências.
- Retro quinzenal (45 min): ajustar fluxo e capacidade por agente.

## 5) Gatilhos de escalonamento (atenção a risco)
- Se SC-02 atrasar >2 dias: congelar novas features e priorizar conteúdo.
- Se BE-05 falhar em confiabilidade: bloquear release beta.
- Se QA-03 encontrar falha crítica: voltar tarefa para IN PROGRESS com plano de correção em 24h.
- Se D7 cair >10% relativo após exposição de paywall: pausar variação e voltar para controle.
- Se check-in rate cair >8% relativo após paywall: reduzir frequência de exibição e reavaliar gatilhos.

## 6) Definição de pronto (DoD global)
Uma tarefa só vai para `DONE` quando tiver:
- Critério de aceite atendido.
- Evidência (print, log, teste, dashboard ou PR).
- Sem regressão conhecida no fluxo diário.

## 7) Evidências recentes (2026-02-14)
- App (feature flags + gatilhos): `app/lib/app_state.dart`, `app/lib/core/paywall/paywall_flow.dart`, `app/lib/features/daily_quote/presentation/home_screen.dart`, `app/lib/features/daily_quote/data/daily_repository.dart`.
- Backend (eventos versionados): `backend/src/server.mjs`, `backend/tests/server.test.mjs`, `backend/openapi/daily-package.openapi.yaml`.
- Backend (contrato de assinatura): `GET /v1/subscription/entitlement`, `POST /v1/subscription/trial/start`, `POST /v1/subscription/activate`, `POST /v1/subscription/restore` em `backend/src/server.mjs`.
- UI/design system alinhado ao Figma MCP: PR #5 (`feat(ui): alinhar design system Flutter ao Figma MCP`).
- Conteúdo editorial SC-02/SC-04: `content/catalog/quotes_catalog_90.csv` finalizado (`40 verified` / `50 rejected`); remapeamento de recomendações em `content/recommendations/recommendations_40.csv`; seed editorial final em `content/seeds/quotes_seed_verified_v2.json`; seed de produção em `backend/data/daily_seed.json`; logs em `docs/execution/sc-02-log-verificacao-2026-02-14.md` e `docs/execution/sc-04-log-integridade-2026-02-14.md`.
- Testes executados: `npm test --prefix backend` (13/13 passando), `cd app && flutter test` (1/1 passando).
- Observação de qualidade: `cd app && flutter analyze` segue falhando por lints informativos históricos (sem erro de compilação).
