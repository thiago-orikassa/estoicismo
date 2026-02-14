import 'package:flutter/material.dart';

import '../motion/motion.dart';
import '../tokens/design_tokens.dart';

enum AuthButtonVariant { apple, google, email, primary, secondary }

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.variant,
    required this.label,
    required this.onPressed,
    this.disabled = false,
  });

  final AuthButtonVariant variant;
  final String label;
  final VoidCallback onPressed;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final colors = _AuthButtonColors.fromVariant(variant);
    final isDisabled = disabled;

    return StoicPressScale(
      enabled: !isDisabled,
      child: Opacity(
        opacity: isDisabled ? 0.4 : 1.0,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: isDisabled ? null : onPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: colors.background,
              foregroundColor: colors.foreground,
              side: BorderSide(color: colors.border, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(StoicRadius.md),
              ),
              textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

class AuthLink extends StatelessWidget {
  const AuthLink({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                decoration: TextDecoration.underline,
                decorationColor: StoicColors.stone,
                color: StoicColors.stone,
              ),
        ),
      ),
    );
  }
}

class _AuthButtonColors {
  const _AuthButtonColors({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;

  static _AuthButtonColors fromVariant(AuthButtonVariant variant) {
    switch (variant) {
      case AuthButtonVariant.apple:
        return const _AuthButtonColors(
          background: StoicColors.obsidian,
          foreground: StoicColors.ivory,
          border: StoicColors.obsidian,
        );
      case AuthButtonVariant.google:
        return const _AuthButtonColors(
          background: StoicColors.ivory,
          foreground: StoicColors.obsidian,
          border: StoicColors.sand,
        );
      case AuthButtonVariant.email:
      case AuthButtonVariant.primary:
        return const _AuthButtonColors(
          background: StoicColors.deepBlue,
          foreground: StoicColors.ivory,
          border: StoicColors.deepBlue,
        );
      case AuthButtonVariant.secondary:
        return const _AuthButtonColors(
          background: Colors.transparent,
          foreground: StoicColors.stone,
          border: Colors.transparent,
        );
    }
  }
}
