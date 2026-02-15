import 'package:estoicismo_app/core/design_system/components/paywall_types.dart';
import 'package:estoicismo_app/core/paywall/paywall_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  PaywallEligibilitySnapshot baseSnapshot({
    bool paywallEnabled = true,
    bool isPro = false,
    int activeDaysCount = 3,
    int completedCheckinsCount = 3,
    DateTime? lastPaywallView,
    DateTime? lastPaywallDismissed,
    bool featureBlockTriggerEnabled = true,
    bool valueBasedTriggerEnabled = true,
    bool manualTriggerEnabled = true,
  }) {
    return PaywallEligibilitySnapshot(
      paywallEnabled: paywallEnabled,
      isPro: isPro,
      activeDaysCount: activeDaysCount,
      completedCheckinsCount: completedCheckinsCount,
      lastPaywallView: lastPaywallView,
      lastPaywallDismissed: lastPaywallDismissed,
      featureBlockTriggerEnabled: featureBlockTriggerEnabled,
      valueBasedTriggerEnabled: valueBasedTriggerEnabled,
      manualTriggerEnabled: manualTriggerEnabled,
    );
  }

  test('bloqueia paywall na primeira sessão', () {
    final evaluation = evaluatePaywallEligibility(
      trigger: PaywallTrigger.valueBased,
      snapshot: baseSnapshot(activeDaysCount: 1, completedCheckinsCount: 0),
      now: DateTime(2026, 2, 14, 12),
    );

    expect(evaluation.canShow, isFalse);
    expect(evaluation.blockedReason, PaywallBlockReason.firstSessionGuardrail);
  });

  test('aplica limite de frequência de 24h após visualização', () {
    final now = DateTime(2026, 2, 14, 12);
    final evaluation = evaluatePaywallEligibility(
      trigger: PaywallTrigger.manual,
      snapshot:
          baseSnapshot(lastPaywallView: now.subtract(const Duration(hours: 2))),
      now: now,
    );

    expect(evaluation.canShow, isFalse);
    expect(evaluation.blockedReason, PaywallBlockReason.dailyFrequencyCap);
  });

  test('aplica cooldown de 48h após recusa', () {
    final now = DateTime(2026, 2, 14, 12);
    final evaluation = evaluatePaywallEligibility(
      trigger: PaywallTrigger.featureBlock,
      snapshot: baseSnapshot(
        lastPaywallDismissed: now.subtract(const Duration(hours: 12)),
      ),
      now: now,
    );

    expect(evaluation.canShow, isFalse);
    expect(evaluation.blockedReason, PaywallBlockReason.dismissCooldown);
  });

  test('bloqueia trigger valueBased sem milestone', () {
    final evaluation = evaluatePaywallEligibility(
      trigger: PaywallTrigger.valueBased,
      snapshot: baseSnapshot(activeDaysCount: 2, completedCheckinsCount: 2),
      now: DateTime(2026, 2, 14, 12),
    );

    expect(evaluation.canShow, isFalse);
    expect(
        evaluation.blockedReason, PaywallBlockReason.valueMilestoneNotReached);
    expect(evaluation.valueMilestone, 'none');
  });

  test('libera valueBased no milestone de consistência (3 dias ativos)', () {
    final evaluation = evaluatePaywallEligibility(
      trigger: PaywallTrigger.valueBased,
      snapshot: baseSnapshot(activeDaysCount: 3, completedCheckinsCount: 1),
      now: DateTime(2026, 2, 14, 12),
    );

    expect(evaluation.canShow, isTrue);
    expect(evaluation.blockedReason, isNull);
    expect(evaluation.valueMilestone, 'active_days_3');
  });

  test('bloqueia trigger manual quando flag está desativada', () {
    final evaluation = evaluatePaywallEligibility(
      trigger: PaywallTrigger.manual,
      snapshot: baseSnapshot(manualTriggerEnabled: false),
      now: DateTime(2026, 2, 14, 12),
    );

    expect(evaluation.canShow, isFalse);
    expect(evaluation.blockedReason, PaywallBlockReason.manualTriggerDisabled);
  });
}
