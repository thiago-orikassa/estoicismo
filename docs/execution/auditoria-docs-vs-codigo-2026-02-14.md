# Auditoria Docs vs Código - 2026-02-14

## Escopo
- Documentação auditada: `README.md`, `app/README.md`, `backend/README.md`, `docs/PRD.md`, `docs/arquitetura-mobile.md`, `docs/execution/*.md`, `qa/*.md`.
- Código auditado: `app/lib/**`, `backend/src/**`, `backend/openapi/**`, `backend/data/**`, `content/**`.
- Validações executadas:
  - `node qa/validate_seed.mjs` (ok)
  - `npm test --prefix backend` (8/8 ok)
  - `flutter test` (ok)
  - `flutter analyze` (20 issues; status != 0)

## Achados (priorizados)

### CRÍTICO-01 - Escopo MVP documentado conflita com o comportamento do app
- Documento define assinatura/paywall como fora do MVP: `docs/execution/mvp-escopo-v1.md:23`, `docs/execution/mvp-escopo-v1.md:26`.
- Código já expõe monetização e assinatura em produção de UI:
  - `app/lib/core/paywall/paywall_flow.dart:10`
  - `app/lib/features/history/presentation/history_screen.dart:86`
  - `app/lib/features/favorites/presentation/favorites_screen.dart:185`
  - `app/lib/features/settings/presentation/settings_screen.dart:352`
  - Estado de assinatura persistido em `app/lib/app_state.dart:37`, `app/lib/app_state.dart:60`.
- Risco: time opera com duas fontes de verdade e priorização entra em conflito com o "MVP congelado".

### CRÍTICO-02 - Política offline de 7 dias (SQLite + fallback) não está implementada no app
- Política documentada exige cache local estruturado:
  - `docs/execution/offline-cache-policy-v1.md:9`
  - `docs/execution/offline-cache-policy-v1.md:12`
  - `docs/execution/offline-cache-policy-v1.md:16`
  - `docs/execution/offline-cache-policy-v1.md:21`
- Arquitetura também exige `SQLite (drift)`: `docs/arquitetura-mobile.md:8`.
- Implementação atual só marca estado offline em memória após erro de rede:
  - `app/lib/app_state.dart:395`
  - `app/lib/app_state.dart:399`
  - `app/lib/app_state.dart:416`
  - `app/lib/app_state.dart:420`
  - `app/lib/app_state.dart:434`
  - `app/lib/app_state.dart:438`
- Dependências mobile não incluem Drift/SQLite local: `app/pubspec.yaml:9`.
- Risco: requisito central de consumo diário sem rede não é atendido.

### ALTO-01 - Limites Free vs Pro divergentes entre docs e app
- Docs de UX definem Free com:
  - Favoritos até 20: `docs/execution/ux-experiencia-free-vs-pro-v1.md:51`
  - Histórico 30 dias: `docs/execution/ux-experiencia-free-vs-pro-v1.md:52`
- Código aplica outros limites no cliente:
  - Favoritos free: `take(10)` em `app/lib/features/favorites/presentation/favorites_screen.dart:46`
  - Histórico free: `take(7)` em `app/lib/features/history/presentation/history_screen.dart:129`
- Backend não aplica limite de favoritos (controle só de UI):
  - `backend/src/server.mjs:424`
  - `backend/src/server.mjs:458`
- Risco: inconsistência de produto, telemetria e experiência entre plataformas/versões.

### ALTO-02 - Push/deeplink é prioridade P0 nos docs, mas não está implementado tecnicamente
- Docs posicionam push com deeplink como requisito P0:
  - `docs/board-execucao-agentes.md:36`
  - `docs/board-execucao-agentes.md:39`
  - `docs/roadmap-execucao.md:33`
  - `docs/arquitetura-mobile.md:10`
- App tem apenas fluxo de permissão/simulação de lembrete local de UI, sem stack de push:
  - Dependências atuais: `app/pubspec.yaml:9` (não há FCM/APNs SDK)
  - Não há referência a FCM/APNs/deeplink em código mobile.
- Risco: fluxo diário descrito (push -> abertura -> check-in) não ocorre ponta a ponta.

### ALTO-03 - Contratos de dados em `docs/execution/data-contracts-v1.md` estão desatualizados em relação à API real
- Docs exigem IDs UUID para `Quote`/`DailyRecommendation`:
  - `docs/execution/data-contracts-v1.md:7`
  - `docs/execution/data-contracts-v1.md:20`
  - `docs/execution/data-contracts-v1.md:21`
