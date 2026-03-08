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
| MA-05 | Mobile Architect | Orquestrar gatilhos de paywall no app (A/B/C) com regra de frequência e cooldown | P0 | M | MA-04, PS-04 | Gatilhos implementados e auditáveis por logs/eventos | DONE |
| BE-01 | Backend and Data Engineer | Provisionar backend e banco base | P0 | M | MA-02 | Ambientes dev/stage com migrações iniciais | DONE |
| BE-02 | Backend and Data Engineer | API pacote diário por timezone | P0 | M | BE-01, SC-02, SC-03 | Endpoint retorna citação + recomendação válidas | DONE |
| BE-03 | Backend and Data Engineer | API de favoritos e histórico | P0 | M | BE-01 | CRUD funcional com paginação | DONE |
| BE-04 | Backend and Data Engineer | API de check-in diário | P0 | S | BE-01 | Persistência com timestamp local e UTC | DONE |
| BE-05 | Backend and Data Engineer | Scheduler diário confiável | P0 | M | BE-02 | Entrega diária sem duplicidade em teste de 7 dias | DONE |
| BE-06 | Backend and Data Engineer | Telemetria backend e logs estruturados | P1 | S | BE-01 | Logs e métricas de erro disponíveis | DONE |
| BE-07 | Backend and Data Engineer | Expor entitlement de assinatura + elegibilidade de trial + restauração | P0 | M | BE-01, MA-05 | Contrato de assinatura disponível e validado em staging | DONE |
| BE-08 | Backend and Data Engineer | Instrumentar eventos de monetização no backend (`paywall_*`, `trial_*`, `subscription_*`) | P0 | S | BE-06, PS-04 | Eventos publicados com propriedades mínimas e versionamento | DONE |
| BE-09 | Backend and Data Engineer | Deploy Railway com Railway Volume para persistência SQLite | P0 | S | BE-01 | SQLite sobrevive a redeploy; dados não são zerados em produção | TODO |
| BE-10 | Backend and Data Engineer | Validação de recibos server-side (Apple/Google) | P1 | M | BE-07, IOS-04, AN-04 | Backend verifica recibo com App Store/Play antes de ativar entitlement | TODO |
| BE-11 | Backend and Data Engineer | Hardening de segurança backend (rate limit, TTL sessão, body limit, token forte) | P0 | S | BE-01 | Rate limiting em auth, sessions expiram, payload > 100KB rejeitado | DONE |
| BE-12 | Backend and Data Engineer | Log de auditoria de mudanças de assinatura | P2 | S | BE-07 | Tabela `subscription_audit_log` com motivo + timestamp de cada transição | TODO |
| AN-01 | Android Specialist | Base UI Android (Material 3) | P1 | M | MA-01 | Home, histórico e ajustes com padrões M3 | DONE |
| AN-02 | Android Specialist | Fluxo push Android (FCM + permissões) | P0 | M | BE-05 | Push entregue e aberto com deeplink correto | IN PROGRESS |
| AN-03 | Android Specialist | Acessibilidade Android (fonte/contraste/leitura) | P1 | S | AN-01 | Checklist de acessibilidade sem bloqueadores | TODO |
| AN-04 | Android Specialist | Integrar compra e restore Android (Billing) com retorno para feature bloqueada | P0 | M | MA-05, BE-07 | Trial/compra/restore concluídos com retorno ao contexto correto | TODO |
| IOS-01 | iOS Specialist | Base UI iOS (HIG + Dynamic Type) | P1 | M | MA-01 | Home, histórico e ajustes com padrões HIG | DONE |
| IOS-02 | iOS Specialist | Fluxo push iOS (APNs/FCM + permissões) | P0 | M | BE-05 | Push entregue e aberto com deeplink correto | IN PROGRESS |
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
- AN-03
- AN-04
- IOS-03
- IOS-04
- QA-03
- QA-04
- QA-05
- QA-06
- BE-09 ← **bloqueador de release** (dados ephemeral em produção)
- BE-10
- BE-12

## IN PROGRESS
- AN-02
- IOS-02

## BLOCKED
- (usar para dependências não resolvidas)

## REVIEW
- (tarefas prontas aguardando validação de aceite)

## DONE
- PS-01, PS-02, PS-03, PS-04
- SC-01, SC-02, SC-03, SC-04
- MA-01, MA-02, MA-03, MA-04, MA-05
- BE-01, BE-02, BE-03, BE-04, BE-05, BE-06, BE-07, BE-08, BE-11
- QA-01, QA-02
- AN-01, IOS-01

## 2.0) Macro Acionáveis (3 frentes)

