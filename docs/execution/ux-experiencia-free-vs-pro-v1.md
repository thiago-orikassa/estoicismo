# Plano UX - Experiencia Free vs Pro v1

Data: 2026-02-14  
Owner: Product Strategist + Mobile Architect  
Suporte: Stoic Content Curator, Backend and Data Engineer, QA and Analytics Lead

## 1. Contexto e decisao de produto

Baseado em:
- `/Users/thiagoorikassa/Documents/Estoicismo/docs/PRD.md`
- `/Users/thiagoorikassa/Documents/Estoicismo/docs/execution/mvp-escopo-v1.md`
- `/Users/thiagoorikassa/Documents/Estoicismo/docs/execution/contexto-paywall-v1.md`
- `/Users/thiagoorikassa/Documents/Estoicismo/docs/execution/status-execucao-2026-02-14.md`

Diretriz central:
- O ritual diario (pacote do dia + check-in) e o motor de retencao.
- Monetizacao nao pode quebrar o valor principal do usuario free.

## 2. Principios UX obrigatorios

- Sem bloquear a primeira experiencia.
- Sem interromper o consumo do conteudo diario antes da acao de valor.
- Preco, teste e cancelamento sempre explicitos.
- Free precisa resolver o caso de uso basico com qualidade.
- Pro precisa entregar "profundidade e continuidade", nao apenas remover bloqueio.

## 3. Estrategia em 2 fases (alinhada ao escopo atual)

### Fase A - Beta de produto (agora)
- Assinatura permanece desativada por padrao, respeitando MVP congelado.
- Coletar baseline real de D1, D7, check-in e push.
- Preparar feature flags de monetizacao sem exposicao ampla.

### Fase B - Monetizacao controlada
- Ativar paywall v1 somente apos:
  - fluxo diario estavel,
  - telemetria ponta a ponta ativa,
  - catalogo editorial com fonte validada.
- Iniciar com rollout gradual para usuarios elegiveis.

## 4. Definicao da experiencia Free (valor principal)

O usuario free recebe valor diario completo e recorrente:
- Onboarding simples (autor, horario, temas).
- Pacote diario completo (citacao com fonte + interpretacao + acao + journaling).
- Check-in diario sem friccao.
- Notificacao diaria configuravel.
- Cache offline de 7 dias.

Limites free (sem quebrar o ritual):
- Favoritos: ate 20 itens salvos.
- Historico: ultimos 30 dias.
- Insights: visao basica (dias com check-in e taxa semanal simples).
- Trilhas guiadas: teaser + 1 intro liberada, restante bloqueado.
- Audio-reflexoes: preview curto, episodio completo bloqueado.

## 5. Definicao da experiencia Pro (profundidade)

Usuario Pro desbloqueia progresso continuo:
- Favoritos ilimitados.
- Historico completo da jornada.
- Trilhas guiadas completas por objetivo (ansiedade, foco, disciplina).
- Audio-reflexoes completas.
- Insights avancados (padrao por tema, autor e consistencia semanal).
- Lembretes inteligentes por contexto e comportamento.

Planos e oferta:
- Mensal: R$ 19,90.
- Anual: R$ 149,00 com 7 dias gratis.
- Anual pre-selecionado como opcao de melhor custo-beneficio.

## 6. Jornada UX proposta (free -> pro)

### Etapa 1 - Descoberta de valor (dias 0-2)
- Nenhum paywall na primeira sessao.
- Usuario consome conteudo e registra primeiros check-ins.
- Home mostra micro-beneficios de Pro em formato nao intrusivo.

### Etapa 2 - Momento de valor comprovado (dia 3 ou 3o check-in)
- Exibir paywall apos acao concluida (nunca antes do pacote diario).
- Header contextual: progresso real do usuario ("Voce manteve sua pratica por 3 dias").

### Etapa 3 - Intencao explicita
- Ao tentar trilha premium, historico completo ou audio completo:
  - mostrar bloqueio elegante,
  - explicar valor especifico desbloqueado,
  - abrir paywall com plano anual destacado.

### Etapa 4 - Pos-recusa
- Se usuario tocar em "Continuar no gratuito", aplicar cooldown de 48h.
- Maximo 1 exposicao por dia.
- Reforcar valor free no retorno, sem punicao de UX.

## 7. Arquitetura de paywall (tela unica v1)

Composicao:
- Bloco de contexto pessoal (objetivo escolhido no onboarding).
- 3 beneficios principais de Pro.
- Comparativo simples Free x Pro.
- Seletor de plano (mensal/anual) com economia anual explicita.
- CTA primario: "Iniciar 7 dias gratis".
- CTA secundario: "Continuar no gratuito".
- Link "Restaurar compra".
- Microcopy legal: cancelamento e renovacao automatica.

Regras de UX:
- Fechar tela deve ser obvio.
- Nao ocultar preco por periodo.
- Sem dark pattern em close, scroll e selecao de plano.

## 8. Mapa de gatilhos e frequencia

Gatilhos ativos:
- A: apos 3 check-ins concluidos.
- B: no 3o dia ativo.
- C: tentativa de abrir funcionalidade premium.

Regras:
- max 1/dia por usuario,
- cooldown de 48h apos recusa explicita,
- sem exibicao para usuario no primeiro dia de uso.

## 9. Analytics e decisao

Eventos essenciais de monetizacao:
- `paywall_viewed`
- `paywall_dismissed`
- `paywall_cta_clicked`
- `trial_started`
- `subscription_activated`
- `subscription_renewed`
- `subscription_canceled`
- `premium_feature_blocked`

Propriedades minimas:
- `user_id`
- `date_local`
- `timezone`
- `event_version`
- `paywall_variant`
- `trigger_type`
- `plan_selected`
- `price_displayed`
- `trial_eligible`

KPIs de validacao:
- Trial start rate > 8%.
- Trial -> paid > 35%.
- Retencao D7 sem queda relevante.
- Check-in rate pos-paywall sem queda > 8% relativo.

## 10. A/B inicial e hipoteses

Variacoes:
- A: narrativa de progresso e consistencia.
- B: narrativa de alivio de ansiedade e clareza.

Hipotese:
- B tende a converter melhor em usuarios com contexto inicial "ansiedade".
- A tende a preservar melhor check-in em usuarios orientados a disciplina.

Decisao:
- Pausar variacao se D7 cair > 10% relativo ao baseline.
- Consolidar vencedora em 14 dias por coorte semanal.

## 11. Riscos UX e mitigacoes

- Risco: paywall cedo demais derruba retencao.
- Mitigacao: gatilho de valor e cooldown.

- Risco: sensacao de app "capado" no free.
- Mitigacao: valor diario completo sempre livre.

- Risco: copy generica e baixa conversao.
- Mitigacao: personalizar titulo/subtitulo por objetivo do onboarding.

## 12. Backlog de implementacao (enxuto)

- PS: fechar limites numericos finais (favoritos e janela historico).
- MA: criar feature flags para gatilhos, variante e cooldown.
- Mobile: implementar paywall + estados bloqueados em trilhas/audio/historico.
- Backend: expor entitlement de assinatura e elegibilidade de trial.
- QA/Analytics: validar funil completo e dashboards por coorte.

## 13. Criterio de pronto

So publicar paywall v1 quando:
- telemetria de monetizacao estiver validada em staging,
- experiencia free mantiver ritual diario sem bloqueio,
- termos de preco/teste/cancelamento estiverem claros nas duas plataformas,
- monitoramento de D1/D7/check-in estiver ativo desde o dia 0 do rollout.
