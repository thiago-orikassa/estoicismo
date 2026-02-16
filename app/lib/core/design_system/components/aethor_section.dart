import 'package:flutter/material.dart';

import '../tokens/design_tokens.dart';

enum AethorSectionSpacing {
  tight,
  normal,
  relaxed,
}

class AethorSection extends StatelessWidget {
  const AethorSection({
    super.key,
    required this.children,
    this.spacing = AethorSectionSpacing.normal,
    this.padding,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final List<Widget> children;
  final AethorSectionSpacing spacing;
  final EdgeInsetsGeometry? padding;
  final CrossAxisAlignment crossAxisAlignment;

  double _gapFor(AethorSectionSpacing value) {
    switch (value) {
      case AethorSectionSpacing.tight:
        return AethorSpacing.md;
      case AethorSectionSpacing.normal:
        return AethorSpacing.xl;
      case AethorSectionSpacing.relaxed:
        return AethorSpacing.xxl;
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
