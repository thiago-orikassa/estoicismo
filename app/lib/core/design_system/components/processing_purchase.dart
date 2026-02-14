import 'package:flutter/material.dart';

import '../tokens/design_tokens.dart';

class ProcessingPurchaseOverlay extends StatelessWidget {
  const ProcessingPurchaseOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: StoicColors.obsidian.withValues(alpha: 0.92),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(StoicColors.copper),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Confirmando sua assinatura...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: StoicColors.ivory,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
