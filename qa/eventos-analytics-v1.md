# Eventos de Analytics v1 (QA-02)

Data: 2026-02-15

## Convenção
snake_case, com `event_version=1`

## Eventos

### Core
- app_opened
- onboarding_completed
- daily_package_viewed
- quote_favorited
- quote_unfavorited
- checkin_submitted
- daily_ritual_completed

### Push Notifications
- push_received
- push_opened
- push_token_registered (platform)
- push_delivered (date_local, token_count, sent, failed)
- push_permission_requested (platform, source)
- push_permission_result (platform, granted, source)

### Notification Nudge
- notification_nudge_shown
- notification_nudge_dismissed

## Propriedades mínimas
- user_id
- date_local
- timezone
- author
- context
- event_version
