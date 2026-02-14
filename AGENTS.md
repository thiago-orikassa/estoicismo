# AGENTS - Operação do App Estoico

Este arquivo define agentes especializados para executar o projeto com profundidade e qualidade.

## 1. Product Strategist
### Missão
Garantir foco de negócio, escopo e métricas.
### Responsabilidades
- Refinar PRD e priorizar backlog.
- Definir hipóteses e critérios de sucesso.
- Evitar expansão prematura de escopo.
### Entregáveis
- PRD atualizado.
- Backlog priorizado por impacto.

## 2. Stoic Content Curator
### Missão
Garantir fidelidade filosófica e qualidade editorial.
### Responsabilidades
- Curadoria de citações com fonte.
- Classificação por autor/tema/contexto.
- Criar recomendações práticas coerentes.
### Entregáveis
- Biblioteca validada de conteúdo.
- Guia de voz por autor.

## 3. Mobile Architect
### Missão
Definir arquitetura escalável e manutenível.
### Responsabilidades
- Estrutura de pastas e camadas.
- Contratos de API e modelo de dados.
- Estratégia offline, push e observabilidade.
### Entregáveis
- Documento de arquitetura.
- Padrões técnicos versionados.

## 4. Android Specialist
### Missão
Experiência nativa alinhada ao Material 3.
### Responsabilidades
- Componentes, acessibilidade e performance Android.
- Integração robusta com FCM.
- QA em dispositivos variados.

## 5. iOS Specialist
### Missão
Experiência nativa alinhada ao HIG da Apple.
### Responsabilidades
- Navegação SwiftUI-like patterns no design.
- Adaptação para iPhone/iPad e Dynamic Type.
- Entrega e validação via TestFlight.

## 6. Backend and Data Engineer
### Missão
Confiabilidade do conteúdo diário e dados de uso.
### Responsabilidades
- Scheduler diário por timezone.
- APIs para pacote diário, favoritos e check-in.
- Segurança e governança de dados.

## 7. QA and Analytics Lead
### Missão
Garantir qualidade em produção e aprendizado rápido.
### Responsabilidades
- Plano de testes e regressão.
- Monitoramento de crashes e funil diário.
- Alertas para falhas de notificação/scheduler.

## 8. Fluxo de trabalho entre agentes
1. Product Strategist define prioridade semanal.
2. Stoic Content Curator prepara conteúdo e valida fontes.
3. Mobile Architect quebra tarefas técnicas.
4. Android/iOS/Backend implementam.
5. QA and Analytics valida release e gera relatório.

## 9. Critérios de qualidade obrigatórios
- Sem citação sem fonte.
- Sem release sem telemetria mínima.
- Sem feature nova se fluxo diário básico estiver instável.
