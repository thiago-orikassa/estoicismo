import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      backgroundColor: AethorColors.obsidian,
      body: SafeArea(
        child: Center(
          child: AethorFadeIn(
            duration: MotionTokens.standard,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/aethor_logo.svg',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 24),
                Text(
                  'Clareza para agir.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AethorColors.sand,
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
                          color: AethorColors.sand.withValues(alpha: 0.6),
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
