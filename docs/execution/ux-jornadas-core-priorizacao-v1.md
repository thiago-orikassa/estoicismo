# UX - Jornadas Core e Priorizacao v1

Data: 2026-02-14  
Owner: Product Strategist + Mobile Architect  
Suporte: Android Specialist, iOS Specialist, Backend and Data Engineer, QA and Analytics Lead

Baseado em:
- `/Users/thiagoorikassa/Documents/Estoicismo/docs/PRD.md`
- `/Users/thiagoorikassa/Documents/Estoicismo/docs/execution/mvp-escopo-v1.md`
- `/Users/thiagoorikassa/Documents/Estoicismo/docs/execution/priorizacao-impacto-risco-v1.md`
- `/Users/thiagoorikassa/Documents/Estoicismo/docs/execution/contexto-paywall-v1.md`
- `/Users/thiagoorikassa/Documents/Estoicismo/docs/execution/ux-casos-de-uso-jornadas-v1.md`
- `/Users/thiagoorikassa/Documents/Estoicismo/docs/branding/contexto-diretrizes-branding.md`

## 1. Objetivo deste arquivo

Listar as jornadas core do app em ordem de prioridade de UX para orientar roadmap, sprint planning e criterio de release.

Regra macro:
- Sem estabilidade do fluxo diario, nao priorizar expansao de monetizacao/feature.

## 2. Criterios de priorizacao (UX best practices)

Cada jornada foi classificada por:
- Impacto em valor percebido no primeiro uso.
- Impacto em retencao (D1, D7) e consistencia diaria.
- Risco de friccao/cancelamento se mal implementada.
- Dependencia tecnica do MVP (scheduler, push, offline, analytics).

Escala:
- P0 = critico para valor principal e retencao.
- P1 = alto impacto apos estabilidade do core.
- P2 = otimiza crescimento/receita, mas nao bloqueia valor base.

## 3. Mapa de jornadas core priorizadas

| Prioridade | ID | Jornada | Objetivo UX | KPI primario | Dependencias |
|---|---|---|---|---|---|
| P0 | J-01 | Primeira sessao e ativacao | Levar do primeiro open ao primeiro check-in no mesmo dia | `onboarding_completed`, `checkin_submitted` D0 | Onboarding simples, home diaria, check-in |
| P0 | J-02 | Loop diario recorrente | Sustentar habito com baixo esforco cognitivo | `daily_package_viewed`, `checkin_submitted`, D1/D7 | Scheduler, push, deeplink, daily package |
| P0 | J-03 | Confiabilidade offline e recuperacao | Garantir continuidade mesmo sem rede | taxa de sucesso offline, erros de carga | Cache 7 dias, estados loading/erro/offline |
| P0 | J-04 | Favoritar e revisitar valor | Reforcar utilidade na primeira semana | `quote_favorited`, first-week value | API favoritos, lista de favoritos usavel |
| P1 | J-05 | Historico de progresso pessoal | Dar continuidade e reflexao ao usuario recorrente | depth de historico, retorno semanal | API historico, UX de timeline clara |
| P1 | J-06 | Permissao de notificacao no momento certo | Maximizar opt-in sem interromper valor inicial | push opt-in rate, push opened | Pre-prompt, fluxo push Android/iOS |
| P1 | J-07 | Intent paywall em feature premium | Monetizar em intencao real sem quebrar free | `premium_feature_blocked`, `trial_started` | Flags de paywall, entitlement |
| P1 | J-08 | Value paywall apos valor comprovado | Converter com base em evidencia de engajamento | `paywall_viewed` -> `trial_started` | Regra 3 check-ins/3o dia ativo |
| P1 | J-09 | Trial, assinatura e restaurar compra | Reduzir atrito de pagamento e suporte | `subscription_activated`, restore success | Integracao stores, backend assinatura |

## 4. Blueprint resumido por jornada

## J-01 (P0) - Primeira sessao e ativacao
Fluxo ideal:
1. Boas-vindas curta e clara.
2. Onboarding em ate 3 passos (objetivo, autor, horario).
3. Entrada imediata na Home do dia.
4. Primeiro check-in com feedback claro de conclusao.

