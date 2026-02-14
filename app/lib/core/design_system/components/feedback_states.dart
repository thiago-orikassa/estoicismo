import 'package:flutter/material.dart';

import '../motion/motion.dart';
import '../tokens/design_tokens.dart';
import 'stoic_card.dart';

class StoicLoadingState extends StatelessWidget {
  const StoicLoadingState({
    super.key,
    this.message = 'Carregando conteúdo...',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return StoicCard(
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class StoicEmptyState extends StatelessWidget {
  const StoicEmptyState({
    super.key,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return StoicFadeIn(
      child: StoicCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            if (description != null) ...[
              const SizedBox(height: 6),
              Text(description!),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              StoicPressScale(
                child: FilledButton.tonal(
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class StoicErrorState extends StatelessWidget {
  const StoicErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return StoicFadeIn(
      child: StoicCard(
        child: Row(
          children: [
            Expanded(child: Text(message)),
            TextButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class StoicOfflineBanner extends StatelessWidget {
  const StoicOfflineBanner({
    super.key,
    required this.onSync,
  });

  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: StoicColors.deepBlue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: StoicColors.deepBlue.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: StoicColors.deepBlue,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Você está offline. Mostrando conteúdo em cache.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: StoicColors.deepBlue,
                    height: 1.4,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onSync,
            style: TextButton.styleFrom(
              foregroundColor: StoicColors.deepBlue,
              textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
            ),
            child: const Text('Sincronizar'),
          ),
        ],
      ),
    );
  }
}
