import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../app_state.dart';
import '../auth/auth_flow.dart';
import '../auth/auth_models.dart';
import '../design_system/components/components.dart';
import '../design_system/tokens/design_tokens.dart';
import '../domain/subscription.dart';
import 'purchase_service.dart';

class PaywallFlow {
  static void _trackBlockedPaywallAttempt(
    AppState state, {
    required PaywallTrigger trigger,
  }) {
    unawaited(
      state.trackEvent(
        'paywall_view_blocked',
        properties: {
          'trigger_type': trigger.name,
          'blocked_reason': state.paywallBlockReasonCodeForTrigger(trigger),
          'value_milestone': state.valueBasedMilestone,
        },
      ),
    );
  }

  static Future<void> showRestore(
    BuildContext context, {
    required AppState state,
  }) async {
    await _showRestoreFlow(context, state: state);
  }

  static Future<void> showPremiumBlock(
    BuildContext context, {
    required AppState state,
    required PremiumFeature feature,
  }) async {
    if (!state.canShowPaywallForTrigger(PaywallTrigger.featureBlock)) {
      _trackBlockedPaywallAttempt(
        state,
        trigger: PaywallTrigger.featureBlock,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Em preparação.')),
      );
      return;
    }

    unawaited(
      state.trackEvent(
        'premium_feature_blocked',
        properties: {
          'trigger_type': PaywallTrigger.featureBlock.name,
          'feature': feature.name,
          'trial_eligible': !state.isPro,
        },
      ),
    );

    final action = await showModalBottomSheet<PremiumBlockAction>(
      context: context,
      backgroundColor: AethorColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return PremiumBlockSheet(
          feature: feature,
          onAction: (value) => Navigator.of(context).pop(value),
        );
      },
    );