| Acionável | Objetivo | IDs incluídos | Janela alvo | Status |
|---|---|---|---|---|
| 1 | Fechar orquestração de paywall (A/B/C) com guardrails e auditabilidade | MA-05 | 2026-02-17 a 2026-02-21 | DONE |
| 2 | Fechar push + deeplink cross-platform e validar ritual diário | AN-02, IOS-02, QA-03 | 2026-02-23 a 2026-03-06 | IN PROGRESS |
| 3 | Fechar monetização E2E + observabilidade + gate beta | AN-03, IOS-03, AN-04, IOS-04, QA-05, QA-06, QA-04 | 2026-02-24 a 2026-03-06 | TODO |

## 2.0.1) Execução do Acionável 1 (MA-05)
- Implementado motor de decisão de elegibilidade em `app/lib/core/paywall/paywall_policy.dart`.
- Regras centralizadas: primeira sessão protegida, frequência máxima de 24h, cooldown de 48h, flags por trigger e milestone de valor (`checkins_3`, `active_days_3`).
- App integrado com razão de bloqueio auditável (`paywall_view_blocked`) em `app/lib/core/paywall/paywall_flow.dart`.
- Trigger de consistência (3º dia ativo) aplicado também na Home ao carregar o pacote diário em `app/lib/features/daily_quote/presentation/home_screen.dart`.
- Cobertura de testes expandida de 6 para 44 em `app/test/core/paywall/paywall_policy_test.dart`.
- Validação final executada (2026-02-15):
  - `cd app && flutter test` -> 49/49 passando (44 paywall + 5 existentes).
  - `npm test --prefix backend` -> 15/15 passando.
  - `cd app && flutter analyze lib/core/paywall lib/features/daily_quote/presentation/home_screen.dart lib/app_state.dart` -> 0 issues.
- **Status: DONE** - Critério de aceite atendido (gatilhos A/B/C validados com frequência 1x/dia, cooldown 48h, sem paywall na 1a sessão, com eventos auditáveis). Sem regressão.

## 2.1) Board Operacional de Ação (faltantes do release)

| Ordem | Janela | Stream | IDs | Dono primário | Dependências | Critério de saída (DoD) | Status |
|---|---|---|---|---|---|---|---|
| 1 | 2026-02-17 a 2026-02-21 | Fechamento da orquestração de paywall | MA-05 | Mobile Architect | MA-04, PS-04, BE-07, BE-08 | Gatilhos A/B/C validados com frequência 1x/dia, cooldown 48h, sem paywall na 1a sessão, com eventos auditáveis | DONE |
| 2 | 2026-02-23 a 2026-02-27 | Push + deeplink cross-platform | AN-02, IOS-02 | Android Specialist + iOS Specialist | BE-05 | Push entregue em Android/iOS, abertura por deeplink no contexto correto (Home/check-in), eventos `push_received` e `push_opened` coletados | IN PROGRESS |
| 3 | 2026-02-24 a 2026-02-28 | Hardening de acessibilidade mobile | AN-03, IOS-03 | Android Specialist + iOS Specialist | AN-01, IOS-01 | Checklist sem bloqueadores (fonte escalavel, contraste, leitura/VoiceOver, targets minimos, navegação assistiva) | TODO |
| 4 | 2026-03-02 a 2026-03-04 | Compra e restauração reais (stores) | AN-04, IOS-04 | Android Specialist + iOS Specialist | MA-05, BE-07 | Trial/compra/restore em sandbox com retorno ao contexto bloqueado e erros tratáveis sem quebrar fluxo free | TODO |
| 5 | 2026-03-03 a 2026-03-05 | QA monetização + monitoramento de guardrails | QA-05, QA-06 | QA and Analytics Lead | AN-04, IOS-04, BE-08 | E2E monetização aprovado + dashboard/alertas ativos para `paywall_*`, `trial_*`, `subscription_*`, D7 e check-in | TODO |
| 6 | 2026-03-05 a 2026-03-06 | E2E do ritual diário (7 ciclos) | QA-03 | QA and Analytics Lead | AN-02, IOS-02, BE-05 | 7/7 ciclos simulados sem falha crítica (push -> abertura -> consumo -> check-in) | TODO |
| 7 | 2026-03-06 | Gate final de release beta | QA-04 | QA and Analytics Lead + Product Strategist | QA-03, QA-05, QA-06 | Go/No-Go formal: crash-free >99,5%, guardrails preservados e checklist final assinado | TODO |
| 8 | Pós-release (após 2026-03-11) | Expansão editorial P2 | SC-05 | Stoic Content Curator | SC-02 | Autores adicionais publicados com fonte canônica e 100% das citações rastreáveis | TODO |

