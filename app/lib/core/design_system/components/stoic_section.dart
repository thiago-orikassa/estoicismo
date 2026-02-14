import 'package:flutter/material.dart';

import '../tokens/design_tokens.dart';

class StoicSection extends StatelessWidget {
  const StoicSection({
    super.key,
    required this.title,
    required this.child,
    this.topSpacing = StoicSpacing.lg,
  });

  final String title;
  final Widget child;
  final double topSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: StoicColors.obsidian,
                ),
          ),
          const SizedBox(height: StoicSpacing.sm),
          child,
        ],
      ),
    );
  }
}
