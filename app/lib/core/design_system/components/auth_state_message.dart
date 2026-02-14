import 'package:flutter/material.dart';

import '../motion/motion.dart';
import '../tokens/design_tokens.dart';

enum AuthStateMessageType { success, error }

class AuthStateMessage extends StatelessWidget {
  const AuthStateMessage({
    super.key,
    required this.type,
    required this.title,
    this.subtitle,
  });

  final AuthStateMessageType type;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final isSuccess = type == AuthStateMessageType.success;
    final icon = isSuccess ? Icons.check_rounded : Icons.error_outline;
    final iconBackground =
        isSuccess ? StoicColors.deepBlue : StoicColors.copper;

    return StoicFadeSlideIn(
      offsetY: 8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: StoicColors.ivory, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: StoicColors.obsidian,
                ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: StoicColors.textMuted,
                    height: 1.4,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
