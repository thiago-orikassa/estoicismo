import 'package:flutter/material.dart';

import '../tokens/design_tokens.dart';

enum StoicCardVariant {
  defaultCard,
  subtle,
}

class StoicCard extends StatelessWidget {
  const StoicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(StoicSpacing.md),
    this.variant = StoicCardVariant.defaultCard,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final StoicCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final color = switch (variant) {
      StoicCardVariant.defaultCard => StoicColors.surface,
      StoicCardVariant.subtle => StoicColors.cardBackground,
    };
    final borderColor = switch (variant) {
      StoicCardVariant.defaultCard => StoicColors.cardOutline,
      StoicCardVariant.subtle => Colors.transparent,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(StoicRadius.lg),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
