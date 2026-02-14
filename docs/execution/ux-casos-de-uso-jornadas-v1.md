# UX - Casos de Uso e Jornadas v1

Data: 2026-02-14  
Owner: Product Strategist + Mobile Architect  
Suporte: Android Specialist, iOS Specialist, QA and Analytics Lead

Baseado em:
- `/Users/thiagoorikassa/Documents/Estoicismo/docs/PRD.md`
- `/Users/thiagoorikassa/Documents/Estoicismo/docs/execution/mvp-escopo-v1.md`
- `/Users/thiagoorikassa/Documents/Estoicismo/docs/execution/contexto-paywall-v1.md`
- `/Users/thiagoorikassa/Documents/Estoicismo/docs/execution/ux-experiencia-free-vs-pro-v1.md`

## 1. Casos de uso prioritarios

| ID | Caso de uso | Valor para usuario | Free/Pro | KPI principal |
|---|---|---|---|---|
| UC-01 | Completar onboarding em menos de 2 min | Entender perfil e entregar conteudo relevante | Free | onboarding_completed rate |
| UC-02 | Consumir pacote diario em menos de 30s | Valor rapido no momento de uso | Free | daily_package_viewed, time_to_value |
| UC-03 | Fazer check-in diario sem friccao | Criar habito e progressao | Free | checkin_submitted rate |
| UC-04 | Favoritar citacoes para revisitar | Consolidar valor da primeira semana | Free com limite / Pro ilimitado | quote_favorited rate |
| UC-05 | Consultar historico da pratica | Continuar reflexao com contexto | Free 30 dias / Pro completo | history_view depth |
| UC-06 | Iniciar trilha guiada por objetivo | Resolver dor concreta (ansiedade, foco, disciplina) | Pro | premium_feature_blocked -> trial_started |
| UC-07 | Ouvir audio-reflexao | Aplicar em contexto de baixa atencao | Pro | audio_start rate |
| UC-08 | Iniciar teste gratis e assinar | Converter sem atrito e sem duvida | Pro | trial_started, subscription_activated |
| UC-09 | Usar app offline | Garantir confiabilidade do ritual diario | Free e Pro | offline_daily_package_success |
| UC-10 | Restaurar compra em novo dispositivo | Confianca e continuidade da conta | Pro | restore_purchase_success |

## 2. Jornadas recomendadas (best practices)

## J-01: Primeira sessao (ativacao)
Objetivo:
- Levar usuario do install ate o primeiro check-in no mesmo dia.

Fluxo:
1. Splash curta com proposta de valor ("1 insight + 1 acao hoje").
2. Onboarding em 3 passos maximos:
   - objetivo principal (ansiedade, foco, disciplina),
   - autor preferido (ou misto),
   - horario da notificacao.
3. Entrar direto na Home diaria.
4. Expor uma unica CTA primaria: "Aplicar hoje".
5. Fechar com check-in simples (sim/nao + nota opcional).

Boas praticas:
- Nao pedir permissao de push na primeira tela; pedir apos primeiro valor percebido.
- Manter o onboarding com progresso visivel e linguagem curta.
- Evitar escolhas demais antes do primeiro valor.

Eventos:
- `onboarding_completed`
- `daily_package_viewed`
- `checkin_submitted`

## J-02: Loop diario recorrente (free core loop)
Objetivo:
- Sustentar D1/D7 por consistencia, nao por complexidade.

Fluxo:
1. Push diario no horario do usuario.
2. Deeplink abre Home diaria no bloco de conteudo.
3. Usuario le citacao + interpretacao + acao.
4. Usuario executa micro-acao e marca check-in.
5. Usuario opcionalmente favorita e sai.

Boas praticas:
- Sempre 1 acao por dia, sem sobrecarga cognitiva.
- Persistir estado parcial para nao perder progresso ao alternar app.
- Exibir reforco de continuidade apos check-in ("voce concluiu o dia").

Eventos:
- `push_received`
- `push_opened`
- `daily_package_viewed`
- `checkin_submitted`
- `quote_favorited`

## J-03: Intent paywall (ao tocar em feature premium)
Objetivo:
- Monetizar no momento de intencao real, sem punir o fluxo diario.

Fluxo:
1. Usuario toca em trilha premium, historico completo ou audio completo.
2. Tela de bloqueio contextual explica o valor especifico.
3. CTA primaria abre paywall.
4. CTA secundaria retorna ao fluxo free sem friccao.

Boas praticas:
- Mostrar claramente o que esta bloqueado e o que continua gratis.
- Incluir preview curto para reduzir sensacao de bloqueio abrupto.
- Garantir acao de fechar/voltar visivel.

Eventos:
- `premium_feature_blocked`
- `paywall_viewed`
- `paywall_cta_clicked`
- `paywall_dismissed`

