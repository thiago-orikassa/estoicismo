# Arquitetura de Pastas e Camadas v1 (MA-01)

Data: 2026-02-14

## Estrutura
app/
- lib/
  - core/
    - networking/
    - storage/
    - analytics/
    - notifications/
    - theme/
  - features/
    - daily_quote/
      - presentation/
      - domain/
      - data/
    - history/
    - favorites/
    - checkin/
    - settings/
    - onboarding/

## Regra de camadas
- presentation: UI, estado de tela e navegação.
- domain: entidades, casos de uso e regras de negócio.
- data: fontes (api/local), repos e mappers.

## Convenções
- Feature-first, sem compartilhamento acoplado entre features.
- Core apenas para concern transversal.
- DTOs não atravessam para presentation.
