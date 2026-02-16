# Matriz de Teste de Push — QA-03

Data: 2026-02-15

## Dispositivos

| # | Plataforma | Modelo | OS Version | Fabricante |
|---|-----------|--------|------------|------------|
| A1 | Android | — | Android 13+ | — |
| A2 | Android | — | Android 12 | — |
| I1 | iOS | — | iOS 17+ | Apple |
| I2 | iOS | — | iOS 16 | Apple |

## Cenários por dispositivo (7 dias × 3 estados)

### Estados do app
- **Cold start**: app não estava em memória → tap na notificação abre o app
- **Background**: app em memória mas não visível → tap na notificação traz ao front
- **Foreground**: app visível → banner in-app exibido, tap navega

### Checklist por dia (repetir para cada dia do ciclo de 7)

| Dia | Estado | Push recebido | Tap na notif. | Tela correta | Conteúdo carregado | Check-in | Evento rastreado |
|-----|--------|---------------|---------------|--------------|---------------------|----------|-----------------|
| 1 | Cold start | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| 2 | Background | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| 3 | Foreground | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| 4 | Cold start | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| 5 | Background | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| 6 | Foreground | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| 7 | Cold start | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

### Validações adicionais

- [ ] Deep link navega para tab "Hoje" com data correta
- [ ] Conteúdo (citação + recomendação) corresponde ao dia
- [ ] Check-in persiste após fechar e reabrir o app
- [ ] Favorito funciona normalmente após navegação via push
- [ ] Permissão negada → notificação não chega (correto)
- [ ] Permissão concedida no onboarding → push funciona no dia seguinte
- [ ] Token refresh → backend recebe token atualizado
- [ ] Eventos `push_received` e `push_opened` no analytics com `event_version=1`

## Critério de aceite QA-03

1. **7/7 ciclos** sem falha crítica em pelo menos 1 Android + 1 iOS
2. Push entregue e aberto em Android e iOS
3. Deep link navega para tela correta em cold start, background e foreground
4. Check-in persiste corretamente
5. Eventos `push_received` e `push_opened` rastreados com `event_version=1`
6. Nenhuma regressão no fluxo diário free (citação, prática, check-in)
7. Paywall não interfere no fluxo free

## Procedimento

1. Instalar build de staging nos 4 dispositivos
2. Registrar token FCM em cada dispositivo
3. Executar `node backend/scripts/send-daily-push.mjs "America/Sao_Paulo"` 1x por dia
4. Para cada dispositivo: verificar recebimento → tap → validar tela → check-in → verificar analytics
5. Repetir por 7 dias consecutivos
6. No dia 7: validar métricas no endpoint `/v1/observability/metrics`

## Resultado

| Dispositivo | Dias OK | Dias com falha | Observações |
|-------------|---------|----------------|-------------|
| A1 | /7 | | |
| A2 | /7 | | |
| I1 | /7 | | |
| I2 | /7 | | |

**Veredicto:** [ ] GO [ ] NO-GO
