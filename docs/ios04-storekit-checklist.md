# IOS-04 — StoreKit: Checklist de Diagnóstico e Teste

## Causa raiz do "Loja indisponível"

Existem 3 causas possíveis, em ordem de probabilidade:

### Causa A — Produtos sem metadados no App Store Connect (mais provável)
Quando `queryProductDetails()` retorna `notFoundIDs: [aethor_pro_annual, aethor_pro_monthly]`,
significa que os produtos não estão prontos na loja. Isso acontece quando:
- Status do produto é "Faltam metadados" (Missing Metadata)
- Produto não tem preço configurado
- Produto não tem localização em pt-BR
- Produto não tem screenshot de revisão IAP
- Acordo de licença de aplicativos pagos não foi aceito no App Store Connect

**Ação:** No App Store Connect → My Apps → Aethor → Manage In-App Purchases:
- Verificar `aethor_pro_annual` e `aethor_pro_monthly`
- Garantir que ambos têm status "Ready to Submit" ou "Waiting for Review"
- Aceitar os contratos em: App Store Connect → Agreements, Tax and Banking

### Causa B — `isAvailable()` retorna false (no device)
Acontece quando:
- O device não está conectado ao App Store (simulador sem conta logada)
- Teste em device sem a conta sandbox configurada
- Restrições de compras no iOS (Screen Time)

**Ação:** No device de teste:
- Settings → App Store → confirmar conta logada
- Settings → Screen Time → confirmar que compras não estão bloqueadas

### Causa C — Simulator sem arquivo .storekit ativo no scheme
O arquivo `Aethor.storekit` está referenciado no `Runner.xcscheme`.
Funciona automaticamente ao usar `flutter run` no simulator.

---

## Diagnóstico em debug build

O app tem uma seção "Diagnóstico IAP" em Ajustes → seção QA (debug only).
Ela mostra:
- `isAvailable`: true/false
- `productsLoaded`: true/false
- `notFound`: lista de IDs não encontrados
- `error`: mensagem de erro do SDK

Use o botão "Reload produtos IAP" para re-tentar o carregamento sem reiniciar o app.

---

## Checklist de teste em Sandbox (device físico)

### Pré-requisitos
- [ ] Conta sandbox criada: `aethor.tester.2026@outlook.com`
- [ ] Senha definida em App Store Connect → Users & Access → Sandbox Testers
- [ ] Device configurado: Settings → App Store → Sandbox Account → Sign In
- [ ] App instalado via `flutter run --dart-define=DEV_SERVER_URL=http://SEU_IP:8787`
  (ou via TestFlight para testar contra Railway production)

### Configuração do App Store Connect
- [ ] `aethor_pro_annual` — status "Ready to Submit"
  - Preço configurado: R$ 149,00/ano (ou tier equivalente)
  - Localização pt-BR com nome e descrição
  - Tipo: Auto-Renewable Subscription
  - Introductory Offer: 7 dias grátis (Free Trial)
  - Subscription Group: "Aethor Pro"
- [ ] `aethor_pro_monthly` — status "Ready to Submit"
  - Preço configurado: R$ 19,90/mês
  - Localização pt-BR
  - Sem introductory offer
- [ ] Contratos aceitos: Agreements, Tax and Banking → Paid Apps Agreement ativo

### Cenários de teste

#### Cenário 1 — Compra anual (com trial)
1. Abrir app → navegar até Ajustes → "Ver planos"
2. Selecionar "Pro Anual" → tocar "Iniciar 7 dias grátis"
3. Autenticar com sandbox account quando solicitado
4. **Verificar:** overlay "Processando..." aparece
5. **Verificar:** tela de sucesso com "Trial ativo — 7 dias grátis"
6. **Verificar:** Ajustes mostra "Pro Anual · Trial ativo"
7. **Verificar:** backend `/v1/subscription/entitlement` retorna `status: trial`

#### Cenário 2 — Compra mensal (sem trial)
1. Reinstalar app (ou resetar onboarding via debug)
2. Abrir paywall → selecionar "Pro Mensal" → tocar "Assinar agora"
3. **Verificar:** confirmação de preço R$ 19,90/mês
4. **Verificar:** após confirmação, tela de sucesso
5. **Verificar:** `status: active` no backend

#### Cenário 3 — Restore
1. Desinstalar e reinstalar o app
2. Abrir Ajustes → "Restaurar compra"
3. **Verificar:** restore bem-sucedido → acesso Pro restaurado
4. **Verificar:** se nenhuma compra anterior → mensagem "Nenhuma compra encontrada"

#### Cenário 4 — Cold start com Pro ativo
1. Com Pro ativo (cenário 1 ou 2 concluído)
2. Forçar encerramento e reabrir o app
3. **Verificar:** usuário ainda é Pro (entitlement persistido localmente)
4. **Verificar:** `syncEntitlementFromBackend()` no bootstrap confirma status

#### Cenário 5 — Sem conexão
1. Ativar modo avião
2. Tentar abrir paywall → tocar em comprar
3. **Verificar:** mensagem "Loja indisponível. Verifique sua conexão e tente novamente."
4. Reativar rede → tocar novamente → **Verificar:** retry automático funciona

---

## O que foi corrigido no código (2026-03-15)

### `purchase_service.dart`
- Adicionado `notFoundIds` e `queryError` para diagnóstico
- Adicionado método `reload()` para re-tentar carregamento de produtos sem reiniciar
- `_subscription ??=` — evita duplo listener se `initialize()` for chamado mais de uma vez
- Extração de `_queryProducts()` como método privado reutilizável

### `paywall_flow.dart` — `_processPurchase`
- Antes de retornar "Loja indisponível", tenta um `reload()` automático
- Mensagens de erro diferenciadas: "Loja indisponível" vs "Produto não encontrado"

### `paywall_flow.dart` — `_showRestoreFlow` (bug corrigido)
- O `completer` do restore só completa em `restored`, `error` ou `cancelled`
- Antes: completava com `false` em qualquer evento não-`restored` — incluindo `pending`, o que quebrava o restore se um evento `pending` chegasse primeiro

### `app_state.dart`
- `bootstrap()` agora inclui `syncEntitlementFromBackend()` no `Future.wait`
- Garante que o status de assinatura seja sincronizado do servidor a cada abertura do app

### `settings_screen.dart`
- Nova seção "Diagnóstico IAP" no modo debug
- Mostra `isAvailable`, `productsLoaded`, `notFoundIds`, `queryError`
- Botão "Reload produtos IAP" para retry manual

---

## Critério de aceite (IOS-04)

- [ ] Trial anual inicia, tela de sucesso aparece, `status: trial` no backend
- [ ] Compra mensal ativa, `status: active` no backend
- [ ] Restore funciona após reinstalação
- [ ] Sem crash durante nenhum dos 5 cenários acima
- [ ] Fluxo free não é afetado (usuário free ainda acessa a citação diária normalmente)
