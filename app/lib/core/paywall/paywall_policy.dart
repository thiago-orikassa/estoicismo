import '../design_system/components/paywall_types.dart';

enum PaywallBlockReason {
  paywallDisabled,
  alreadyPro,
  firstSessionGuardrail,
  dailyFrequencyCap,
  dismissCooldown,
  featureBlockTriggerDisabled,
  valueBasedTriggerDisabled,
  manualTriggerDisabled,
  valueMilestoneNotReached,
}

class PaywallEligibilitySnapshot {
  const PaywallEligibilitySnapshot({
    required this.paywallEnabled,
    required this.isPro,
    required this.activeDaysCount,
    required this.completedCheckinsCount,
    required this.lastPaywallView,
    required this.lastPaywallDismissed,
    required this.featureBlockTriggerEnabled,
    required this.valueBasedTriggerEnabled,
    required this.manualTriggerEnabled,
  });

  final bool paywallEnabled;
  final bool isPro;
  final int activeDaysCount;
  final int completedCheckinsCount;
  final DateTime? lastPaywallView;
  final DateTime? lastPaywallDismissed;
  final bool featureBlockTriggerEnabled;
  final bool valueBasedTriggerEnabled;
  final bool manualTriggerEnabled;
}

class PaywallEvaluation {
  const PaywallEvaluation({
    required this.canShow,
    required this.valueMilestone,
    this.blockedReason,
  });

  final bool canShow;
  final PaywallBlockReason? blockedReason;
  final String valueMilestone;

  String get blockedReasonCode => blockedReason?.name ?? 'eligible';
}

String resolveValueMilestone({
  required int activeDaysCount,
  required int completedCheckinsCount,
}) {
  final reachedCheckins = completedCheckinsCount >= 3;
  final reachedActiveDays = activeDaysCount >= 3;

  if (reachedCheckins && reachedActiveDays) return 'checkins_and_active_days_3';
  if (reachedCheckins) return 'checkins_3';
  if (reachedActiveDays) return 'active_days_3';
  return 'none';
}

PaywallEvaluation evaluatePaywallEligibility({
  required PaywallTrigger trigger,
  required PaywallEligibilitySnapshot snapshot,
  required DateTime now,
  bool enforceTriggerRules = true,
}) {
  final milestone = resolveValueMilestone(
    activeDaysCount: snapshot.activeDaysCount,
    completedCheckinsCount: snapshot.completedCheckinsCount,
  );

  if (!snapshot.paywallEnabled) {
    return PaywallEvaluation(
      canShow: false,
      blockedReason: PaywallBlockReason.paywallDisabled,
      valueMilestone: milestone,
    );
  }

  if (snapshot.isPro) {
    return PaywallEvaluation(
      canShow: false,
      blockedReason: PaywallBlockReason.alreadyPro,
      valueMilestone: milestone,
    );
  }

  final isFirstSessionGuardrail =
      snapshot.activeDaysCount <= 1 && snapshot.completedCheckinsCount == 0;
  if (isFirstSessionGuardrail) {
    return PaywallEvaluation(
      canShow: false,
      blockedReason: PaywallBlockReason.firstSessionGuardrail,
      valueMilestone: milestone,
    );
  }

  if (snapshot.lastPaywallView != null &&
      now.difference(snapshot.lastPaywallView!) < const Duration(hours: 24)) {
    return PaywallEvaluation(
      canShow: false,
      blockedReason: PaywallBlockReason.dailyFrequencyCap,
      valueMilestone: milestone,
    );
  }

  if (snapshot.lastPaywallDismissed != null &&
      now.difference(snapshot.lastPaywallDismissed!) <
          const Duration(hours: 48)) {
    return PaywallEvaluation(
      canShow: false,
      blockedReason: PaywallBlockReason.dismissCooldown,
      valueMilestone: milestone,
    );
  }

  if (enforceTriggerRules) {
    switch (trigger) {
      case PaywallTrigger.featureBlock:
        if (!snapshot.featureBlockTriggerEnabled) {
          return PaywallEvaluation(
            canShow: false,
            blockedReason: PaywallBlockReason.featureBlockTriggerDisabled,
            valueMilestone: milestone,
          );
        }
        break;
      case PaywallTrigger.valueBased:
        if (!snapshot.valueBasedTriggerEnabled) {
          return PaywallEvaluation(
            canShow: false,
            blockedReason: PaywallBlockReason.valueBasedTriggerDisabled,
            valueMilestone: milestone,
          );
        }
        if (milestone == 'none') {
          return PaywallEvaluation(
            canShow: false,
            blockedReason: PaywallBlockReason.valueMilestoneNotReached,
            valueMilestone: milestone,
          );
        }
        break;
      case PaywallTrigger.manual:
        if (!snapshot.manualTriggerEnabled) {
          return PaywallEvaluation(
            canShow: false,
            blockedReason: PaywallBlockReason.manualTriggerDisabled,
            valueMilestone: milestone,
          );
        }
        break;
    }
  }

  return PaywallEvaluation(canShow: true, valueMilestone: milestone);
}
