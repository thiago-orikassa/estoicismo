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

### 3.1 Cores (base marca)
- `color.base.obsidian`: #111315
- `color.base.stone`: #2C3136
- `color.base.sand`: #D9D0C3
- `color.base.ivory`: #F6F2EA
- `color.accent.copper`: #B87444
- `color.accent.deepBlue`: #2F4B66

### 3.2 Cores semânticas (UI)
- `color.bg.canvas`: #F6F2EA
- `color.bg.surface`: #FFFFFF
- `color.text.primary`: #111315
- `color.text.secondary`: #4A5057
- `color.text.inverse`: #FFFFFF
- `color.border.default`: #D9D0C3
- `color.state.success`: #2E7D32
- `color.state.warning`: #B26A00
- `color.state.error`: #B3261E
- `color.state.info`: #2F4B66

### 3.3 Tipografia
- Família editorial (citações): Cormorant Garamond.
- Família de interface: Inter.
- Escala:
- `display`: 34/40 semibold
- `titleL`: 28/34 semibold
- `titleM`: 22/28 semibold
- `titleS`: 18/24 medium
- `bodyL`: 16/24 regular
- `bodyM`: 14/20 regular
- `label`: 12/16 medium

### 3.4 Espaçamento e layout
- Grid base: 4pt.
- Escala: 4, 8, 12, 16, 20, 24, 32.
- Padding padrão de tela: 16.
- Gap padrão entre blocos principais: 20.
- Largura máxima de leitura (tablet): 720.

### 3.5 Radius, borda e elevação
- `radius.sm`: 8
- `radius.md`: 12
- `radius.lg`: 16
- `radius.pill`: 999
- Elevação padrão cards: 0 ou 1 (preferir borda discreta).
- Borda padrão: 1px `color.border.default`.

### 3.6 Motion
- Curta e funcional, sem ornamentação.
- Duração:
- micro: 120ms
- padrão: 200ms
- entrada de tela: 260ms
- Curva: ease-out para entrada, ease-in-out para transições.

### 3.7 Iconografia
- Biblioteca primária cross-platform: **Phosphor Icons** (pacote `phosphor_flutter`).
- Peso padrão: **Light** (1.5px stroke) — intelectual e contido, legível e grounded.
- Variantes por contexto:
  - **Light (outline)**: navegação inativa, toolbar, metadata, settings.
  - **Duotone**: navegação ativa, estados de completude (Copper + Obsidian).
  - **Bold/Fill**: CTAs, alertas críticos.
  - **Thin**: metadata densa em cards.
- Suplementar por plataforma:
  - Android: Material Symbols Sharp (pickers de sistema, notificações nativas).
  - iOS: SF Symbols (equivalentes semânticos via adaptadores de plataforma).
- Tokens centralizados em `AethorIcons` (`app/lib/core/design_system/tokens/aethor_icons.dart`).
- Escala de tamanhos:
  - `icon.size.xs`: 16px (inline com label 12/16)
  - `icon.size.sm`: 20px (inline com bodyM 14/20)
  - `icon.size.md`: 24px (primário: UI, navegação)
  - `icon.size.lg`: 28px (headers de seção)
  - `icon.size.xl`: 32px (empty states, onboarding)
- Touch target: visual 24px, área interativa mínima 48dp (Material) / 44pt (Apple).
- Regra de alinhamento: altura do ícone iguala line-height do texto adjacente.

## 4. Componentes Core (v1)

### 4.1 Estruturais
- `AethorScaffold`: scaffold com tratamento de banner de erro.
- `AethorSection`: seção com título + conteúdo + espaçamento padrão.
- `AethorCard`: card semântico para blocos de leitura.

### 4.2 Conteúdo editorial
- `QuoteCard`: citação, autor, obra, referência, tags e ação de favorito.
- `PracticeCard`: título, racional, passos, duração, resultado esperado.
- `SourceMeta`: linha de metadados editoriais (obra/referência).
- `TagGroup`: conjunto de chips de contexto.

### 4.3 Interação
- `PrimaryButton`: CTA principal (ex.: Apliquei hoje).
- `SecondaryButton`: ação secundária (ex.: Não apliquei).
- `TonalButton`: ação auxiliar (ex.: Sincronizar agora).
- `AethorTextField`: campo de nota/check-in.
- `AethorDropdown`: seleção de contexto.

### 4.4 Estado
- `LoadingState`: indicador central + mensagem opcional.
- `EmptyState`: ilustração opcional + texto + ação.
- `ErrorState`: mensagem clara + retry.
- `FeedbackBar`: snackbar/banner padronizado.

## 5. Patterns por Fluxo

### 5.1 Hoje (principal)
Ordem fixa:
1. Citação do dia
2. Prática do dia
3. Check-in

Regras:
- Máximo de 1 CTA primário por bloco.
- Exibir fonte da citação antes de ações.
- Manter comprimento de leitura escaneável.

### 5.2 Histórico
- Lista temporal com item resumido.
- CTA para abrir detalhe do dia (futuro v2).

### 5.3 Favoritos
- Lista de citações favoritas (hoje mostra IDs; v2 deve mostrar texto e fonte).
- Ação de remover sem ruído.

### 5.4 Ajustes
- Preferências de contexto, timezone e sincronização.
- Controles com labels claros e baixo esforço cognitivo.

## 6. Cross-Platform (Material 3 + HIG)

### Android
- Base em Material 3, `NavigationBar` para 3-5 destinos.
- Top app bar simples, sem sobrecarga visual.
- Uso de tonalidade para hierarquia de botões.

### iOS
- Respeitar densidade de toque e tipografia dinâmica.
- Ícones semanticamente equivalentes em SF Symbols.
- Feedbacks discretos e legíveis (banner/snackbar equivalente).

### Decisão para Flutter
- Um token set único com variações de comportamento por plataforma.
- Componentes com API única e adaptação interna quando necessário.

## 7. Acessibilidade (mínimo obrigatório)
- Contraste mínimo AA para textos e CTAs.
- Tamanho de toque mínimo: 44x44pt.
- Suporte a escala de fonte sem quebrar hierarquia.
- Labels semânticos para botões de ação (favoritar/check-in).
- Ordem de leitura lógica para leitores de tela.

## 8. Governança e versionamento
- Nome da versão: `DS v1.0`.
- Mudanças em tokens/componentes exigem changelog.
- Toda nova tela deve reutilizar componentes existentes antes de criar novos.
- QA visual obrigatório para estados: loading, vazio, erro e sucesso.

## 9. Plano de implementação no app Flutter

### Fase 1 (rápida)
1. Criar camada de tokens em `app/lib/core/design_system/tokens/`.
2. Refatorar `AppTheme` para consumir tokens.
3. Padronizar botões, campos e cards nas telas existentes.

### Fase 2
1. Extrair `QuoteCard`, `PracticeCard` e `AethorSection`.
2. Criar biblioteca de estados (`LoadingState`, `EmptyState`, `ErrorState`).
3. Ajustar favoritos para exibir conteúdo editorial em vez de IDs.

### Fase 3
1. Auditar acessibilidade e contraste.
2. Definir snapshot visual básico dos componentes principais.
3. Publicar changelog `DS v1.1` com melhorias.

## 10. Métricas de qualidade do Design System
- % de telas usando componentes oficiais.
- Redução de variação visual não intencional.
- Tempo para montar uma nova tela de conteúdo.
- Taxa de retrabalho de UI por inconsistência.
