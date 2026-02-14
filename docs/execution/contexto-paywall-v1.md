# Contexto - Paywall v1 (Assinatura)

Data: 2026-02-14  
Owner primário: Product Strategist  
Suporte: Mobile Architect, Android Specialist, iOS Specialist, Backend and Data Engineer, QA and Analytics Lead

## 1. Objetivo do paywall v1
Monetizar sem comprometer retenção do ritual diário, usando assinatura com oferta simples e timing baseado em momento de valor.

## 2. Escopo v1
Implementar somente assinatura (sem anúncios) com:
- 1 tela de paywall principal.
- 2 planos (mensal e anual).
- 1 período de teste grátis (apenas no anual).
- Gatilhos de exibição em momentos de valor.
- Instrumentação mínima de funil ponta a ponta.

## 3. Premissas obrigatórias antes de escalar
- Fluxo diário básico estável (daily package + check-in + push).
- Telemetria mínima ativa em app e backend.
- Fonte de citações e recomendações validada.
- Sem expansão de escopo para comunidade/gamificação.

## 4. Proposta de valor do Pro
Desbloquear profundidade e continuidade da prática estoica:
- Biblioteca completa com fontes verificadas.
- Trilhas guiadas por objetivo: ansiedade, foco e disciplina.
- Histórico e insights de progresso.
- Áudio-reflexões.
- Lembretes inteligentes por contexto.

## 5. Modelo de planos e preço
- Pro Mensal: R$ 19,90 por mês.
- Pro Anual: R$ 149,00 por ano.
- Teste grátis: 7 dias no plano anual.
- Ancoragem de preço: anual destacado como melhor custo-benefício.

## 6. Limites Free vs Pro

| Área | Free | Pro |
|---|---|---|
| Pacote diário | Incluído | Incluído |
| Favoritos | Limitado | Ilimitado |
| Histórico | Janela curta | Completo |
| Trilhas guiadas | Bloqueado | Completo |
| Áudio-reflexões | Bloqueado | Completo |
| Insights de progresso | Básico | Avançado |

## 7. Gatilhos de exibição do paywall
Mostrar paywall sem interromper a primeira experiência:
- Gatilho A (valor comprovado): após 3 check-ins concluídos.
- Gatilho B (consistência): no 3º dia de uso ativo.
- Gatilho C (intenção): ao tentar abrir trilha premium ou histórico completo.
- Regras de frequência: no máximo 1 exibição por dia; cooldown de 48 horas após recusa explícita.

## 8. Estrutura do paywall v1 (copy base)
Headline:
- Evolua sua prática estoica com profundidade.

Subheadline:
- Desbloqueie trilhas guiadas, histórico completo e insights para transformar reflexão em ação diária.

Bullets de valor:
- Trilhas práticas para ansiedade, foco e disciplina.
- Histórico completo da sua jornada.
- Áudios curtos para aplicar no dia a dia.

Bloco de planos:
- Mensal: R$ 19,90/mês.
- Anual: R$ 149/ano (7 dias grátis).

CTAs:
- Primário: Iniciar 7 dias grátis.
- Secundário: Continuar no gratuito.
- Ação adicional: Restaurar compra.

Microcopy de confiança:
- Cancele quando quiser antes do fim do período de teste.

## 9. Experimento A/B inicial (14 dias)
Objetivo:
- Maximizar conversão para trial sem reduzir retenção D7.

Variações:
- Variante A: foco em "progresso e consistência".
- Variante B: foco em "alívio de ansiedade e clareza".

Métricas de decisão:
- Trial start rate.
- Trial to paid conversion.
- Retenção D7.
- Check-in rate pós-exposição do paywall.

Critérios de corte:
- Pausar variação se retenção D7 cair mais que 10% relativo ao baseline.
- Pausar variação se check-in rate cair mais que 8% relativo ao baseline.

## 10. Instrumentação de analytics (v1)
Eventos novos:
- paywall_viewed
- paywall_dismissed
- paywall_cta_clicked
- trial_started
- subscription_activated
- subscription_renewed
- subscription_canceled
- premium_feature_blocked

Propriedades mínimas por evento:
- user_id
- date_local
- timezone
- event_version
- paywall_variant
- trigger_type
- plan_selected
- price_displayed
- trial_eligible

## 11. Metas de performance (fase inicial)
- Trial start rate > 8%.
- Trial to paid > 35%.
- Churn mensal < 6%.
- Conversão anual/mensal > 1,5.
- Retenção D7 sem regressão relevante pós-paywall.

## 12. Plano de execução (30 dias)
Semana 1:
- Fechar copy e regras de gatilho.
- Implementar eventos de analytics no app/backend.
- Validar tracking em ambiente de teste.

Semana 2:
- Publicar paywall v1 com variante A.
- Ativar pricing e trial.
- Monitorar funil diário.

Semana 3:
- Rodar A/B (A vs B) com guarda de retenção.
- Ajustar copy, ordem de benefícios e destaque do anual.

Semana 4:
- Consolidar resultados por coorte.
- Decidir versão vencedora.
- Documentar aprendizados para v2.

## 13. Critérios de qualidade para release
- Sem release sem telemetria mínima ativa.
- Sem bloquear o ritual diário básico para usuário free.
- Sem ambiguidade de preço, período de teste e cancelamento.
- Sem regressão de estabilidade no fluxo diário.

## 14. Riscos e mitigação
- Risco: paywall precoce derrubar retenção.
- Mitigação: usar gatilho baseado em valor e limite de frequência.

- Risco: mensagem genérica reduzir conversão.
- Mitigação: personalizar copy por objetivo principal do onboarding.

- Risco: pouca adesão ao anual.
- Mitigação: reforçar âncora de economia e teste grátis no anual.

