# Componentes de Design - DS v1 (Aethor)

## Objetivo
Documentar os componentes reutilizáveis do produto para garantir consistência visual, acessibilidade e velocidade de implementação.

## Convenções
- Prefixo de componentes proprietários: `Aethor`.
- Todos os componentes devem consumir tokens de `Design Tokens` (cores, tipografia, spacing, radius).
- Estados mínimos por componente interativo: default, hover/focus (quando aplicável), pressed, disabled, loading (quando aplicável).

## 1. Layout e Estrutura

### AethorScaffold
- Finalidade: estrutura base de tela com app bar, conteúdo e tratamento de erro global.
- Base Flutter: `Scaffold` + `MaterialBanner`.
- Props sugeridas:
- `title` (String)
- `body` (Widget)
- `errorMessage` (String?)
- `onRetry` (VoidCallback?)
- Regras:
- Exibir banner apenas quando houver erro.
- Manter body com área segura e padding controlado por seção.

### AethorSection
- Finalidade: agrupar blocos de conteúdo com título e espaçamento consistente.
- Base Flutter: `Column`.
- Props sugeridas:
- `title` (String)
- `child` (Widget)
- `spacingTop` (double, default token 20)
- Regras:
- Título sempre acima do conteúdo.
- Evitar mais de um CTA primário por seção.

### AethorCard
- Finalidade: superfície semântica para leitura e ações relacionadas.
- Base Flutter: `Card` customizado.
- Props sugeridas:
- `child` (Widget)
- `padding` (EdgeInsets, default 16)
- `variant` (`default | outlined | tonal`)
- Regras:
- Elevação baixa (0-1), priorizar borda.
- Não aninhar card dentro de card.

## 2. Editorial

### QuoteCard
- Finalidade: exibir citação do dia com fonte e ação de favorito.
- Conteúdo mínimo:
- Texto da citação
- Autor
- Obra e referência
- Intenção comportamental
- Tags de contexto
- Ação de favoritar/desfavoritar
- Props sugeridas:
- `quoteText`, `author`, `sourceWork`, `sourceRef`, `behaviorIntent`
- `contextTags` (List<String>)
- `isFavorite` (bool)
- `onToggleFavorite` (VoidCallback)
- Estados:
- `default`
- `loading`
- `error` (quando dados editoriais falharem)
- Regras:
- Sem renderizar citação sem metadado de fonte.
- Ação de favorito deve ter label acessível.

### PracticeCard
- Finalidade: apresentar prática diária com instruções aplicáveis.
- Conteúdo mínimo:
- Título
- Explicação de vínculo com a citação
- Contexto e duração
- Passos numerados
- Resultado esperado
- Critério de conclusão
- Pergunta de journaling
- Props sugeridas:
- `title`, `quoteLinkExplanation`, `context`, `minutes`
- `steps` (List<String>)
- `expectedOutcome`, `completionCriteria`, `journalPrompt`
- Regras:
- Passos sempre ordenados.
- Evitar parágrafos longos; preferir blocos escaneáveis.

### SourceMeta
- Finalidade: linha compacta de metadados editoriais.
- Base Flutter: `Text` com estilo secundário.
- Props sugeridas:
- `sourceWork` (String)
- `sourceRef` (String)
- Formato:
- `{sourceWork} • {sourceRef}`

### TagGroup
- Finalidade: exibir contextos relacionados em chips.
- Base Flutter: `Wrap` + `Chip`.
- Props sugeridas:
- `tags` (List<String>)
- `maxVisible` (int?)
- Regras:
- Espaçamento horizontal 8 e vertical 8.
- Se houver overflow, agrupar em `+N` (v2).

## 3. Inputs e Ações

### AethorTextField
- Finalidade: entrada de texto para check-in e notas.
- Base Flutter: `TextField`.
- Props sugeridas:
- `controller` (TextEditingController)
- `hintText` (String)
- `minLines` (int)
- `maxLines` (int)
- `onChanged` (ValueChanged<String>?)
- Estados:
- default, focused, disabled, error
- Regras:
- Suporte a Dynamic Type sem clipping.
- Borda e foco com contraste AA.

