# Componentes de Design - DS v1 (Estoicismo)

## Objetivo
Documentar os componentes reutilizáveis do produto para garantir consistência visual, acessibilidade e velocidade de implementação.

## 1. Layout e Estrutura
- `StoicScaffold`: estrutura base com tratamento de erro.
- `StoicSection`: agrupamento com título e spacing padrão.
- `StoicCard`: superfície semântica para leitura e ações.

## 2. Editorial
- `QuoteCard`: citação, fonte, tags e favorito.
- `PracticeCard`: prática diária com passos e critérios.
- `SourceMeta`: obra + referência.
- `TagGroup`: chips de contexto.

## 3. Inputs e Ações
- `StoicTextField`
- `StoicDropdown`
- `PrimaryButton`
- `SecondaryButton`
- `TonalButton`
- `IconActionButton`

## 4. Estados de Tela
- `LoadingState`
- `EmptyState`
- `ErrorState`
- `FeedbackBar`

## 5. Navegação
- `StoicBottomNav`: Hoje, Histórico, Favoritos, Ajustes.

## 6. Regras
- Todo componente interativo deve ter estados mínimo default/focus/disabled.
- Toda ação crítica deve ter feedback visual.
- Toda citação exibida deve conter fonte.
