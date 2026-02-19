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

## 10. Padrão obrigatório de português em dados e conteúdo
Todo texto voltado ao usuário (títulos, passos, prompts, labels) deve respeitar a ortografia e acentuação do português brasileiro. Esta regra se aplica a arquivos de seed (`daily_seed.json`), CSVs de conteúdo (`recommendations_40.csv`, `quotes_catalog_90.csv`), strings no código Dart e qualquer outro artefato exibido na UI.

### Checklist de acentuação (erros recorrentes)
| Errado | Correto |
|---|---|
| -acao, -cao | -ação, -ção (procrastinação, conclusão, atenção, decisão, interpretação, motivação, etc.) |
| -oes | -ões (notificações, objeções, opções, respirações, ações) |
| -ao (substantivo/advérbio) | -ão (não, então, também, manhã, amanhã) |
| -avel, -ivel | -ável, -ível (controlável, sustentável, aceitável, plausível, inevitável) |
| -ario, -orio | -ário, -ório (necessário, secundária, diário) |
| -encia, -ancia | -ência, -ância (evidência, impermanência, constância, benevolência) |
| -ico, -ica (proparoxítona) | -ético, -ática, -ógica (automático, específico, única, fácil, útil, rápido) |
| voce, carater, criterio | você, caráter, critério |

### Regra de validação
- Antes de publicar qualquer arquivo de dados ou conteúdo, executar revisão ortográfica do texto em PT-BR.
- Ao gerar novos seeds ou recomendações, validar que nenhuma palavra comum esteja sem acento.
- Esta regra é gate de qualidade: conteúdo sem acentuação correta não deve ser considerado DONE.

## 11. Playbook Operacional (MVP com Paywall)
- Referência operacional por agente: `/Users/thiagoorikassa/Documents/Estoicismo/docs/execution/agentes-operacionais-mvp-paywall-v1.md`
- O board oficial de execução permanece em: `/Users/thiagoorikassa/Documents/Estoicismo/docs/board-execucao-agentes.md`
- Regra: sempre executar com handoff documentado, evidência e gate de qualidade.