## J-04: Value paywall (apos valor comprovado)
Objetivo:
- Converter apos evidencia de engajamento (3 check-ins ou 3o dia ativo).

Fluxo:
1. Usuario conclui check-in.
2. App mostra intersticial leve com progresso pessoal.
3. Usuario escolhe iniciar teste gratis ou continuar free.
4. Se recusar, aplica cooldown de 48h.

Boas praticas:
- Nunca interromper antes do consumo do pacote diario.
- Maximo 1 exposicao de paywall por dia.
- Mensagem baseada no objetivo do onboarding.

Eventos:
- `paywall_viewed` (trigger A/B)
- `trial_started`
- `paywall_dismissed`

## J-05: Limite de favoritos (free -> pro sem friccao)
Objetivo:
- Converter usuarios de alto valor sem frustracao.

Fluxo:
1. Usuario tenta favoritar acima do limite free.
2. App mostra modal com 3 opcoes:
   - assinar Pro (favoritos ilimitados),
   - gerenciar favoritos existentes,
   - cancelar.
3. Se cancelar, manter acao principal da sessao disponivel.

Boas praticas:
- Nao bloquear check-in por limite de favoritos.
- Dar alternativa util imediata (gerenciar lista).
- Reforcar beneficio objetivo (nao usar copia agressiva).

Eventos:
- `premium_feature_blocked` (contexto: favorites_limit)
- `paywall_viewed`
- `paywall_cta_clicked`

## J-06: Jornada de trial para assinatura
Objetivo:
- Reduzir abandono entre interesse e ativacao.

Fluxo:
1. Paywall abre com anual pre-selecionado e economia explicita.
2. Usuario confirma na loja (Google Play / App Store).
3. Tela de sucesso mostra o que foi desbloqueado.
4. Usuario e levado direto para a feature premium que motivou a compra.

Boas praticas:
- Exibir preco por periodo sem ambiguidade.
- Exibir regra de teste gratis e cancelamento com linguagem clara.
- Sucesso deve ter next step concreto ("Iniciar trilha agora").

Eventos:
- `trial_started`
- `subscription_activated`

## J-07: Jornada de restaurar compra
Objetivo:
- Evitar perda de acesso em reinstalacao/troca de dispositivo.

Fluxo:
1. Usuario aciona "Restaurar compra" no paywall ou ajustes.
2. App valida entitlement com store + backend.
3. App confirma restauracao e atualiza UI imediatamente.

Boas praticas:
- Botao sempre visivel no paywall.
- Mensagens de erro acionaveis ("tente novamente", "contatar suporte").
- Nao esconder estado atual da assinatura.

Eventos:
- `restore_purchase_started`
- `restore_purchase_success`
- `restore_purchase_failed`

## 3. Melhores praticas cross-platform (Android + iOS)

Padroes comuns:
- Touch targets minimos de 48dp/44pt.
- Tipografia sem tamanho fixo (suporte a Dynamic Type / font scaling).
- Contraste e hierarquia visual clara para leitura de texto longo.
- Estados de loading, vazio, erro e offline para todas as telas chave.
- Gestos nativos preservados (back swipe iOS, back system Android).

Android (Material 3):
- Usar componentes Material 3 e hierarchy de emphasis correta.
- Bottom navigation para Home/Historico/Favoritos/Ajustes.
- Feedback de acao com snackbar curto e claro.

iOS (HIG):
- Navegacao com titulo claro e comportamento nativo de retorno.
- SF Symbols e semantica de cor nativa.
- Respeito a safe areas e comportamento de sheet/modal do sistema.

## 4. Estados e edge cases obrigatorios

- Sem internet ao abrir app:
  - carregar cache local dos ultimos 7 dias,
  - sinalizar modo offline sem bloquear leitura/check-in.

- Conteudo invalido:
  - se citacao sem fonte, nao publicar no pacote diario.

- Falha de assinatura:
  - manter experiencia free funcional,
  - registrar erro tecnico sem quebrar UI.

- Excesso de exposicao de paywall:
  - garantir regra de frequencia por usuario no app e backend.

## 5. Gaps para fechar antes do plano de execucao

- Definir limite final de favoritos free (20 confirmado ou ajuste).
- Definir se historico free fica em 30 dias fixos ou janela dinamica.
- Definir quais insights entram no free basico vs pro avancado.
- Definir eventos faltantes no contrato analytics atual:
  - `paywall_viewed`
  - `paywall_dismissed`
  - `paywall_cta_clicked`
  - `trial_started`
  - `subscription_activated`
  - `premium_feature_blocked`

## 6. Resultado esperado desta fase

Com estes casos de uso e jornadas:
- o time tem clareza do que e valor core (free),
- o time tem clareza de onde monetizar (pro),
- o proximo passo natural e quebrar execucao por sprint com criterio de aceite por jornada.