- API/seed usam IDs string não-UUID:
  - `backend/openapi/daily-package.openapi.yaml:198`
  - `backend/openapi/daily-package.openapi.yaml:214`
  - `backend/data/daily_seed.json:4`
  - `backend/data/daily_seed.json:126`
- API/cliente já exigem campos extras não descritos em `data-contracts-v1`:
  - `backend/openapi/daily-package.openapi.yaml:212`
  - `backend/openapi/daily-package.openapi.yaml:218`
  - `backend/openapi/daily-package.openapi.yaml:223`
  - `backend/openapi/daily-package.openapi.yaml:224`
  - `app/lib/features/daily_quote/domain/models.dart:60`
  - `app/lib/features/daily_quote/domain/models.dart:65`
  - `app/lib/features/daily_quote/domain/models.dart:66`
- Risco: quebra de integração para novos consumidores e documentação enganosa.

### MÉDIO-01 - Analytics documentado (core + monetização) não está totalmente instrumentado
- Core esperado no QA: `qa/eventos-analytics-v1.md:9` até `qa/eventos-analytics-v1.md:16`.
- Monetização esperada: `docs/execution/contexto-paywall-v1.md:100` até `docs/execution/contexto-paywall-v1.md:107`.
- Backend hoje registra apenas subset:
  - `daily_package_viewed` em `backend/src/server.mjs:313`
  - `checkin_submitted` em `backend/src/server.mjs:390`
  - `quote_favorited` em `backend/src/server.mjs:460`
  - `quote_unfavorited` em `backend/src/server.mjs:494`
- Não há `paywall_*`, `trial_started`, `subscription_*`, `push_*` no código app/backend.
- Risco: decisões de produto sem telemetria mínima definida pelos próprios docs.

### MÉDIO-02 - Documentos de status/README estão parcialmente desatualizados ou contraditórios
- Contradição interna em status de QA-02:
  - concluído: `docs/execution/status-execucao-2026-02-14.md:17`
  - em andamento/faltante: `docs/execution/status-execucao-2026-02-14.md:23`
- Bloqueio técnico diz que Flutter não está instalado:
  - `docs/execution/status-execucao-2026-02-14.md:62`
  - ambiente atual possui Flutter 3.41.1.
- `app/README.md` ainda descreve escopo menor e próximos passos antigos:
  - `app/README.md:1`
  - `app/README.md:17`
  - `app/README.md:24`
- `backend/README.md` diz que seed atual usa `probable`, mas seed local está 100% `verified`:
  - doc: `backend/README.md:63`
  - seed: `backend/data/daily_seed.json:13`
- Risco: onboarding de time lento e decisões baseadas em estado não real.

### MÉDIO-03 - Baseline de qualidade CI móvel não está "verde"
- Pipeline exige análise estática: `qa/pipeline-qa-v1.md:17`, `.github/workflows/qa.yml:46`.
- Execução local de `flutter analyze` retorna 20 issues (principalmente `use_build_context_synchronously` e `prefer_const_constructors`).
- Risco: PRs podem falhar na etapa Mobile Quality, apesar de testes passarem.

## Consistências confirmadas (sem divergência crítica)
- Sessão/token e autorização em check-in/favoritos estão implementados e coerentes:
  - `backend/src/server.mjs:252`
  - `backend/src/server.mjs:355`
  - `backend/src/server.mjs:412`
  - `backend/src/server.mjs:483`
- Seed editorial parcial (10/90 verificados) coerente com status SC-02:
  - `content/README.md:12`
  - `content/catalog/quotes_catalog_90.csv` (`10 verified`, `80 pending_literal_extraction`)
  - `content/seeds/quotes_seed_verified_v1.json`.

## Recomendações (ordem de execução)
1. Definir fonte de verdade do escopo imediatamente:
   - ou remover/desativar paywall do app até pós-MVP,
   - ou atualizar `mvp-escopo-v1.md` e board com decisão formal.
2. Fechar gap de offline (SQLite local + política de TTL/purga) antes de novas features.
3. Harmonizar limites Free/Pro em docs + app + backend (idealmente com enforcement no backend).
4. Atualizar `data-contracts-v1.md` para refletir OpenAPI/seed real (incluindo campos extras).
5. Instrumentar eventos ausentes (push e monetização) ou retirar metas dependentes desses eventos.
6. Corrigir documentos desatualizados (`status-execucao`, `app/README`, `backend/README`).
7. Zerar issues do `flutter analyze` para estabilizar gate de CI.
