import 'package:flutter/material.dart';

import '../tokens/design_tokens.dart';

enum AethorButtonSize {
  small,
  medium,
  large,
}

class _AethorButtonSpec {
  const _AethorButtonSpec({
    required this.height,
    required this.horizontalPadding,
    required this.fontSize,
  });

  final double height;
  final double horizontalPadding;
  final double fontSize;
}

_AethorButtonSpec _specFor(AethorButtonSize size) {
  switch (size) {
    case AethorButtonSize.small:
      return const _AethorButtonSpec(
          height: 40, horizontalPadding: 16, fontSize: 13);
    case AethorButtonSize.medium:
      return const _AethorButtonSpec(
          height: 48, horizontalPadding: 24, fontSize: 14);
    case AethorButtonSize.large:
      return const _AethorButtonSpec(
          height: 56, horizontalPadding: 32, fontSize: 15);
  }
}

class AethorPrimaryButton extends StatelessWidget {
  const AethorPrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = AethorButtonSize.medium,
    this.fullWidth = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final AethorButtonSize size;
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
          backgroundColor: AethorColors.deepBlue,
          foregroundColor: AethorColors.ivory,
          disabledBackgroundColor: AethorColors.deepBlue.withValues(alpha: 0.4),
          disabledForegroundColor: AethorColors.ivory.withValues(alpha: 0.75),
          padding: EdgeInsets.symmetric(horizontal: spec.horizontalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AethorRadius.md),
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

class AethorSecondaryButton extends StatelessWidget {
  const AethorSecondaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = AethorButtonSize.medium,
    this.fullWidth = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final AethorButtonSize size;
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
          foregroundColor: AethorColors.stone,
          backgroundColor: Colors.white.withValues(alpha: 0.6),
          disabledForegroundColor: AethorColors.stone.withValues(alpha: 0.5),
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.35),
          side: const BorderSide(
            color: AethorColors.sand,
          ),
          padding: EdgeInsets.symmetric(horizontal: spec.horizontalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AethorRadius.md),
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

class AethorTonalButton extends StatelessWidget {
  const AethorTonalButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = AethorButtonSize.medium,
    this.fullWidth = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final AethorButtonSize size;
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
          backgroundColor: AethorColors.copper.withValues(alpha: 0.1),
          foregroundColor: AethorColors.copper,
          disabledBackgroundColor: AethorColors.copper.withValues(alpha: 0.06),
          disabledForegroundColor: AethorColors.copper.withValues(alpha: 0.5),
          padding: EdgeInsets.symmetric(horizontal: spec.horizontalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AethorRadius.md),
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
