import 'package:flutter/material.dart';

import '../../../core/design_system/components/components.dart';
import '../../../core/design_system/motion/motion.dart';
import '../../../core/design_system/tokens/design_tokens.dart';

class AuthSplashScreen extends StatelessWidget {
  const AuthSplashScreen({
    super.key,
    required this.showLoading,
  });

  final bool showLoading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoicColors.obsidian,
      body: SafeArea(
        child: Center(
          child: StoicFadeIn(
            duration: MotionTokens.standard,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Estoicismo',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: StoicColors.ivory,
                        fontSize: 52,
                        height: 1.1,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Clareza para agir.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: StoicColors.sand,
                        fontSize: 16,
                      ),
                ),
                if (showLoading) ...[
                  const SizedBox(height: 32),
                  const AuthLoadingSpinner(
                    size: AuthSpinnerSize.md,
                    color: AuthSpinnerColor.light,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Preparando seu insight de hoje...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: StoicColors.sand.withValues(alpha: 0.6),
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
