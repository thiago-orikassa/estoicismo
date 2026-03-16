import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../tokens/aethor_icons.dart';
import '../tokens/design_tokens.dart';

class SubscriptionSuccessOverlay extends StatelessWidget {
  const SubscriptionSuccessOverlay({
    super.key,
    required this.isTrial,
    required this.onPrimary,
    required this.onClose,
  });

  final bool isTrial;
  final VoidCallback onPrimary;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: AethorColors.obsidian.withValues(alpha: 0.96),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AethorColors.copper.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  AethorIcons.check,
                  size: 32,
                  color: AethorColors.copper,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isTrial ? l10n.subscriptionSuccessTrialTitle : l10n.subscriptionSuccessProTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AethorColors.ivory,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isTrial ? l10n.subscriptionSuccessTrialMessage : l10n.subscriptionSuccessProMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AethorColors.sand,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _FeatureList(),
              const Spacer(),
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
                  onPressed: onPrimary,
                  child: Text(l10n.subscriptionSuccessContinue),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onClose,
                style: TextButton.styleFrom(
                  foregroundColor: AethorColors.sand,
                ),
                child: Text(l10n.subscriptionSuccessBack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final features = [
      l10n.subscriptionSuccessFeature1,
      l10n.subscriptionSuccessFeature2,
      l10n.subscriptionSuccessFeature3,
      l10n.subscriptionSuccessFeature4,
    ];
    return Column(
      children: features
          .map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(AethorIcons.check,
                      color: AethorColors.copper, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    feature,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AethorColors.ivory,
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
