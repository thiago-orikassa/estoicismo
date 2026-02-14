# Arquitetura Mobile - Base Técnica

## 1. Estratégia recomendada
Para MVP com velocidade e qualidade: Flutter (iOS + Android) com backend desacoplado.

### Stack sugerida
- App: Flutter + Riverpod (estado) + GoRouter (navegação).
- Dados locais: SQLite (drift) + cache em memória.
- Backend: Supabase (Postgres + Auth + Edge Functions) ou Firebase.
- Notificações: FCM + APNs (via Firebase Cloud Messaging).
- Analytics: Firebase Analytics + Crashlytics.

## 2. Princípios de arquitetura
- Clean Architecture leve (camadas: presentation, domain, data).
- Feature-first folders (`features/daily_quote`, `features/history`, `features/settings`).
- Offline-first para leitura e histórico recente.
- Conteúdo versionado (permite corrigir texto/fonte sem quebrar app).

## 3. Módulos do app
- Onboarding e preferências iniciais.
- Home (citação diária + recomendação).
- Histórico e favoritos.
- Perfil/configurações (horário notificação, autor preferido, temas).
- Check-in diário.

## 4. Modelo de dados (mínimo)
## quote
- id
- author (seneca|epictetus|marcus_aurelius)
- text
- source_work
- source_ref
- language
- tags (disciplina, ansiedade, virtude, etc.)
- authenticity_level (verified|probable)

## daily_recommendation
- id
- quote_id
- context (trabalho|emocao|relacionamento|foco)
- action_title
- action_steps (lista curta)
- estimated_minutes

## user_profile
- id
- timezone
- preferred_author
- notification_time
- themes

## daily_checkin
- id
- user_id
- date
- applied (bool)
- note

## 5. Fluxo diário
1. Scheduler gera "pacote diário" por timezone.
2. Usuário recebe push no horário escolhido.
3. Home abre com citação + ação prática.
4. Usuário faz check-in no fim do dia.
5. Evento enviado para analytics.

## 6. Regras críticas
- Nunca gerar "citação inventada".
- Recomendações são derivadas do conteúdo, mas não passam como citação literal.
- Se faltar citação validada para um contexto, usar fallback editorial aprovado.

## 7. Segurança e privacidade
- Coletar apenas dados essenciais.
- Consentimento para push e analytics.
- Política clara: dados de check-in usados para personalização interna.

## 8. CI/CD
- CI: lint, testes unitários, testes de widget/snapshot.
- Distribuição: TestFlight (iOS) e Internal Testing (Play Console).
- Feature flags para testar tipos de recomendação sem nova release.
