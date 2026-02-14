import 'package:flutter/material.dart';

import '../tokens/design_tokens.dart';

enum StoicSectionSpacing {
  tight,
  normal,
  relaxed,
}

class StoicSection extends StatelessWidget {
  const StoicSection({
    super.key,
    required this.children,
    this.spacing = StoicSectionSpacing.normal,
    this.padding,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final List<Widget> children;
  final StoicSectionSpacing spacing;
  final EdgeInsetsGeometry? padding;
  final CrossAxisAlignment crossAxisAlignment;

  double _gapFor(StoicSectionSpacing value) {
    switch (value) {
      case StoicSectionSpacing.tight:
        return StoicSpacing.md;
      case StoicSectionSpacing.normal:
        return StoicSpacing.xl;
      case StoicSectionSpacing.relaxed:
        return StoicSpacing.xxl;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gap = _gapFor(spacing);
    final spacedChildren = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) spacedChildren.add(SizedBox(height: gap));
      spacedChildren.add(children[i]);
    }

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: spacedChildren,
      ),
    );
  }
}