## 2.2) Caminho crítico de execução
1. Trilha monetização: `MA-05 -> AN-04 + IOS-04 -> QA-05 -> QA-06 -> QA-04`.
2. Trilha ritual diário: `AN-02 + IOS-02 -> QA-03 -> QA-04`.
3. `QA-04` só fecha quando as duas trilhas acima estiverem concluídas e evidenciadas.

## 2.3) Checklist técnico obrigatório por stream
- Push/deeplink (`AN-02`, `IOS-02`): permissão contextual, token válido, payload com rota, app aberto em foreground/background/cold start, fallback seguro sem quebra do ritual free.
- Billing (`AN-04`, `IOS-04`): uso de fluxo nativo da loja, validação de entitlement no backend, restore idempotente, transparência de preço/teste/cancelamento.
- Telemetria (`QA-06`): eventos versionados, propriedades mínimas por evento, dashboard com corte automático para queda de D7 (>10% relativo) e check-in (>8% relativo).
- Qualidade (`QA-03`, `QA-05`, `QA-04`): evidência de execução (logs, vídeo curto, relatório), regressão do fluxo free monitorada, plano de rollback pronto.

## 2.4) Referências de mercado usadas no plano
- Android notification permission: https://developer.android.com/develop/ui/views/notifications/notification-permission
- FCM em Flutter: https://firebase.google.com/docs/cloud-messaging/flutter/receive
- Android App Links/deeplink: https://developer.android.com/training/app-links/add-applinks
- Apple Universal Links: https://developer.apple.com/library/archive/documentation/General/Conceptual/AppSearch/UniversalLinks.html
- Google Play Billing: https://developer.android.com/google/play/billing/integrate
- StoreKit e assinaturas: https://developer.apple.com/in-app-purchase/
- Crash-free e health metrics: https://firebase.google.com/docs/crashlytics/crash-free-metrics

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

## 7.1) Evidências recentes (2026-03-08) — Deploy Railway + Hardening

- **Backend em produção:** `https://aethor-production.up.railway.app` (Railway, Node 23, SQLite)
- **Arquivos de deploy:** `backend/railway.json`, `backend/nixpacks.toml`, `backend/scripts/start-railway.mjs`
- **Migrations aplicadas:** 001→009 (session expiry adicionada em 009)
- **Hardening (BE-11):** rate limiting auth (5/10/20 req/15 min), body limit 100 KB, tokens 256-bit, TTL sessão 90 dias
- **Testes:** 26/26 passando (24 server + 2 monetization/ritual)
- **Flutter:** `api_client.dart` aponta para Railway em produção; dev via `--dart-define=DEV_SERVER_URL`
- **Boas práticas documentadas:** `docs/backend-best-practices.md`
- **Commit:** `a3701e2` — `fix(backend): harden security before public TestFlight`
- **⚠️ BE-09 pendente:** dados SQLite são ephemeral — Railway Volume não configurado. **Não subir para produção real antes de resolver.**

## 7) Evidências recentes (2026-02-14)
- App (feature flags + gatilhos): `app/lib/app_state.dart`, `app/lib/core/paywall/paywall_flow.dart`, `app/lib/features/daily_quote/presentation/home_screen.dart`, `app/lib/features/daily_quote/data/daily_repository.dart`.
- Backend (eventos versionados): `backend/src/server.mjs`, `backend/tests/server.test.mjs`, `backend/openapi/daily-package.openapi.yaml`.
- Backend (provisionamento + observabilidade): `backend/scripts/provision.mjs`, `backend/scripts/start-profile.mjs`, `backend/src/logger.mjs`, `GET /v1/observability/metrics`.
- Log de entrega BE-01/BE-06: `docs/execution/be-01-be-06-entrega-2026-02-14.md`.
- Backend (contrato de assinatura): `GET /v1/subscription/entitlement`, `POST /v1/subscription/trial/start`, `POST /v1/subscription/activate`, `POST /v1/subscription/restore` em `backend/src/server.mjs`.
- UI/design system alinhado ao Figma MCP: PR #5 (`feat(ui): alinhar design system Flutter ao Figma MCP`).
- Conteúdo editorial SC-02/SC-04: `content/catalog/quotes_catalog_90.csv` finalizado (`40 verified` / `50 rejected`); remapeamento de recomendações em `content/recommendations/recommendations_40.csv`; seed editorial final em `content/seeds/quotes_seed_verified_v2.json`; seed de produção em `backend/data/daily_seed.json`; logs em `docs/execution/sc-02-log-verificacao-2026-02-14.md` e `docs/execution/sc-04-log-integridade-2026-02-14.md`.
- Testes executados: `npm test --prefix backend` (15/15 passando), `cd app && flutter test` (1/1 passando).
- Observação de qualidade: `cd app && flutter analyze` segue falhando por lints informativos históricos (sem erro de compilação).
