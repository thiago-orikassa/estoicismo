import 'package:flutter/material.dart';

import '../tokens/design_tokens.dart';

enum AethorCardVariant {
  defaultCard,
  subtle,
}

class AethorCard extends StatelessWidget {
  const AethorCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AethorSpacing.md),
    this.variant = AethorCardVariant.defaultCard,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final AethorCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final color = switch (variant) {
      AethorCardVariant.defaultCard => AethorColors.cardBackground,
      AethorCardVariant.subtle =>
        AethorColors.cardBackground.withValues(alpha: 0.5),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AethorRadius.lg),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
