# Agentes Operacionais - MVP com Paywall v1

Data: 2026-02-14  
Base: `docs/board-execucao-agentes.md`, `docs/execution/contexto-paywall-v1.md`, `docs/execution/mvp-escopo-v1.md`

## 1. Objetivo
Definir como cada agente executa as tarefas do MVP com paywall, com handoff claro, evidências e gates de qualidade.

## 2. Regras Globais (melhores práticas)
- Não quebrar o ritual diário free (pacote diário + check-in).
- Sem paywall na primeira sessão.
- Paywall com frequência máxima de 1x/dia e cooldown de 48h após recusa.
- Toda mudança de monetização deve ser protegida por feature flag.
- Toda decisão de produto deve ser suportada por evento versionado.
- Nenhuma entrega vai para `DONE` sem evidência verificável.

## 3. Contrato de Handoff entre agentes
- Entrada obrigatória:
  - objetivo da tarefa,
  - dependências resolvidas,
  - critérios de aceite.
- Saída obrigatória:
  - PR/commit referenciado,
  - teste executado,
  - risco conhecido,
  - plano de rollback.

## 4. Agentes e Playbooks

## 4.1 Product Strategist (PS-04)
Missão:
- Consolidar regras de monetização no MVP sem comprometer retenção.

Tarefas foco:
- PS-04.

Checklist:
- Definir e publicar gatilhos A/B/C.
- Confirmar limites de frequência e cooldown.
- Definir guardrails de corte (D7 e check-in).
- Publicar baseline e metas de monetização.

Saída esperada:
- Documento de decisão atualizado + critérios de corte objetivos.

Evidência:
- Atualização em `docs/execution/mvp-escopo-v1.md` e board.

Handoff:
- Para MA-04/MA-05 com critérios de implementação e métricas.

## 4.2 Mobile Architect (MA-04, MA-05)
Missão:
- Traduzir regras de produto em arquitetura controlável e auditável.

Tarefas foco:
- MA-04, MA-05.

Checklist:
- Definir flags por trigger (`feature_block`, `value_based`, `manual`).
- Garantir avaliação de frequência/cooldown local + backend.
- Centralizar lógica de elegibilidade (evitar lógica duplicada por tela).
- Validar comportamento em offline/erro sem travar fluxo free.

Saída esperada:
- Documento técnico + implementação de flags e orquestração.

Evidência:
- Código com ponto único de decisão + testes de elegibilidade.

Handoff:
- Para BE-07/BE-08 (contratos) e AN-04/IOS-04 (integração de compra).

## 4.3 Backend and Data Engineer (BE-07, BE-08)
Missão:
- Garantir contratos de assinatura, trial e telemetria confiáveis.

Tarefas foco:
- BE-07, BE-08.

Checklist:
- Expor entitlement e elegibilidade de trial.
- Expor endpoint/evento de restore com idempotência.
- Instrumentar `paywall_*`, `trial_*`, `subscription_*` com `event_version`.
- Validar compatibilidade retroativa de contrato.

Saída esperada:
- API documentada + testes de contrato + eventos persistidos.

Evidência:
- OpenAPI atualizado, testes passando, amostras de eventos.

Handoff:
- Para QA-05/QA-06 e mobile platform specialists.

## 4.4 Android Specialist (AN-04)
Missão:
- Integrar Billing Android com UX consistente e retorno ao contexto de origem.

Tarefas foco:
- AN-04 (dependendo de MA-05 e BE-07).

Checklist:
- Trial start/compra/restore sem perda de contexto.
- Mensagens de erro acionáveis.
- Botão de restore visível e funcional.
- Acessibilidade mínima nos fluxos de compra.

Saída esperada:
- Fluxo Android fim-a-fim validado em staging.

Evidência:
- Vídeo curto ou logs do fluxo + testes manuais documentados.

Handoff:
- Para QA-05.

## 4.5 iOS Specialist (IOS-04)
Missão:
- Integrar StoreKit com comportamento alinhado ao HIG e ao funil de produto.

Tarefas foco:
- IOS-04 (dependendo de MA-05 e BE-07).

Checklist:
- Trial/compra/restore com retorno direto à feature bloqueada.
- Transparência de preço/renovação/cancelamento.
- Tratamento de erro sem bloqueio do fluxo free.
- Dynamic Type e acessibilidade preservados.

Saída esperada:
- Fluxo iOS fim-a-fim validado em staging.

Evidência:
- Evidência de execução + checklist HIG.

Handoff:
- Para QA-05.

## 4.6 QA and Analytics Lead (QA-05, QA-06)
Missão:
- Validar qualidade funcional e impacto da monetização em retenção.

Tarefas foco:
- QA-05, QA-06.

Checklist:
- E2E de monetização (feature block -> paywall -> trial/compra/restore).
- E2E do ritual free sem regressão com paywall ativo.
- Dashboard com trial rate, conversion, D7, check-in pós-exposição.
- Alertas para queda de D7 >10% e check-in >8%.

Saída esperada:
- Relatório de qualidade + painel de monitoramento ativo.

Evidência:
- Logs de execução E2E + screenshots de dashboards.

Handoff:
- Para PS (go/no-go) e Release Gate.

## 5. Definição de Pronto por Tarefa (DoD)
- Critério de aceite atendido.
- Testes relevantes executados.
- Telemetria mínima validada.
- Risco e rollback documentados.
- Evidência anexada no board.

## 6. Anti-padrões proibidos
- Ativar paywall sem feature flag.
- Bloquear check-in diário para usuário free.
- Lançar mudança sem eventos mínimos.
- Alterar preço/copy sem atualização de docs e analytics.
- Marcar `DONE` sem evidência.
