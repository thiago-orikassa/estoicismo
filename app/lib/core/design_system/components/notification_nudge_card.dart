import 'package:flutter/material.dart';

import '../motion/motion.dart';
import '../tokens/design_tokens.dart';

class NotificationNudgeCard extends StatelessWidget {
  const NotificationNudgeCard({
    super.key,
    required this.onEnable,
    required this.onDismiss,
  });

  final VoidCallback onEnable;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            StoicColors.deepBlue,
            StoicColors.deepBlue.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(StoicRadius.lg),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: StoicColors.ivory.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(StoicRadius.md),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: StoicColors.ivory,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quer manter sua constância?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: StoicColors.ivory,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ative um lembrete diário no melhor horário para você.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: StoicColors.ivory.withValues(alpha: 0.8),
                            height: 1.6,
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
                backgroundColor: StoicColors.ivory,
                foregroundColor: StoicColors.deepBlue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(StoicRadius.md),
                ),
                textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
              ),
              onPressed: onEnable,
              child: const Text('Ativar lembretes'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: StoicPressScale(
              child: TextButton(
                onPressed: onDismiss,
                style: TextButton.styleFrom(
                  foregroundColor: StoicColors.ivory.withValues(alpha: 0.8),
                  textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                ),
                child: const Text('Agora não'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
