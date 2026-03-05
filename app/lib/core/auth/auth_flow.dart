import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../features/auth/presentation/email_login_flow.dart';
import '../../features/auth/presentation/login_prompt_sheet.dart';
import '../../features/auth/presentation/login_success_screen.dart';
import 'auth_models.dart';
import 'oauth_service.dart';

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
          MaterialPageRoute(builder: (_) => EmailLoginFlow(state: state)),
        );
        final loggedIn = result == true;
        if (loggedIn) {
          await state.refreshSession();
          state.markAuthenticated(true);
        }
        return loggedIn;
      case AuthMethod.apple:
      case AuthMethod.google:
        final OAuthCredential? credential;
        try {
          credential = method == AuthMethod.apple
              ? await OAuthService.signInWithApple()
              : await OAuthService.signInWithGoogle();
        } catch (_) {
          return false;
        }
        if (credential == null) return false;

        final bool oauthResult;
        try {
          oauthResult = await state.authenticateWithOAuth(
            provider: credential.provider,
            identityToken: credential.identityToken,
            email: credential.email,
          );
        } catch (_) {
          return false;
        }

        if (oauthResult) {
          await Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (ctx) => LoginSuccessScreen(
                onContinue: () => Navigator.of(ctx).pop(),
              ),
            ),
          );
          return true;
        }
        return false;
    }
  }
}
