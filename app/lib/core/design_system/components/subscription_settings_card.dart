import 'package:flutter/material.dart';

import '../../domain/subscription.dart';
import '../tokens/design_tokens.dart';

class SubscriptionSettingsCard extends StatelessWidget {
  const SubscriptionSettingsCard({
    super.key,
    required this.status,
    required this.plan,
    this.trialEndsAt,
    this.nextBillingDate,
    required this.onViewPlans,
    required this.onManage,
    required this.onRestore,
  });

  final SubscriptionStatus status;
  final SubscriptionPlan plan;
  final DateTime? trialEndsAt;
  final DateTime? nextBillingDate;
  final VoidCallback onViewPlans;
  final VoidCallback onManage;
  final VoidCallback onRestore;

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (status == SubscriptionStatus.free) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: StoicColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: StoicColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estoicismo Pro',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: StoicColors.obsidian,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Histórico completo, favoritos ilimitados e trilhas guiadas.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: StoicColors.textMuted,
                  ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: onViewPlans,
                    style: FilledButton.styleFrom(
                      backgroundColor: StoicColors.deepBlue,
                      foregroundColor: StoicColors.ivory,
                    ),
                    child: const Text('Ver planos Pro'),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: onRestore,
                  style: TextButton.styleFrom(
                    foregroundColor: StoicColors.textMuted,
                  ),
                  child: const Text('Restaurar compra'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final isTrial = status == SubscriptionStatus.trial;
    final badge = isTrial ? 'Teste ativo' : 'Assinatura ativa';
    final planLabel = plan == SubscriptionPlan.annual ? 'Plano anual' : 'Plano mensal';
    final billingLabel = isTrial
        ? 'Renova em ${trialEndsAt != null ? _formatDate(trialEndsAt!) : '--'}'
        : 'Próxima cobrança: ${nextBillingDate != null ? _formatDate(nextBillingDate!) : '--'}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            StoicColors.deepBlue,
            StoicColors.deepBlue.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: StoicColors.ivory.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: StoicColors.ivory,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                ),
              ),
              const Spacer(),
              Text(
                planLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: StoicColors.ivory,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            billingLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: StoicColors.ivory.withValues(alpha: 0.8),
                ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onManage,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: StoicColors.ivory,
                    side: BorderSide(
                      color: StoicColors.ivory.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Text('Gerenciar assinatura'),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: onRestore,
                style: TextButton.styleFrom(
                  foregroundColor: StoicColors.ivory.withValues(alpha: 0.8),
                ),
                child: const Text('Restaurar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
