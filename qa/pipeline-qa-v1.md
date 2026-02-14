# Pipeline de QA v1

Objetivo: garantir qualidade consistente em cada merge e release.

## Gatilhos
1. `pull_request`: valida tudo antes do merge.
2. `push` em `main/master`: valida novamente e bloqueia regressões.

## Etapas automatizadas (CI)
1. **Content Quality**
   Script: `node qa/validate_seed.mjs`.
   Verifica: fonte obrigatória, campos críticos, referências cruzadas.
2. **Backend Tests**
   Script: `npm test --prefix backend`.
   Cobertura mínima: contratos HTTP essenciais e validações.
3. **Mobile Quality**
   Scripts: `flutter analyze` e `flutter test` em `/app`.
   Detecta regressões de UI e lógica.

## Gates de qualidade (obrigatórios)
1. Todas as etapas de CI aprovadas.
2. 0 bugs P0/P1 abertos.
3. Fluxos críticos aprovados conforme `/Users/thiagoorikassa/Documents/Estoicismo/qa/plano-testes-v1.md`.

## Manual obrigatório antes de release
1. Rodar E2E de 7 ciclos diários sem duplicidade.
2. Validar push -> deep link -> check-in correto.
3. Verificar telemetria mínima (eventos definidos em `/Users/thiagoorikassa/Documents/Estoicismo/qa/eventos-analytics-v1.md`).

## Pós-release (monitoramento)
1. Crash-free > 99.5% nas primeiras 72 horas.
2. Taxa de abertura da notificação diária dentro do baseline definido.
