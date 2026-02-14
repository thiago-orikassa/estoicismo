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
