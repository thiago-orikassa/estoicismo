import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../auth/auth_flow.dart';
import '../auth/auth_models.dart';
import '../design_system/components/components.dart';
import '../design_system/tokens/design_tokens.dart';
import '../domain/subscription.dart';

class PaywallFlow {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conteúdo premium em preparação.')),
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
      backgroundColor: StoicColors.cardBackground,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paywall disponível novamente em breve.')),
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
          'price_displayed': _priceForPlan(SubscriptionPlan.annual),
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
                      'price_displayed': _priceForPlan(plan),
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
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ProcessingPurchaseOverlay(),
    );

    await Future.delayed(const Duration(milliseconds: 2000));
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    final isTrial = plan == SubscriptionPlan.annual;
    if (isTrial) {
      state.startTrial(plan);
      unawaited(
        state.trackEvent(
          'trial_started',
          properties: {
            'trigger_type': trigger.name,
            'plan_selected': plan.name,
            'price_displayed': _priceForPlan(plan),
            'trial_eligible': true,
          },
        ),
      );
    } else {
      state.activateSubscription(plan);
      unawaited(
        state.trackEvent(
          'subscription_activated',
          properties: {
            'trigger_type': trigger.name,
            'plan_selected': plan.name,
            'price_displayed': _priceForPlan(plan),
            'trial_eligible': false,
          },
        ),
      );
    }

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
                content: Text('Suporte: suporte@estoicismo.app'),
              ),
            );
          },
        );
      },
    );
  }

  static String _priceForPlan(SubscriptionPlan plan) {
    if (plan == SubscriptionPlan.monthly) return 'R\$ 19,90/mês';
    return 'R\$ 149,00/ano';
  }
}
