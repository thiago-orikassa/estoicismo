import 'package:flutter/material.dart';

import '../motion/motion.dart';
import '../tokens/design_tokens.dart';
import 'stoic_buttons.dart';

class StoicLoadingState extends StatelessWidget {
  const StoicLoadingState({
    super.key,
    this.message = 'Carregando conteúdo...',
    this.subtitle = 'Buscando sua prática diária',
  });

  final String message;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 600),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                backgroundColor: StoicColors.sand,
                valueColor: AlwaysStoppedAnimation<Color>(StoicColors.copper),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: StoicColors.obsidian,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: StoicColors.textMuted,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
    this.icon,
  });

  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return StoicFadeIn(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 400),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null)
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: StoicColors.sand.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: icon),
                  ),
                if (icon != null) const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: StoicColors.obsidian,
                      ),
                  textAlign: TextAlign.center,
                ),
                if (description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 14,
                          color: StoicColors.textMuted,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 24),
                  StoicPressScale(
                    child: StoicPrimaryButton(
                      onPressed: onAction,
                      size: StoicButtonSize.medium,
                      child: Text(actionLabel!),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StoicErrorState extends StatelessWidget {
  const StoicErrorState({
    super.key,
    this.title = 'Não foi possível carregar',
    this.message = 'Verifique sua conexão e tente novamente.',
    required this.onRetry,
    this.retryLabel = 'Tentar novamente',
  });

  final String title;
  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return StoicFadeIn(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 600),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: StoicColors.copper.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: StoicColors.copper,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: StoicColors.obsidian,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 14,
                        height: 1.6,
                        color: StoicColors.textSecondarySoft,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                StoicPressScale(
                  child: StoicPrimaryButton(
                    onPressed: onRetry,
                    size: StoicButtonSize.medium,
                    fullWidth: true,
                    child: Text(retryLabel),
                  ),
                ),
              ],
            ),
          ),
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
        color: StoicColors.deepBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(StoicRadius.md),
        border: Border.all(color: StoicColors.deepBlue.withValues(alpha: 0.2)),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modo offline',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: StoicColors.deepBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  'Mostrando conteúdo em cache',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: StoicColors.textMuted,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onSync,
            style: TextButton.styleFrom(
              foregroundColor: StoicColors.deepBlue,
              backgroundColor: StoicColors.deepBlue.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                  ),
            ),
            child: const Text('SINCRONIZAR'),
          ),
        ],
      ),
    );
  }
}