Boas praticas UX:
- 1 decisao principal por tela.
- Sem pedir push antes de entregar valor.
- Sem paywall na primeira sessao.

## J-02 (P0) - Loop diario recorrente
Fluxo ideal:
1. Push no horario configurado.
2. Deeplink abre conteudo do dia.
3. Leitura rapida da citacao + acao pratica.
4. Check-in em poucos toques.

Boas praticas UX:
- Tempo para valor < 30s.
- Um unico proximo passo claro.
- Reforco de continuidade apos check-in.

## J-03 (P0) - Offline e recuperacao
Fluxo ideal:
1. Sem rede -> app abre com cache local.
2. Usuario consegue ler pacote e registrar acao localmente.
3. Sincronizacao quando rede voltar.

Boas praticas UX:
- Nunca tela vazia sem explicacao.
- Mensagem acionavel: "Modo offline ativo".
- Preservar progresso parcial.

## J-04 (P0) - Favoritos e revisita
Fluxo ideal:
1. Favoritar com 1 toque na citacao.
2. Ver lista de favoritos legivel e escaneavel.
3. Revisitar facilmente.

Boas praticas UX:
- Feedback imediato de salvar/remover.
- Evitar listar apenas IDs; mostrar conteudo humano.
- Nao interromper fluxo diario por acao secundaria.

## J-05 (P1) - Historico
Fluxo ideal:
1. Timeline dos dias anteriores.
2. Resumo claro do dia e status de check-in.
3. Acesso rapido ao detalhe (quando existir).

Boas praticas UX:
- Ordem temporal previsivel.
- Escaneabilidade (data, autor, insight principal).
- Empty state orientando retorno ao ritual.

## J-06 (P1) - Permissao de push
Fluxo ideal:
1. Pre-prompt contextual apos primeiro valor percebido.
2. Prompt nativo.
3. Se negar, caminho de reativacao em Ajustes.

Boas praticas UX:
- Justificar beneficio antes da permissao.
- Nao bloquear uso se negar.
- Re-prompt apenas em momentos de valor.

## J-07/J-08/J-09 (P1) - Monetizacao
Fluxo ideal:
1. Trigger por intencao real ou valor comprovado.
2. Paywall com proposta objetiva e transparencia de preco.
3. Trial/assinatura com retorno direto para a feature desejada.
4. Restaurar compra sempre visivel.

Boas praticas UX:
- Maximo 1 exposicao de paywall por dia.
- Cooldown de 48h apos recusa explicita.
- Sempre manter o ritual diario funcional para free.

## 5. Ordem recomendada de execucao (proximas sprints)

Sprint A (P0):
- J-01 ativacao.
- J-02 loop diario.
- J-03 offline.
- J-04 favoritos.

Sprint B (P1):
- J-05 historico.
- J-06 permissao de push no timing correto.
- J-07 intent paywall.
- J-08 value paywall.
- J-09 trial, assinatura e restaurar compra.

Sprint C (P2):
- Otimizacoes de conversao e reducao de friccao (copy, variantes e refinamento de gatilhos).

## 6. Gates de qualidade por prioridade

Para fechar P0:
- Fluxo diario sem falha critica por 7 dias simulados.
- Eventos minimos de funil ativos no app + backend.
- Tempo de consumo inicial dentro da meta de UX.

Para liberar P1:
- D1 e D7 sem regressao relevante apos ajustes de onboarding e loop.

Para liberar monetizacao do MVP (P1):
- Guardrails de retencao ativos.
- Copy de monetizacao clara e sem ambiguidade.
- Regra de frequencia de paywall validada.

## 7. Decisoes para priorizacao imediata

- Priorizar backlog por jornada (nao por tela isolada).
- Toda task nova deve declarar a jornada impactada.
- Monetizacao entra no MVP somente apos concluir gates de P0 e validar guardrails de impacto em retencao/check-in.

## 8. Resultado esperado

Com esta priorizacao:
- o time protege o valor central do app (ritual diario),
- reduz risco de retrabalho em UX,
- cria base solida para monetizacao sem sacrificar retencao.