### AethorDropdown
- Finalidade: seleção de contexto preferencial.
- Base Flutter: `DropdownButtonFormField<T>`.
- Props sugeridas:
- `value` (T)
- `items` (List<DropdownMenuItem<T>>)
- `labelText` (String)
- `onChanged` (ValueChanged<T?>)
- Regras:
- Label sempre visível.
- Alvos de toque >= 44x44.

### PrimaryButton
- Finalidade: CTA principal da tela/bloco.
- Base Flutter: `FilledButton`.
- Uso atual recomendado:
- `Apliquei hoje`

### SecondaryButton
- Finalidade: ação alternativa ao CTA principal.
- Base Flutter: `OutlinedButton`.
- Uso atual recomendado:
- `Não apliquei`

### TonalButton
- Finalidade: ação auxiliar de baixo destaque.
- Base Flutter: `FilledButton.tonal`.
- Uso atual recomendado:
- `Sincronizar agora`

### IconActionButton
- Finalidade: ações compactas com ícone (ex.: remover favorito).
- Base Flutter: `IconButton`.
- Regras:
- Sempre possuir `tooltip` e semântica.

## 4. Estados de Tela

### LoadingState
- Finalidade: indicar carregamento de seção ou tela.
- Base Flutter: `CircularProgressIndicator` + texto opcional.
- Texto padrão:
- `Carregando conteúdo...`

### EmptyState
- Finalidade: comunicar ausência de dados e orientar próxima ação.
- Base Flutter: `Column` centralizada.
- Props sugeridas:
- `title` (String)
- `description` (String?)
- `actionLabel` (String?)
- `onAction` (VoidCallback?)
- Casos atuais:
- Favoritos vazios
- Histórico vazio

### ErrorState
- Finalidade: exibir falha com caminho de recuperação.
- Base Flutter: `Card`/`Banner` + ação de retry.
- Props sugeridas:
- `message` (String)
- `onRetry` (VoidCallback)

### FeedbackBar
- Finalidade: confirmações rápidas de ações.
- Base Flutter: `SnackBar`.
- Mensagens atuais:
- `Check-in registrado.`

## 5. Navegação

### AethorBottomNav
- Finalidade: navegação principal entre áreas do app.
- Base Flutter: `NavigationBar`.
- Destinos v1:
- Hoje
- Histórico
- Favoritos
- Ajustes
- Regras:
- Máximo recomendado de 5 destinos.
- Ícones semanticamente claros.

## 6. Mapeamento Inicial para o Código Atual
- `/Users/thiagoorikassa/Documents/Estoicismo/app/lib/main.dart`
- Extrair `AethorScaffold` e `AethorBottomNav`.
- `/Users/thiagoorikassa/Documents/Estoicismo/app/lib/features/daily_quote/presentation/home_screen.dart`
- Extrair `QuoteCard`, `PracticeCard`, `AethorSection`, `AethorTextField`, `PrimaryButton`, `SecondaryButton`.
- `/Users/thiagoorikassa/Documents/Estoicismo/app/lib/features/settings/presentation/settings_screen.dart`
- Extrair `AethorDropdown` e `TonalButton`.
- `/Users/thiagoorikassa/Documents/Estoicismo/app/lib/features/favorites/presentation/favorites_screen.dart`
- Aplicar `EmptyState` e `IconActionButton` com semântica.
- `/Users/thiagoorikassa/Documents/Estoicismo/app/lib/features/history/presentation/history_screen.dart`
- Aplicar `EmptyState` e padronização de `AethorCard`.

## 7. Critérios de Qualidade
- Componente novo só entra se não houver equivalente reutilizável.
- Todo componente interativo deve ter estado disabled e foco.
- Toda ação crítica deve ter feedback visível.
- Toda citação exibida deve incluir fonte.
- Checklist de acessibilidade é obrigatório antes de release.

## 8. Roadmap de Evolução
- v1.1: componente de detalhe do item de histórico.
- v1.1: `QuoteListItem` para favoritos com texto completo.
- v1.2: variantes adaptativas para tablet e iPad.
- v1.1: ~~biblioteca de ícones semânticos oficial do produto~~ **IMPLEMENTADO** — Phosphor Icons via `AethorIcons` (tokens/aethor_icons.dart).
