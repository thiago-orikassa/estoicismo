import 'package:flutter/material.dart';

import '../tokens/design_tokens.dart';

class StoicScaffold extends StatelessWidget {
  const StoicScaffold({
    super.key,
    required this.child,
    this.showNav = true,
    this.maxWidth = 390,
    this.horizontalPadding = 20,
  });

  final Widget child;
  final bool showNav;
  final double maxWidth;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = showNav ? 80.0 : 32.0;

    return Container(
      color: StoicColors.screenBackground,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                0,
                horizontalPadding,
                bottomPadding,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
