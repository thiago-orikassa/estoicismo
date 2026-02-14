# Board de Execução por Agentes

Baseado em:
- `/Users/thiagoorikassa/Documents/Estoicismo/docs/roadmap-execucao.md`
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
| SC-01 | Stoic Content Curator | Criar matriz editorial (autor x tema x contexto) | P0 | M | PS-01 | Matriz publicada com cobertura mínima por célula | DONE |
| SC-02 | Stoic Content Curator | Curar 90 citações com fonte verificável | P0 | L | SC-01 | 100% com referência catalogada e validade | IN PROGRESS |
| SC-03 | Stoic Content Curator | Criar 40 recomendações práticas vinculadas | P0 | M | SC-01 | Cada recomendação com princípio + ação + critério | DONE |
| SC-04 | Stoic Content Curator | Revisão de integridade filosófica | P0 | M | SC-02, SC-03 | Checklist sem pendências críticas | TODO |
| SC-05 | Stoic Content Curator | Expandir catálogo com autores estoicos adicionais (Zenão, Cleantes, Crisipo, Musônio Rufo, Hierócles, Posidônio) | P2 | L | SC-02 | Autores adicionados com fonte canônica definida e 100% das citações com referência | TODO |
| MA-01 | Mobile Architect | Definir arquitetura de pastas e camadas | P0 | S | PS-01 | Estrutura documentada com exemplos | DONE |
| MA-02 | Mobile Architect | Contratos de dados (Quote, Recommendation, Check-in) | P0 | M | MA-01, SC-01 | Schemas versionados + validações mínimas | DONE |
| MA-03 | Mobile Architect | Estratégia offline e cache de 7 dias | P0 | M | MA-01 | Fluxo offline documentado + política de expiração | DONE |
| MA-04 | Mobile Architect | Definir estratégia de feature flags | P1 | S | MA-01 | Plano de toggles por funcionalidade crítica | TODO |
| BE-01 | Backend and Data Engineer | Provisionar backend e banco base | P0 | M | MA-02 | Ambientes dev/stage com migrações iniciais | IN PROGRESS |
| BE-02 | Backend and Data Engineer | API pacote diário por timezone | P0 | M | BE-01, SC-02, SC-03 | Endpoint retorna citação + recomendação válidas | DONE |
| BE-03 | Backend and Data Engineer | API de favoritos e histórico | P0 | M | BE-01 | CRUD funcional com paginação | DONE |
| BE-04 | Backend and Data Engineer | API de check-in diário | P0 | S | BE-01 | Persistência com timestamp local e UTC | DONE |
| BE-05 | Backend and Data Engineer | Scheduler diário confiável | P0 | M | BE-02 | Entrega diária sem duplicidade em teste de 7 dias | DONE |
| BE-06 | Backend and Data Engineer | Telemetria backend e logs estruturados | P1 | S | BE-01 | Logs e métricas de erro disponíveis | TODO |
| AN-01 | Android Specialist | Base UI Android (Material 3) | P1 | M | MA-01 | Home, histórico e ajustes com padrões M3 | DONE |
| AN-02 | Android Specialist | Fluxo push Android (FCM + permissões) | P0 | M | BE-05 | Push entregue e aberto com deeplink correto | TODO |
| AN-03 | Android Specialist | Acessibilidade Android (fonte/contraste/leitura) | P1 | S | AN-01 | Checklist de acessibilidade sem bloqueadores | TODO |
| IOS-01 | iOS Specialist | Base UI iOS (HIG + Dynamic Type) | P1 | M | MA-01 | Home, histórico e ajustes com padrões HIG | DONE |
| IOS-02 | iOS Specialist | Fluxo push iOS (APNs/FCM + permissões) | P0 | M | BE-05 | Push entregue e aberto com deeplink correto | TODO |
| IOS-03 | iOS Specialist | Acessibilidade iOS (Dynamic Type/VoiceOver) | P1 | S | IOS-01 | Checklist sem bloqueadores críticos | TODO |
| QA-01 | QA and Analytics Lead | Plano de testes e estratégia de regressão | P0 | S | PS-01, MA-01 | Plano com suíte mínima por fluxo crítico | DONE |
| QA-02 | QA and Analytics Lead | Instrumentação do funil diário | P0 | S | PS-02, BE-04 | Eventos publicados com naming consistente | DONE |
| QA-03 | QA and Analytics Lead | Testes E2E do fluxo diário (7 dias simulados) | P0 | M | BE-05, AN-02, IOS-02 | Execução sem falha crítica por 7 ciclos | TODO |
| QA-04 | QA and Analytics Lead | Gate de release beta | P0 | S | QA-03 | Crash-free >99,5% e checklist final aprovado | TODO |

## 2) Board Kanban inicial (Sprint 1-2)

## TODO
- SC-04
- SC-05

## IN PROGRESS
- BE-01
- SC-02

## BLOCKED
- (usar para dependências não resolvidas)

## REVIEW
- (tarefas prontas aguardando validação de aceite)

## DONE
- PS-01, PS-02, PS-03
- SC-01, SC-03
- MA-01, MA-02, MA-03
- BE-02, BE-03, BE-04, BE-05
- QA-01, QA-02
- AN-01, IOS-01

## 3) Plano tático de 2 semanas

## Semana 1 (fundação e conteúdo)
- Product: PS-01, PS-02, PS-03
- Editorial: SC-01 + começo SC-02
- Arquitetura: MA-01, MA-02, MA-03
- Backend: BE-01 e rascunho de BE-02/BE-04
- Mobile: AN-01 e IOS-01 (estrutura base de telas)
- QA: QA-01, QA-02

Meta da semana 1:
- Plataforma pronta para integrar dados reais sem retrabalho estrutural.

## Semana 2 (integração e fluxo diário)
- Editorial: concluir SC-02, SC-03 e SC-04
- Backend: BE-02, BE-03, BE-04, BE-05
- Mobile: AN-02, IOS-02 e ligação com APIs
- QA: QA-03

Meta da semana 2:
- Fluxo de valor completo: receber push, abrir citação diária, executar check-in, registrar evento.

## 4) Rituais de operação entre agentes
- Daily (15 min): bloqueios e dependências por ID.
- Refinamento 2x/semana (30 min): quebrar P1 em tarefas de no máximo 3 dias.
- Review semanal (45 min): validar critérios de aceite e evidências.
- Retro quinzenal (45 min): ajustar fluxo e capacidade por agente.

## 5) Gatilhos de escalonamento (atenção a risco)
- Se SC-02 atrasar >2 dias: congelar novas features e priorizar conteúdo.
- Se BE-05 falhar em confiabilidade: bloquear release beta.
- Se QA-03 encontrar falha crítica: voltar tarefa para IN PROGRESS com plano de correção em 24h.

## 6) Definição de pronto (DoD global)
Uma tarefa só vai para `DONE` quando tiver:
- Critério de aceite atendido.
- Evidência (print, log, teste, dashboard ou PR).
- Sem regressão conhecida no fluxo diário.
