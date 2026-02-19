import 'package:aethor_app/core/design_system/components/paywall_types.dart';
import 'package:aethor_app/core/paywall/paywall_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 2, 15, 12);

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

  // ---------------------------------------------------------------------------
  // resolveValueMilestone
  // ---------------------------------------------------------------------------
  group('resolveValueMilestone', () {
    test('retorna none quando nenhum milestone foi atingido', () {
      expect(
        resolveValueMilestone(activeDaysCount: 2, completedCheckinsCount: 2),
        'none',
      );
    });

    test('retorna checkins_3 quando apenas check-ins atingem 3', () {
      expect(
        resolveValueMilestone(activeDaysCount: 2, completedCheckinsCount: 3),
        'checkins_3',
      );
    });

    test('retorna active_days_3 quando apenas dias ativos atingem 3', () {
      expect(
        resolveValueMilestone(activeDaysCount: 3, completedCheckinsCount: 1),
        'active_days_3',
      );
    });

    test('retorna checkins_and_active_days_3 quando ambos atingem 3', () {
      expect(
        resolveValueMilestone(activeDaysCount: 3, completedCheckinsCount: 3),
        'checkins_and_active_days_3',
      );
    });

    test('reconhece valores acima do limiar (>3)', () {
      expect(
        resolveValueMilestone(activeDaysCount: 10, completedCheckinsCount: 7),
        'checkins_and_active_days_3',
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Guardrails globais (independente de trigger)
  // ---------------------------------------------------------------------------
  group('guardrails globais', () {
    test('bloqueia quando paywall está desabilitado (feature flag off)', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.manual,
        snapshot: baseSnapshot(paywallEnabled: false),
        now: now,
      );

      expect(evaluation.canShow, isFalse);
      expect(evaluation.blockedReason, PaywallBlockReason.paywallDisabled);
    });

    test('bloqueia quando usuário já é Pro', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.featureBlock,
        snapshot: baseSnapshot(isPro: true),
        now: now,
      );

      expect(evaluation.canShow, isFalse);
      expect(evaluation.blockedReason, PaywallBlockReason.alreadyPro);
    });

    test('bloqueia na primeira sessão (dia 1, 0 check-ins)', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.valueBased,
        snapshot: baseSnapshot(activeDaysCount: 1, completedCheckinsCount: 0),
        now: now,
      );

      expect(evaluation.canShow, isFalse);
      expect(
          evaluation.blockedReason, PaywallBlockReason.firstSessionGuardrail);
    });

    test('libera na primeira sessão se já tem 1 check-in', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.featureBlock,
        snapshot: baseSnapshot(activeDaysCount: 1, completedCheckinsCount: 1),
        now: now,
      );

      expect(evaluation.canShow, isTrue);
    });

    test('libera no segundo dia sem check-ins (não é mais primeira sessão)',
        () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.featureBlock,
        snapshot: baseSnapshot(activeDaysCount: 2, completedCheckinsCount: 0),
        now: now,
      );

      expect(evaluation.canShow, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Frequência (max 1x/dia = 24h)
  // ---------------------------------------------------------------------------
  group('frequência diária (24h)', () {
    test('bloqueia quando último view foi há menos de 24h', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.manual,
        snapshot: baseSnapshot(
          lastPaywallView: now.subtract(const Duration(hours: 2)),
        ),
        now: now,
      );

      expect(evaluation.canShow, isFalse);
      expect(evaluation.blockedReason, PaywallBlockReason.dailyFrequencyCap);
    });

    test('libera quando último view foi há exatamente 24h', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.manual,
        snapshot: baseSnapshot(
          lastPaywallView: now.subtract(const Duration(hours: 24)),
        ),
        now: now,
      );

      expect(evaluation.canShow, isTrue);
    });

    test('libera quando último view foi há mais de 24h', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.featureBlock,
        snapshot: baseSnapshot(
          lastPaywallView: now.subtract(const Duration(hours: 36)),
        ),
        now: now,
      );

      expect(evaluation.canShow, isTrue);
    });

    test('libera quando nunca houve view (lastPaywallView null)', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.manual,
        snapshot: baseSnapshot(lastPaywallView: null),
        now: now,
      );

      expect(evaluation.canShow, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Cooldown (48h após recusa)
  // ---------------------------------------------------------------------------
  group('cooldown de recusa (48h)', () {
    test('bloqueia quando recusa foi há menos de 48h', () {
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

    test('libera quando recusa foi há exatamente 48h', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.manual,
        snapshot: baseSnapshot(
          lastPaywallDismissed: now.subtract(const Duration(hours: 48)),
        ),
        now: now,
      );

      expect(evaluation.canShow, isTrue);
    });

    test('libera quando recusa foi há mais de 48h', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.valueBased,
        snapshot: baseSnapshot(
          lastPaywallDismissed: now.subtract(const Duration(hours: 72)),
        ),
        now: now,
      );

      expect(evaluation.canShow, isTrue);
    });

    test('libera quando nunca houve recusa (lastPaywallDismissed null)', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.featureBlock,
        snapshot: baseSnapshot(lastPaywallDismissed: null),
        now: now,
      );

      expect(evaluation.canShow, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Trigger A: valueBased (valor comprovado / consistência)
  // ---------------------------------------------------------------------------
  group('trigger valueBased (A/B)', () {
    test('bloqueia quando flag valueBasedTrigger está desativada', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.valueBased,
        snapshot: baseSnapshot(valueBasedTriggerEnabled: false),
        now: now,
      );

      expect(evaluation.canShow, isFalse);
      expect(evaluation.blockedReason,
          PaywallBlockReason.valueBasedTriggerDisabled);
    });

    test('bloqueia quando nenhum milestone de valor foi atingido', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.valueBased,
        snapshot: baseSnapshot(activeDaysCount: 2, completedCheckinsCount: 2),
        now: now,
      );

      expect(evaluation.canShow, isFalse);
      expect(evaluation.blockedReason,
          PaywallBlockReason.valueMilestoneNotReached);
      expect(evaluation.valueMilestone, 'none');
    });

    test('libera no milestone checkins_3 (3 check-ins, <3 dias)', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.valueBased,
        snapshot: baseSnapshot(activeDaysCount: 2, completedCheckinsCount: 3),
        now: now,
      );

      expect(evaluation.canShow, isTrue);
      expect(evaluation.valueMilestone, 'checkins_3');
    });

    test('libera no milestone active_days_3 (3 dias, <3 check-ins)', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.valueBased,
        snapshot: baseSnapshot(activeDaysCount: 3, completedCheckinsCount: 1),
        now: now,
      );

      expect(evaluation.canShow, isTrue);
      expect(evaluation.blockedReason, isNull);
      expect(evaluation.valueMilestone, 'active_days_3');
    });

    test('libera no milestone combinado (3 dias + 3 check-ins)', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.valueBased,
        snapshot: baseSnapshot(activeDaysCount: 5, completedCheckinsCount: 4),
        now: now,
      );

      expect(evaluation.canShow, isTrue);
      expect(evaluation.valueMilestone, 'checkins_and_active_days_3');
    });
  });

  // ---------------------------------------------------------------------------
  // Trigger C: featureBlock (intenção)
  // ---------------------------------------------------------------------------
  group('trigger featureBlock (C)', () {
    test('bloqueia quando flag featureBlockTrigger está desativada', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.featureBlock,
        snapshot: baseSnapshot(featureBlockTriggerEnabled: false),
        now: now,
      );

      expect(evaluation.canShow, isFalse);
      expect(evaluation.blockedReason,
          PaywallBlockReason.featureBlockTriggerDisabled);
    });

    test('libera quando flag está ativa e guardrails passam', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.featureBlock,
        snapshot: baseSnapshot(),
        now: now,
      );

      expect(evaluation.canShow, isTrue);
      expect(evaluation.blockedReason, isNull);
    });

    test('featureBlock não exige milestone de valor', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.featureBlock,
        snapshot: baseSnapshot(activeDaysCount: 2, completedCheckinsCount: 0),
        now: now,
      );

      expect(evaluation.canShow, isTrue);
      expect(evaluation.valueMilestone, 'none');
    });
  });

  // ---------------------------------------------------------------------------
  // Trigger manual (ajustes)
  // ---------------------------------------------------------------------------
  group('trigger manual', () {
    test('bloqueia quando flag manual está desativada', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.manual,
        snapshot: baseSnapshot(manualTriggerEnabled: false),
        now: now,
      );

      expect(evaluation.canShow, isFalse);
      expect(
          evaluation.blockedReason, PaywallBlockReason.manualTriggerDisabled);
    });

    test('libera quando flag está ativa e guardrails passam', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.manual,
        snapshot: baseSnapshot(),
        now: now,
      );

      expect(evaluation.canShow, isTrue);
    });

    test('manual não exige milestone de valor', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.manual,
        snapshot: baseSnapshot(activeDaysCount: 2, completedCheckinsCount: 1),
        now: now,
      );

      expect(evaluation.canShow, isTrue);
      expect(evaluation.valueMilestone, 'none');
    });
  });

  // ---------------------------------------------------------------------------
  // enforceTriggerRules = false (canShowPaywall genérico)
  // ---------------------------------------------------------------------------
  group('enforceTriggerRules = false', () {
    test('ignora regras de trigger e valida apenas guardrails globais', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.manual,
        snapshot: baseSnapshot(manualTriggerEnabled: false),
        now: now,
        enforceTriggerRules: false,
      );

      expect(evaluation.canShow, isTrue);
    });

    test('ainda bloqueia por guardrails globais (Pro)', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.valueBased,
        snapshot: baseSnapshot(isPro: true),
        now: now,
        enforceTriggerRules: false,
      );

      expect(evaluation.canShow, isFalse);
      expect(evaluation.blockedReason, PaywallBlockReason.alreadyPro);
    });

    test('ainda bloqueia por frequência mesmo com trigger rules off', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.featureBlock,
        snapshot: baseSnapshot(
          lastPaywallView: now.subtract(const Duration(hours: 1)),
        ),
        now: now,
        enforceTriggerRules: false,
      );

      expect(evaluation.canShow, isFalse);
      expect(evaluation.blockedReason, PaywallBlockReason.dailyFrequencyCap);
    });
  });

  // ---------------------------------------------------------------------------
  // Prioridade de avaliação (ordem dos guardrails)
  // ---------------------------------------------------------------------------
  group('prioridade de avaliação', () {
    test('paywallDisabled tem prioridade sobre alreadyPro', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.manual,
        snapshot: baseSnapshot(paywallEnabled: false, isPro: true),
        now: now,
      );

      expect(evaluation.blockedReason, PaywallBlockReason.paywallDisabled);
    });

    test('alreadyPro tem prioridade sobre firstSession', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.manual,
        snapshot: baseSnapshot(
          isPro: true,
          activeDaysCount: 1,
          completedCheckinsCount: 0,
        ),
        now: now,
      );

      expect(evaluation.blockedReason, PaywallBlockReason.alreadyPro);
    });

    test('firstSession tem prioridade sobre frequência', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.manual,
        snapshot: baseSnapshot(
          activeDaysCount: 1,
          completedCheckinsCount: 0,
          lastPaywallView: now.subtract(const Duration(hours: 1)),
        ),
        now: now,
      );

      expect(
          evaluation.blockedReason, PaywallBlockReason.firstSessionGuardrail);
    });

    test('frequência tem prioridade sobre cooldown', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.manual,
        snapshot: baseSnapshot(
          lastPaywallView: now.subtract(const Duration(hours: 1)),
          lastPaywallDismissed: now.subtract(const Duration(hours: 1)),
        ),
        now: now,
      );

      expect(evaluation.blockedReason, PaywallBlockReason.dailyFrequencyCap);
    });
  });

  // ---------------------------------------------------------------------------
  // PaywallEvaluation.blockedReasonCode
  // ---------------------------------------------------------------------------
  group('PaywallEvaluation.blockedReasonCode', () {
    test('retorna "eligible" quando canShow é true', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.manual,
        snapshot: baseSnapshot(),
        now: now,
      );

      expect(evaluation.blockedReasonCode, 'eligible');
    });

    test('retorna nome do enum quando bloqueado', () {
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.manual,
        snapshot: baseSnapshot(isPro: true),
        now: now,
      );

      expect(evaluation.blockedReasonCode, 'alreadyPro');
    });
  });

  // ---------------------------------------------------------------------------
  // Cenário E2E: simulação de jornada de 3 dias
  // ---------------------------------------------------------------------------
  group('cenário E2E: jornada de 3 dias', () {
    test('dia 1 - primeira sessão - paywall bloqueado', () {
      final day1 = DateTime(2026, 2, 15, 9);
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.valueBased,
        snapshot: baseSnapshot(activeDaysCount: 1, completedCheckinsCount: 0),
        now: day1,
      );

      expect(evaluation.canShow, isFalse);
      expect(
          evaluation.blockedReason, PaywallBlockReason.firstSessionGuardrail);
    });

    test('dia 1 - após primeiro check-in - featureBlock funciona', () {
      final day1After = DateTime(2026, 2, 15, 18);
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.featureBlock,
        snapshot: baseSnapshot(activeDaysCount: 1, completedCheckinsCount: 1),
        now: day1After,
      );

      expect(evaluation.canShow, isTrue);
    });

    test('dia 2 - valueBased ainda bloqueado (sem milestone)', () {
      final day2 = DateTime(2026, 2, 16, 9);
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.valueBased,
        snapshot: baseSnapshot(activeDaysCount: 2, completedCheckinsCount: 1),
        now: day2,
      );

      expect(evaluation.canShow, isFalse);
      expect(evaluation.blockedReason,
          PaywallBlockReason.valueMilestoneNotReached);
    });

    test('dia 3 - consistência atingida - valueBased liberado', () {
      final day3 = DateTime(2026, 2, 17, 9);
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.valueBased,
        snapshot: baseSnapshot(activeDaysCount: 3, completedCheckinsCount: 2),
        now: day3,
      );

      expect(evaluation.canShow, isTrue);
      expect(evaluation.valueMilestone, 'active_days_3');
    });

    test('dia 3 - após recusa - cooldown de 48h bloqueia', () {
      final day3Dismissed = DateTime(2026, 2, 17, 10);
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.valueBased,
        snapshot: baseSnapshot(
          activeDaysCount: 3,
          completedCheckinsCount: 2,
          lastPaywallView: day3Dismissed,
          lastPaywallDismissed: day3Dismissed,
        ),
        now: day3Dismissed.add(const Duration(hours: 1)),
      );

      expect(evaluation.canShow, isFalse);
      expect(evaluation.blockedReason, PaywallBlockReason.dailyFrequencyCap);
    });

    test('dia 5 - cooldown expirou - paywall liberado novamente', () {
      final day3Dismissed = DateTime(2026, 2, 17, 10);
      final day5 = DateTime(2026, 2, 19, 12);
      final evaluation = evaluatePaywallEligibility(
        trigger: PaywallTrigger.valueBased,
        snapshot: baseSnapshot(
          activeDaysCount: 5,
          completedCheckinsCount: 4,
          lastPaywallView: day3Dismissed,
          lastPaywallDismissed: day3Dismissed,
        ),
        now: day5,
      );

      expect(evaluation.canShow, isTrue);
      expect(evaluation.valueMilestone, 'checkins_and_active_days_3');
    });
  });
}
