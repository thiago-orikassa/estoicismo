import 'package:flutter/material.dart';

import '../../domain/subscription.dart';
import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    if (status == SubscriptionStatus.free) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AethorColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AethorColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.subscriptionProTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AethorColors.obsidian,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.subscriptionProDescription,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AethorColors.textMuted,
                  ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: onViewPlans,
                    style: FilledButton.styleFrom(
                      backgroundColor: AethorColors.deepBlue,
                      foregroundColor: AethorColors.ivory,
                    ),
                    child: Text(l10n.subscriptionViewPlansBtn),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: onRestore,
                  style: TextButton.styleFrom(
                    foregroundColor: AethorColors.textMuted,
                  ),
                  child: Text(l10n.subscriptionRestoreBtn),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final isTrial = status == SubscriptionStatus.trial;
    final badge = isTrial ? l10n.subscriptionBadgeTrialActive : l10n.subscriptionBadgeSubscriptionActive;
    final planLabel = plan == SubscriptionPlan.annual ? l10n.subscriptionPlanAnnual : l10n.subscriptionPlanMonthly;
    final billingLabel = isTrial
        ? '${l10n.subscriptionTrialRenewal} ${trialEndsAt != null ? _formatDate(trialEndsAt!) : '--'}'
        : '${l10n.subscriptionNextBilling} ${nextBillingDate != null ? _formatDate(nextBillingDate!) : '--'}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AethorColors.deepBlue,
            AethorColors.deepBlue.withValues(alpha: 0.85),
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
                  color: AethorColors.ivory.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AethorColors.ivory,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                ),
              ),
              const Spacer(),
              Text(
                planLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AethorColors.ivory,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            billingLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AethorColors.ivory.withValues(alpha: 0.8),
                ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onManage,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AethorColors.ivory,
                    side: BorderSide(
                      color: AethorColors.ivory.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(l10n.subscriptionManageBtn),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: onRestore,
                style: TextButton.styleFrom(
                  foregroundColor: AethorColors.ivory.withValues(alpha: 0.8),
                ),
                child: Text(l10n.subscriptionRestoreTextBtn),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
