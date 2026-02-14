import 'package:flutter/material.dart';

import '../../domain/subscription.dart';
import '../tokens/design_tokens.dart';
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
    final primaryLabel = selectedPlan == SubscriptionPlan.annual
        ? 'Iniciar 7 dias grátis'
        : 'Assinar agora';

    return Material(
      color: StoicColors.obsidian,
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
                      'Evolua sua prática estoica com profundidade',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontFamily: 'Cormorant Garamond',
                            fontStyle: FontStyle.italic,
                            fontSize: 32,
                            color: StoicColors.ivory,
                            height: 1.1,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ritual diário sem bloqueio, com recursos completos para quem quer ir além.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: StoicColors.sand,
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
                      'Cancele quando quiser. Sem compromisso.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: StoicColors.sand.withValues(alpha: 0.8),
                          ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: StoicColors.copper,
                          foregroundColor: StoicColors.ivory,
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
                          foregroundColor: StoicColors.ivory,
                          side: BorderSide(
                            color: StoicColors.sand.withValues(alpha: 0.3),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: onContinueFree,
                        child: const Text('Continuar no gratuito'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: onRestorePurchase,
                        style: TextButton.styleFrom(
                          foregroundColor: StoicColors.sand,
                        ),
                        child: const Text('Restaurar compra'),
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
                icon: const Icon(Icons.close_rounded, color: StoicColors.ivory),
                tooltip: 'Fechar',
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
    final items = [
      'Histórico completo e ilimitado.',
      'Favoritos sem limite e revisita rápida.',
      'Trilhas guiadas para aprofundar a prática.',
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
                      color: StoicColors.copper,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: StoicColors.ivory,
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
    return Column(
      children: [
        _PlanCard(
          title: 'Plano Anual',
          subtitle: '7 dias grátis',
          price: 'R\$ 119,90/ano',
          highlight: 'Melhor custo-benefício',
          selected: selectedPlan == SubscriptionPlan.annual,
          onTap: () => onPlanChange(SubscriptionPlan.annual),
        ),
        const SizedBox(height: 12),
        _PlanCard(
          title: 'Plano Mensal',
          subtitle: 'Pagamento mensal',
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
      color: selected ? StoicColors.copper.withValues(alpha: 0.15) : StoicColors.stone,
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
                  ? StoicColors.copper
                  : StoicColors.sand.withValues(alpha: 0.2),
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
                            color: StoicColors.ivory,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: StoicColors.sand,
                          ),
                    ),
                    if (highlight != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: StoicColors.copper.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          highlight!,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: StoicColors.ivory,
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
                      color: StoicColors.ivory,
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
    final rows = [
      ('Citação + prática diária', true, true),
      ('Histórico completo', false, true),
      ('Favoritos ilimitados', false, true),
      ('Áudios práticos', false, true),
      ('Trilhas guiadas', false, true),
      ('Personalização avançada', false, true),
      ('Suporte prioritário', false, true),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StoicColors.stone.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StoicColors.sand.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Recursos', style: TextStyle(color: StoicColors.sand)),
              ),
              const SizedBox(width: 12),
              Text(
                'Free',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: StoicColors.sand,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 16),
              Text(
                'Pro',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: StoicColors.ivory,
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
                            color: StoicColors.ivory,
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
      enabled ? Icons.check_rounded : Icons.close_rounded,
      size: 18,
      color: enabled ? StoicColors.copper : StoicColors.sand,
    );
  }
}
