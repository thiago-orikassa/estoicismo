import 'package:flutter/material.dart';

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
    return Material(
      color: StoicColors.obsidian.withValues(alpha: 0.96),
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
                  color: StoicColors.copper.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 32,
                  color: StoicColors.copper,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isTrial ? 'Teste iniciado com sucesso' : 'Pro ativado com sucesso',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: StoicColors.ivory,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isTrial
                    ? 'Aproveite 7 dias gratuitos para explorar todos os recursos.'
                    : 'Sua assinatura está ativa. Aproveite os recursos Pro.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: StoicColors.sand,
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
                    backgroundColor: StoicColors.copper,
                    foregroundColor: StoicColors.ivory,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: onPrimary,
                  child: const Text('Continuar'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onClose,
                style: TextButton.styleFrom(
                  foregroundColor: StoicColors.sand,
                ),
                child: const Text('Voltar ao início'),
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
    final features = [
      'Histórico completo',
      'Favoritos ilimitados',
      'Trilhas guiadas',
      'Áudios práticos',
    ];
    return Column(
      children: features
          .map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_rounded,
                      color: StoicColors.copper, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    feature,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: StoicColors.ivory,
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
