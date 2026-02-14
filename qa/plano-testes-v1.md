# Plano de Testes v1 (QA-01)

Data: 2026-02-14

## Fluxos críticos
1. Push recebido -> abre tela diária correta
2. Home diária exibe citação+fonte+ação
3. Check-in persiste com data local e UTC
4. Favoritar/desfavoritar sincroniza e mantém offline
5. Histórico carrega 30 dias sem falha

## Pirâmide
- Unit: validações de domínio e mappers
- Integration: repositórios data/local/api
- E2E: fluxo diário completo

## Critérios de saída para beta
- 0 bugs críticos abertos
- crash-free > 99.5%
- E2E de 7 ciclos sem duplicidade
