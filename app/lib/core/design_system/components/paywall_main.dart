import 'package:flutter/material.dart';

import '../../domain/subscription.dart';
import '../tokens/aethor_icons.dart';
import '../tokens/design_tokens.dart';
import '../../../l10n/app_localizations.dart';
import 'paywall_types.dart';

class PaywallMain extends StatelessWidget {
  const PaywallMain({
    super.key,
    required this.selectedPlan,
    required this.onPlanChange,
    required this.onClose,
    required this.onStartPlan,
    required this.onContinueFree,
    required this.onRestorePurchase,
    this.trigger = PaywallTrigger.manual,
  });

  final SubscriptionPlan selectedPlan;
  final ValueChanged<SubscriptionPlan> onPlanChange;
  final VoidCallback onClose;
  final ValueChanged<SubscriptionPlan> onStartPlan;
  final VoidCallback onContinueFree;
  final VoidCallback onRestorePurchase;
  final PaywallTrigger trigger;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final primaryLabel = selectedPlan == SubscriptionPlan.annual
        ? l10n.paywallButtonAnnual
        : l10n.paywallButtonMonthly;

    return Material(
      color: AethorColors.obsidian,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      l10n.paywallMainTitle,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontFamily: 'Cormorant Garamond',
                            fontStyle: FontStyle.italic,
                            fontSize: 32,
                            color: AethorColors.ivory,
                            height: 1.1,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.paywallMainDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AethorColors.sand,
                            height: 1.5,
                          ),
                    ),
                    const SizedBox(height: 24),
                    _ValueBullets(),
                    const SizedBox(height: 24),
                    _PlanSelector(
                      selectedPlan: selectedPlan,
                      onPlanChange: onPlanChange,
                    ),
                    const SizedBox(height: 20),
                    _ComparisonTable(),
                    const SizedBox(height: 20),
                    Text(
                      l10n.paywallCancelNotice,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AethorColors.sand.withValues(alpha: 0.8),
                          ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AethorColors.copper,
                          foregroundColor: AethorColors.ivory,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => onStartPlan(selectedPlan),
                        child: Text(primaryLabel),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AethorColors.ivory,
                          side: BorderSide(
                            color: AethorColors.sand.withValues(alpha: 0.3),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: onContinueFree,
                        child: Text(l10n.paywallContinueFree),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: onRestorePurchase,
                        style: TextButton.styleFrom(
                          foregroundColor: AethorColors.sand,
                        ),
                        child: Text(l10n.paywallRestorePurchase),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: onClose,
                icon: const Icon(AethorIcons.close, color: AethorColors.ivory),
                tooltip: l10n.actionClose,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueBullets extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = [
      l10n.paywallBullet1,
      l10n.paywallBullet2,
      l10n.paywallBullet3,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AethorColors.copper,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AethorColors.ivory,
                            height: 1.5,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PlanSelector extends StatelessWidget {
  const _PlanSelector({
    required this.selectedPlan,
    required this.onPlanChange,
  });

  final SubscriptionPlan selectedPlan;
  final ValueChanged<SubscriptionPlan> onPlanChange;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        _PlanCard(
          title: l10n.paywallPlanAnnualTitle,
          subtitle: l10n.paywallPlanAnnualSubtitle,
          price: 'R\$ 149,00/ano',
          highlight: l10n.paywallPlanAnnualHighlight,
          selected: selectedPlan == SubscriptionPlan.annual,
          onTap: () => onPlanChange(SubscriptionPlan.annual),
        ),
        const SizedBox(height: 12),
        _PlanCard(
          title: l10n.paywallPlanMonthlyTitle,
          subtitle: l10n.paywallPlanMonthlySubtitle,
          price: 'R\$ 19,90/mês',
          selected: selectedPlan == SubscriptionPlan.monthly,
          onTap: () => onPlanChange(SubscriptionPlan.monthly),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.selected,
    required this.onTap,
    this.highlight,
  });

  final String title;
  final String subtitle;
  final String price;
  final String? highlight;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AethorColors.copper.withValues(alpha: 0.15)
          : AethorColors.stone,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? AethorColors.copper
                  : AethorColors.sand.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AethorColors.ivory,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AethorColors.sand,
                          ),
                    ),
                    if (highlight != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AethorColors.copper.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          highlight!,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AethorColors.ivory,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                price,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AethorColors.ivory,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rows = [
      (l10n.paywallComparisonFeature1, true, true),
      (l10n.paywallComparisonFeature2, false, true),
      (l10n.paywallComparisonFeature3, false, true),
      (l10n.paywallComparisonFeature4, false, true),
      (l10n.paywallComparisonFeature5, false, true),
      (l10n.paywallComparisonFeature6, false, true),
      (l10n.paywallComparisonFeature7, false, true),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AethorColors.stone.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AethorColors.sand.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child:
                    Text(l10n.paywallComparisonHeaderFeatures, style: const TextStyle(color: AethorColors.sand)),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.paywallComparisonHeaderFree,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AethorColors.sand,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 16),
              Text(
                l10n.paywallComparisonHeaderPro,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AethorColors.ivory,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row.$1,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AethorColors.ivory,
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _CheckMark(enabled: row.$2),
                  const SizedBox(width: 16),
                  _CheckMark(enabled: row.$3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckMark extends StatelessWidget {
  const _CheckMark({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Icon(
      enabled ? AethorIcons.check : AethorIcons.close,
      size: 18,
      color: enabled ? AethorColors.copper : AethorColors.sand,
    );
  }
}
