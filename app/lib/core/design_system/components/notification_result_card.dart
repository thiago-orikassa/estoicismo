import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../tokens/aethor_icons.dart';
import '../tokens/design_tokens.dart';

enum NotificationResultType {
  granted,
  denied,
}

class NotificationResultCard extends StatelessWidget {
  const NotificationResultCard({
    super.key,
    required this.type,
    this.onAdjustTime,
    this.onGoToSettings,
  });

  final NotificationResultType type;
  final VoidCallback? onAdjustTime;
  final VoidCallback? onGoToSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (type == NotificationResultType.granted) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AethorColors.deepBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AethorRadius.lg),
          border: Border.all(
            color: AethorColors.deepBlue.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AethorColors.deepBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    AethorIcons.check,
                    color: AethorColors.deepBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.notificationResultGrantedTitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AethorColors.deepBlue,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.notificationResultGrantedMessage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                              color: AethorColors.textMuted,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (onAdjustTime != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AethorColors.deepBlue,
                    backgroundColor: Colors.white.withValues(alpha: 0.6),
                    side: BorderSide(
                      color: AethorColors.deepBlue.withValues(alpha: 0.2),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AethorRadius.md),
                    ),
                  ),
                  onPressed: onAdjustTime,
                  child: Text(l10n.notificationResultAdjustTime),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AethorColors.cardBackground,
        borderRadius: BorderRadius.circular(AethorRadius.lg),
        border: Border.all(color: AethorColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AethorColors.stone.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  AethorIcons.info,
                  color: AethorColors.stone.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.notificationResultDeniedTitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AethorColors.obsidian,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.notificationResultDeniedMessage,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                            color: AethorColors.textMuted,
                            height: 1.5,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (onGoToSettings != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AethorColors.deepBlue,
                  foregroundColor: AethorColors.ivory,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AethorRadius.md),
                  ),
                ),
                onPressed: onGoToSettings,
                child: Text(l10n.notificationResultGoToSettings),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
