import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../features/auth/presentation/email_login_flow.dart';
import '../../features/auth/presentation/login_prompt_sheet.dart';
import '../../features/auth/presentation/login_success_screen.dart';
import 'auth_models.dart';

class AuthFlow {
  static Future<bool> showLoginPrompt(
    BuildContext context, {
    required AppState state,
    required AuthPromptContext contextType,
    bool force = false,
  }) async {
    if (state.isAuthenticated && !force) return false;
    if (!force && !state.canShowLoginPrompt) return false;

    state.markLoginPromptShown();

    final method = await showModalBottomSheet<AuthMethod>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return LoginPromptSheet(
          context: contextType,
          onClose: () => Navigator.of(sheetContext).pop(),
          onSelectMethod: (value) => Navigator.of(sheetContext).pop(value),
        );
      },
    );

    if (method == null) {
      state.markLoginPromptDismissed();
      return false;
    }

    switch (method) {
      case AuthMethod.email:
        final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => const EmailLoginFlow()),
        );
        final loggedIn = result == true;
        if (loggedIn) {
          state.markAuthenticated(true);
        }
        return loggedIn;
      case AuthMethod.apple:
      case AuthMethod.google:
        // TODO: Integrate native OAuth. For now, simulate success.
        final success = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (routeContext) => LoginSuccessScreen(
              onContinue: () => Navigator.of(routeContext).pop(true),
            ),
          ),
        );
        if (success == true) {
          state.markAuthenticated(true);
          return true;
        }
        return false;
    }
  }
}
