import 'package:flutter/material.dart';

import '../tokens/design_tokens.dart';

enum StoicButtonSize {
  small,
  medium,
  large,
}

class _StoicButtonSpec {
  const _StoicButtonSpec({
    required this.height,
    required this.horizontalPadding,
    required this.fontSize,
  });

  final double height;
  final double horizontalPadding;
  final double fontSize;
}

_StoicButtonSpec _specFor(StoicButtonSize size) {
  switch (size) {
    case StoicButtonSize.small:
      return const _StoicButtonSpec(
          height: 40, horizontalPadding: 16, fontSize: 13);
    case StoicButtonSize.medium:
      return const _StoicButtonSpec(
          height: 48, horizontalPadding: 24, fontSize: 14);
    case StoicButtonSize.large:
      return const _StoicButtonSpec(
          height: 56, horizontalPadding: 32, fontSize: 15);
  }
}

class StoicPrimaryButton extends StatelessWidget {
  const StoicPrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = StoicButtonSize.medium,
    this.fullWidth = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final StoicButtonSize size;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final spec = _specFor(size);
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: spec.height,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: StoicColors.deepBlue,
          foregroundColor: StoicColors.ivory,
          disabledBackgroundColor: StoicColors.deepBlue.withValues(alpha: 0.4),
          disabledForegroundColor: StoicColors.ivory.withValues(alpha: 0.75),
          padding: EdgeInsets.symmetric(horizontal: spec.horizontalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StoicRadius.md),
          ),
          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: spec.fontSize,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
        ),
        child: child,
      ),
    );
  }
}

class StoicSecondaryButton extends StatelessWidget {
  const StoicSecondaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = StoicButtonSize.medium,
    this.fullWidth = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final StoicButtonSize size;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final spec = _specFor(size);
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: spec.height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: StoicColors.stone,
          backgroundColor: Colors.white.withValues(alpha: 0.6),
          disabledForegroundColor: StoicColors.stone.withValues(alpha: 0.5),
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.35),
          side: const BorderSide(
            color: StoicColors.sand,
          ),
          padding: EdgeInsets.symmetric(horizontal: spec.horizontalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StoicRadius.md),
          ),
          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: spec.fontSize,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
        ),
        child: child,
      ),
    );
  }
}

class StoicTonalButton extends StatelessWidget {
  const StoicTonalButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = StoicButtonSize.medium,
    this.fullWidth = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final StoicButtonSize size;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final spec = _specFor(size);
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: spec.height,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: StoicColors.copper.withValues(alpha: 0.1),
          foregroundColor: StoicColors.copper,
          disabledBackgroundColor: StoicColors.copper.withValues(alpha: 0.06),
          disabledForegroundColor: StoicColors.copper.withValues(alpha: 0.5),
          padding: EdgeInsets.symmetric(horizontal: spec.horizontalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StoicRadius.md),
          ),
          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: spec.fontSize,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
        ),
        child: child,
      ),
    );
  }
}
