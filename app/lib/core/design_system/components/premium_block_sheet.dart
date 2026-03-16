import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../tokens/aethor_icons.dart';
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

  String _title(AppLocalizations l10n) {
    switch (feature) {
      case PremiumFeature.fullHistory:
        return l10n.premiumFullhistoryTitle;
      case PremiumFeature.favoritesLimit:
        return l10n.premiumFavoriteslimitTitle;
      case PremiumFeature.audio:
        return l10n.premiumAudioTitle;
      case PremiumFeature.trail:
        return l10n.premiumTrailTitle;
    }
  }

  String _description(AppLocalizations l10n) {
    switch (feature) {
      case PremiumFeature.fullHistory:
        return l10n.premiumFullhistoryDescription;
      case PremiumFeature.favoritesLimit:
        return l10n.premiumFavoriteslimitDescription;
      case PremiumFeature.audio:
        return l10n.premiumAudioDescription;
      case PremiumFeature.trail:
        return l10n.premiumTrailDescription;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                  color: AethorColors.textSubtle.withValues(alpha: 0.3),
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
                    color: AethorColors.deepBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    AethorIcons.lock,
                    color: AethorColors.deepBlue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _title(l10n),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AethorColors.obsidian,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _description(l10n),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AethorColors.textMuted,
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
                  backgroundColor: AethorColors.deepBlue,
                  foregroundColor: AethorColors.ivory,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => onAction(PremiumBlockAction.viewPlans),
                child: Text(l10n.premiumViewPlans),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AethorColors.stone,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AethorColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => onAction(PremiumBlockAction.continueFree),
                child: Text(l10n.premiumContinueFree),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => onAction(PremiumBlockAction.restorePurchase),
                style: TextButton.styleFrom(
                  foregroundColor: AethorColors.textMuted,
                ),
                child: Text(l10n.premiumRestorePurchase),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
