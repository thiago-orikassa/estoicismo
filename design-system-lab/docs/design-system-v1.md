# Design System v1 - Aethor

## Objetivo
Criar um sistema de design consistente, escalável e multiplataforma (Android/iOS) para sustentar o ritual diário do app com foco em clareza, sobriedade e ação prática.

## 1. Princípios de Produto e Marca
1. Clareza primeiro: cada tela deve ter um objetivo único principal.
2. Conteúdo é o centro: UI não pode competir com citação/reflexão.
3. Consistência diária: padrões previsíveis reduzem fricção cognitiva.
4. Sobriedade emocional: sem estímulos visuais excessivos.
5. Confiabilidade editorial: sempre exibir fonte e contexto.

## 2. Arquitetura do Design System
- Foundations: tokens visuais e comportamentais.
- Components: blocos reutilizáveis (átomos/moléculas/organismos).
- Patterns: composição por fluxo (Hoje, Histórico, Favoritos, Ajustes).
- Governance: versionamento, critérios de adoção e QA visual.

## 3. Foundations (Tokens)
- `color.base.obsidian`: #111315
- `color.base.stone`: #2C3136
- `color.base.sand`: #D9D0C3
- `color.base.ivory`: #F6F2EA
- `color.accent.copper`: #B87444
- `color.accent.deepBlue`: #2F4B66
- Tipografia: Cormorant Garamond (editorial), Inter (interface)
- Espaçamento base: 4, 8, 12, 16, 20, 24, 32
- Radius: 8, 12, 16, 999

## 4. Componentes Core (v1)
- `AethorScaffold`
- `AethorSection`
- `AethorCard`
- `QuoteCard`
- `PracticeCard`
- `SourceMeta`
- `TagGroup`
- `PrimaryButton`
- `SecondaryButton`
- `TonalButton`
- `AethorTextField`
- `AethorDropdown`
- `LoadingState`
- `EmptyState`
- `ErrorState`
- `FeedbackBar`

## 5. Patterns por Fluxo
- Hoje: Citação -> Prática -> Check-in
- Histórico: lista temporal resumida
- Favoritos: lista de citações com remoção
- Ajustes: contexto, timezone e sincronização

## 6. Cross-Platform (Material 3 + HIG)
- Android: base Material 3, navegação inferior, hierarquia tonal.
- iOS: densidade de toque adequada, tipografia dinâmica, semântica nativa.
- Flutter: token set único com adaptações por plataforma.

## 7. Acessibilidade
- Contraste AA mínimo.
- Alvos de toque >= 44x44.
- Suporte a escala de fonte.
- Ordem de leitura e labels semânticos.

## 8. Governança
- Mudanças em tokens/componentes exigem changelog.
- Priorizar reutilização antes de criar novos componentes.
- QA visual obrigatório em estados de loading/vazio/erro/sucesso.