    if (action == null) return;
    if (!context.mounted) return;
    switch (action) {
      case PremiumBlockAction.viewPlans:
        unawaited(
          state.trackEvent(
            'paywall_cta_clicked',
            properties: {
              'trigger_type': PaywallTrigger.featureBlock.name,
              'cta': 'view_plans',
            },
          ),
        );
        await showPaywall(
          context,
          state: state,
          trigger: PaywallTrigger.featureBlock,
        );
        break;
      case PremiumBlockAction.continueFree:
        state.markPaywallDismissed();
        unawaited(
          state.trackEvent(
            'paywall_dismissed',
            properties: {
              'trigger_type': PaywallTrigger.featureBlock.name,
              'dismiss_reason': 'continue_free',
            },
          ),
        );
        break;
      case PremiumBlockAction.restorePurchase:
        unawaited(
          state.trackEvent(
            'restore_purchase_started',
            properties: {'trigger_type': PaywallTrigger.featureBlock.name},
          ),
        );
        await _showRestoreFlow(context, state: state);
        break;
    }
  }

  static Future<void> showPaywall(
    BuildContext context, {
    required AppState state,
    PaywallTrigger trigger = PaywallTrigger.manual,
  }) async {
    if (!state.canShowPaywallForTrigger(trigger)) {
      _trackBlockedPaywallAttempt(state, trigger: trigger);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disponível em instantes.')),
      );
      return;
    }

    state.markPaywallViewed();
    unawaited(
      state.trackEvent(
        'paywall_viewed',
        properties: {
          'paywall_variant': 'A',
          'trigger_type': trigger.name,
          'plan_selected': SubscriptionPlan.annual.name,
          'price_displayed': _priceForPlan(state, SubscriptionPlan.annual),
          'value_milestone': state.valueBasedMilestone,
          'trial_eligible': !state.isPro,
        },
      ),
    );

    SubscriptionPlan selectedPlan = SubscriptionPlan.annual;

    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Paywall',
      pageBuilder: (context, _, __) {
        return StatefulBuilder(
          builder: (context, setState) {
            return PaywallMain(
              selectedPlan: selectedPlan,
              trigger: trigger,
              onPlanChange: (plan) => setState(() => selectedPlan = plan),
              onClose: () {
                state.markPaywallDismissed();
                unawaited(
                  state.trackEvent(
                    'paywall_dismissed',
                    properties: {
                      'trigger_type': trigger.name,
                      'dismiss_reason': 'close',
                    },
                  ),
                );
                Navigator.of(context).pop();
              },
              onContinueFree: () {
                state.markPaywallDismissed();
                unawaited(
                  state.trackEvent(
                    'paywall_dismissed',
                    properties: {
                      'trigger_type': trigger.name,
                      'dismiss_reason': 'continue_free',
                    },
                  ),
                );
                Navigator.of(context).pop();
              },
              onRestorePurchase: () async {
                unawaited(
                  state.trackEvent(
                    'paywall_cta_clicked',
                    properties: {
                      'trigger_type': trigger.name,
                      'cta': 'restore_purchase',
                    },
                  ),
                );
                Navigator.of(context).pop();
                unawaited(
                  state.trackEvent(
                    'restore_purchase_started',
                    properties: {'trigger_type': trigger.name},
                  ),
                );
                await _showRestoreFlow(context, state: state);
              },
              onStartPlan: (plan) async {
                if (!state.isAuthenticated) {
                  final loggedIn = await AuthFlow.showLoginPrompt(
                    context,
                    state: state,
                    contextType: AuthPromptContext.subscription,
                    force: true,
                  );
                  if (!loggedIn) {
                    return;
                  }
                }
                if (!context.mounted) return;
                unawaited(
                  state.trackEvent(
                    'paywall_cta_clicked',
                    properties: {
                      'paywall_variant': 'A',
                      'trigger_type': trigger.name,
                      'cta': 'start_plan',
                      'plan_selected': plan.name,
                      'price_displayed': _priceForPlan(state, plan),
                      'trial_eligible': plan == SubscriptionPlan.annual,
                    },
                  ),
                );
                Navigator.of(context).pop();
                await _processPurchase(
                  context,
                  state: state,
                  plan: plan,
                  trigger: trigger,
                );
              },
            );
          },
        );
      },
      transitionBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }

  static Future<void> _processPurchase(
    BuildContext context, {
    required AppState state,
    required SubscriptionPlan plan,
    required PaywallTrigger trigger,
  }) async {
    final purchaseService = state.purchaseService;

    if (purchaseService == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loja indisponível. Tente novamente mais tarde.')),
        );
      }
      return;
    }

    // If products weren't loaded on startup (network blip, first launch),
    // do a silent reload before giving up.
    if (!purchaseService.available || !purchaseService.productsLoaded) {
      final loaded = await purchaseService.reload();
      if (!loaded && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loja indisponível. Verifique sua conexão e tente novamente.')),
        );
        return;
      }
    }

    final product = purchaseService.productForPlan(plan);
    if (product == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto não encontrado na loja. Aguarde alguns instantes e tente novamente.')),
        );
      }
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ProcessingPurchaseOverlay(),
    );

    StreamSubscription<PurchaseUpdate>? sub;
    final completer = Completer<PurchaseUpdate>();
    sub = purchaseService.updates.listen((update) {
      if (!completer.isCompleted) {
        completer.complete(update);
        sub?.cancel();
      }
    });

    try {
      await purchaseService.buyProduct(product);
    } catch (_) {
      if (!completer.isCompleted) completer.complete(PurchaseUpdate.error);
      sub.cancel();
    }

    final result = await completer.future;
    sub.cancel();

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    switch (result) {
      case PurchaseUpdate.purchased:
        final isTrial = plan == SubscriptionPlan.annual;
        try {
          if (isTrial) {
            await state.api.post(
              '/v1/subscription/trial/start',
              body: {'plan': plan.name},
            );
            state.startTrial(plan);
          } else {
            await state.api.post(
              '/v1/subscription/activate',
              body: {'plan': plan.name},
            );
            state.activateSubscription(plan);
          }
        } on HttpException {
          // Backend 409 (trial already used): fallback to activate.
          try {
            await state.api.post(
              '/v1/subscription/activate',
              body: {'plan': plan.name},
            );
            state.activateSubscription(plan);
          } catch (_) {
            // Optimistic entitlement: store bought, give access anyway.
            if (isTrial) {
              state.startTrial(plan);
            } else {
              state.activateSubscription(plan);
            }
          }
        } catch (_) {
          // Optimistic entitlement on backend failure.
          if (isTrial) {
            state.startTrial(plan);
          } else {
            state.activateSubscription(plan);
          }
        }

        await purchaseService.completePurchase(purchaseService.lastPurchase!);

        // Best-effort: log purchase token to backend for server-side validation.
        _logPurchaseToBackend(
          state,
          purchase: purchaseService.lastPurchase!,
          plan: plan,
        );

        unawaited(
          state.trackEvent(
            isTrial ? 'trial_started' : 'subscription_activated',
            properties: {
              'trigger_type': trigger.name,
              'plan_selected': plan.name,
              'price_displayed': _priceForPlan(state, plan),
              'trial_eligible': isTrial,
            },
          ),
        );

        if (!context.mounted) return;
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return SubscriptionSuccessOverlay(
              isTrial: isTrial,
              onPrimary: () => Navigator.of(context).pop(),
              onClose: () => Navigator.of(context).pop(),
            );
          },
        );

      case PurchaseUpdate.cancelled:
        // Silently close — user cancelled the sheet.
        break;

      case PurchaseUpdate.error:
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao processar compra. Tente novamente.')),
          );
        }

      case PurchaseUpdate.pending:
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Compra pendente de aprovação.')),
          );
        }

      case PurchaseUpdate.restored:
        // Handled by restore flow, not purchase flow.
        break;
    }
  }

  static Future<void> _showRestoreFlow(
    BuildContext context, {
    required AppState state,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return RestorePurchaseDialog(
          onPerformRestore: () async {
            final purchaseService = state.purchaseService;
            if (purchaseService == null || !purchaseService.available) {
              return false;
            }

            final completer = Completer<bool>();
            StreamSubscription<PurchaseUpdate>? sub;
            sub = purchaseService.updates.listen((update) {
              if (completer.isCompleted) return;
              switch (update) {
                case PurchaseUpdate.restored:
                  completer.complete(true);
                  sub?.cancel();
                case PurchaseUpdate.error:
                case PurchaseUpdate.cancelled:
                  completer.complete(false);
                  sub?.cancel();
                case PurchaseUpdate.purchased:
                case PurchaseUpdate.pending:
                  // Ignore — not terminal for a restore flow.
                  break;
              }
            });

            // Timeout after 15 seconds (e.g. no prior purchases → silent).
            final timer = Timer(const Duration(seconds: 15), () {
              if (!completer.isCompleted) {
                completer.complete(false);
                sub?.cancel();
              }
            });

            await purchaseService.restorePurchases();
            final restored = await completer.future;
            timer.cancel();

            if (restored && purchaseService.lastPurchase != null) {
              try {
                await state.api.post(
                  '/v1/subscription/restore',
                  body: {'plan': state.subscriptionPlan.name},
                );
              } catch (_) {
                // Optimistic: store already charged, give access.
              }
              await purchaseService
                  .completePurchase(purchaseService.lastPurchase!);
            }
            return restored;
          },
          onClose: () => Navigator.of(dialogContext).pop(),
          onSuccess: () {
            state.restoreSubscription();
            unawaited(
              state.trackEvent(
                'restore_purchase_success',
                properties: {'restored': true},
              ),
            );
            Navigator.of(dialogContext).pop();
          },
          onContactSupport: () {
            unawaited(
              state.trackEvent(
                'restore_purchase_failed',
                properties: {'restored': false},
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Suporte: suporte@aethor.app'),
              ),
            );
          },
        );
      },
    );
  }

  static void _logPurchaseToBackend(
    AppState state, {
    required PurchaseDetails purchase,
    required SubscriptionPlan plan,
  }) {
    final productId = SubscriptionProducts.productIdFromPlan(plan);
    final platform = Platform.isIOS ? 'ios' : 'android';
    unawaited(
      state.api
          .post(
            '/v1/purchases/log',
            body: {
              'product_id': productId,
              'platform': platform,
              'purchase_token':
                  purchase.verificationData.serverVerificationData,
              'transaction_id': purchase.purchaseID ?? '',
            },
          )
          .catchError((_) => <String, dynamic>{}),
    );
  }

  static String _priceForPlan(AppState state, SubscriptionPlan plan) {
    return state.priceForPlan(plan);
  }
}
