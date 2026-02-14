import 'package:flutter/material.dart';

import '../../../core/design_system/components/components.dart';
import '../../../core/design_system/tokens/design_tokens.dart';

class LoginErrorScreen extends StatelessWidget {
  const LoginErrorScreen({
    super.key,
    required this.onRetry,
    required this.onDismiss,
    this.errorMessage,
  });

  final VoidCallback onRetry;
  final VoidCallback onDismiss;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoicColors.ivory,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AuthStateMessage(
                  type: AuthStateMessageType.error,
                  title: 'Erro ao conectar',
                  subtitle: errorMessage ??
                      'Não foi possível completar o login. Tente novamente.',
                ),
                const SizedBox(height: 32),
                AuthButton(
                  variant: AuthButtonVariant.primary,
                  label: 'Tentar novamente',
                  onPressed: onRetry,
                ),
                const SizedBox(height: 12),
                AuthLink(
                  label: 'Agora não',
                  onPressed: onDismiss,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
