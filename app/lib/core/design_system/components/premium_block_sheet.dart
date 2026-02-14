import 'package:flutter/material.dart';

import '../tokens/design_tokens.dart';
import 'paywall_types.dart';

class PremiumBlockSheet extends StatelessWidget {
  const PremiumBlockSheet({
    super.key,
    required this.feature,
    required this.onAction,
  });

  final PremiumFeature feature;
  final ValueChanged<PremiumBlockAction> onAction;

  String get _title {
    switch (feature) {
      case PremiumFeature.fullHistory:
        return 'Histórico completo é um recurso Pro';
      case PremiumFeature.favoritesLimit:
        return 'Favoritos ilimitados são Pro';
      case PremiumFeature.audio:
        return 'Áudios guiados são Pro';
      case PremiumFeature.trail:
        return 'Trilhas guiadas são Pro';
    }
  }

  String get _description {
    switch (feature) {
      case PremiumFeature.fullHistory:
        return 'Acesse todos os registros da sua jornada estoica.';
      case PremiumFeature.favoritesLimit:
        return 'Salve quantas citações quiser para revisitar depois.';
      case PremiumFeature.audio:
        return 'Ouça práticas guiadas com foco e clareza.';
      case PremiumFeature.trail:
        return 'Siga trilhas estruturadas para aprofundar sua prática.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: StoicColors.textSubtle.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: StoicColors.deepBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: StoicColors.deepBlue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: StoicColors.obsidian,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: StoicColors.textMuted,
                              height: 1.5,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: StoicColors.deepBlue,
                  foregroundColor: StoicColors.ivory,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => onAction(PremiumBlockAction.viewPlans),
                child: const Text('Ver planos'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: StoicColors.stone,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: StoicColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => onAction(PremiumBlockAction.continueFree),
                child: const Text('Continuar no gratuito'),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => onAction(PremiumBlockAction.restorePurchase),
                style: TextButton.styleFrom(
                  foregroundColor: StoicColors.textMuted,
                ),
                child: const Text('Restaurar compra'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
