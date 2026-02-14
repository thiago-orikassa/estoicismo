import 'package:flutter/material.dart';

import '../../app_state.dart';
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
    switch (action) {
      case PremiumBlockAction.viewPlans:
        await showPaywall(context, state: state);
        break;
      case PremiumBlockAction.continueFree:
        state.markPaywallDismissed();
        break;
      case PremiumBlockAction.restorePurchase:
        await _showRestoreFlow(context, state: state);
        break;
    }
  }

  static Future<void> showPaywall(
    BuildContext context, {
    required AppState state,
    PaywallTrigger trigger = PaywallTrigger.manual,
  }) async {
    if (!state.canShowPaywall) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paywall disponível novamente em breve.')),
      );
      return;
    }

    state.markPaywallViewed();

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
                Navigator.of(context).pop();
              },
              onContinueFree: () {
                state.markPaywallDismissed();
                Navigator.of(context).pop();
              },
              onRestorePurchase: () async {
                Navigator.of(context).pop();
                await _showRestoreFlow(context, state: state);
              },
              onStartPlan: (plan) async {
                Navigator.of(context).pop();
                await _processPurchase(context, state: state, plan: plan);
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
    } else {
      state.activateSubscription(plan);
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
            Navigator.of(dialogContext).pop();
          },
          onContactSupport: () {
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
}
