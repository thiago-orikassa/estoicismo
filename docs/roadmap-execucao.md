# Roadmap de Execução

## Fase 0 (Semana 1) - Fundação
- Definir stack final (Flutter + backend).
- Estruturar design system mobile (tokens, tipografia, espaçamento).
- Criar banco inicial de 90 citações verificadas.
- Definir 40 recomendações práticas iniciais.

## Fase 1 (Semanas 2-4) - MVP funcional
- Onboarding + preferências.
- Home diária (citação + ação + check-in).
- Favoritos + histórico 30 dias.
- Notificações diárias por timezone.
- Instrumentação analytics básica.

## Fase 2 (Semanas 5-6) - Beta fechado
- Ajustes de UX com base em eventos reais.
- Melhorias de copy e densidade de conteúdo.
- A/B test de formato de notificação.
- Hardening: crashes, performance, offline.

## Fase 3 (Semanas 7-8) - Expansão de acesso (Widget)
- Widget "Insight do dia" com citação curta e atalho para abrir o app na Home diária.
- Widget "Ação de hoje" com CTA para registrar check-in no app.
- Suporte Android e iOS com comportamento nativo por plataforma.
- Telemetria de uso do widget (impressão, toque e abertura no app).
- Validação de impacto em retenção e check-in rate antes de escalar.

## Backlog priorizado (P0)
- Scheduler diário confiável.
- Pipeline editorial com fonte obrigatória.
- Caching e fallback offline.
- Permissão e gestão de push.
- Evento de check-in com timestamp local.

## Backlog priorizado (P1)
- Widget diário com acesso rápido ao ritual.
- Deeplink do widget para Home diária e bloco de check-in.
- Instrumentação de eventos de widget no app/backend.

## Critérios de pronto do MVP
- Usuário recebe e consome o conteúdo diário sem falhas por 7 dias.
- 95%+ das telas principais carregam em < 1,5s em rede normal.
- Crash-free sessions > 99,5% no beta.
- 100% das citações do MVP com fonte catalogada.

## Sprint inicial (2 semanas)
## Semana 1
- Arquitetura e boilerplate do app.
- Banco de dados e APIs base.
- Home estática com dados mock.
- Primeira versão do sistema editorial.

## Semana 2
- Integração com dados reais.
- Notificação local/remota.
- Favoritos, histórico e check-in.
- Telemetria + testes críticos de fluxo.

---

## Atualização de passagem para release MVP (2026-02-14)

### Objetivo operacional
Concluir os blocos restantes para liberar o **MVP com paywall v1** sem quebrar o ritual diário free.

### Janela proposta de execução

## Bloco A — Fechamento de base e conteúdo (2026-02-16 a 2026-02-20)
- SC-02: finalizar curadoria de 90 citações com referência validada.
- SC-04: revisão de integridade filosófica.
- BE-01: fechar provisionamento dev/stage com migrações e runtime padronizado.
- BE-06: telemetria backend/logs estruturados ativa para suporte ao gate de release.

Saída esperada:
- Conteúdo validado + infraestrutura estável para testes E2E.

## Bloco B — Push e fluxo diário E2E (2026-02-23 a 2026-02-27)
- AN-02: push Android (FCM + permissões + deeplink).
- IOS-02: push iOS (APNs/FCM + permissões + deeplink).
- QA-03: execução de 7 dias simulados do fluxo diário (sem falha crítica).

Saída esperada:
- Ritual diário comprovado em iOS e Android com entrega de push e abertura correta.

## Bloco C — Monetização E2E e gate beta (2026-03-02 a 2026-03-06)
- MA-05: validar orquestração de gatilhos A/B/C com frequência e cooldown.
- AN-04 + IOS-04: trial/compra/restore com retorno ao contexto bloqueado.
- QA-05: E2E monetização completo sem regressão no fluxo free.
- QA-06: dashboard + alertas ativos (`paywall_*`, `trial_*`, `subscription_*`).
- QA-04: gate de release beta (go/no-go).

Saída esperada:
- Release Candidate do MVP pronto em **2026-03-06**.

### Janela de release
- Beta fechado: **2026-03-09 a 2026-03-11** (se QA-04 = aprovado).

### Gate de Go/No-Go (obrigatório)
- 90 citações com fonte verificável (SC-02) e revisão editorial sem pendência crítica (SC-04).
- Fluxo diário rodando 7/7 ciclos sem erro crítico (QA-03).
- Push Android e iOS com deeplink funcional (AN-02 + IOS-02).
- Trial/compra/restore operando nos dois sistemas (AN-04 + IOS-04 + QA-05).
- Telemetria mínima ativa com eventos versionados e dashboards com alertas (BE-08 + QA-06).
- Crash-free sessions > 99,5% no beta.
- Guardrails preservados: sem regressão relevante de D7 e sem queda de check-in acima do limite definido no board.

### Escopo fora da passagem de release MVP
- SC-05 (expansão de autores adicionais) permanece P2 pós-release.
