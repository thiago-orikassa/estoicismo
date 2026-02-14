import 'package:flutter/material.dart';

import '../tokens/design_tokens.dart';

enum AuthSpinnerSize { sm, md, lg }

enum AuthSpinnerColor { light, dark }

class AuthLoadingSpinner extends StatelessWidget {
  const AuthLoadingSpinner({
    super.key,
    this.size = AuthSpinnerSize.md,
    this.color = AuthSpinnerColor.dark,
  });

  final AuthSpinnerSize size;
  final AuthSpinnerColor color;

  double get _dimension {
    switch (size) {
      case AuthSpinnerSize.sm:
        return 16;
      case AuthSpinnerSize.md:
        return 24;
      case AuthSpinnerSize.lg:
        return 40;
    }
  }

  Color get _stroke {
    switch (color) {
      case AuthSpinnerColor.light:
        return StoicColors.ivory;
      case AuthSpinnerColor.dark:
        return StoicColors.deepBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _dimension,
      height: _dimension,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(_stroke),
      ),
    );
  }
}
