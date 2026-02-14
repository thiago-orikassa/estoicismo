import 'package:flutter/material.dart';

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
    if (type == NotificationResultType.granted) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: StoicColors.deepBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: StoicColors.deepBlue.withValues(alpha: 0.2),
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
                    color: StoicColors.deepBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: StoicColors.deepBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lembrete diário ativado',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: StoicColors.deepBlue,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Você receberá um lembrete todos os dias.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: StoicColors.textMuted,
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
                    foregroundColor: StoicColors.deepBlue,
                    backgroundColor: Colors.white.withValues(alpha: 0.6),
                    side: BorderSide(
                      color: StoicColors.deepBlue.withValues(alpha: 0.2),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: onAdjustTime,
                  child: const Text('Ajustar horário'),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: StoicColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: StoicColors.border),
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
                  color: StoicColors.stone.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: StoicColors.stone.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sem problema',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: StoicColors.obsidian,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Você pode ativar lembretes depois em Ajustes.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: StoicColors.textMuted,
                            height: 1.4,
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
                  backgroundColor: StoicColors.deepBlue,
                  foregroundColor: StoicColors.ivory,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: onGoToSettings,
                child: const Text('Ir para Ajustes'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
