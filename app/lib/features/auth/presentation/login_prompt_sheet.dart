import 'package:flutter/material.dart';

import '../../../core/auth/auth_models.dart';
import '../../../core/design_system/components/components.dart';
import '../../../core/design_system/motion/motion.dart';
import '../../../core/design_system/tokens/design_tokens.dart';

class LoginPromptSheet extends StatelessWidget {
  const LoginPromptSheet({
    super.key,
    required this.context,
    required this.onClose,
    required this.onSelectMethod,
  });

  final AuthPromptContext context;
  final VoidCallback onClose;
  final ValueChanged<AuthMethod> onSelectMethod;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        decoration: const BoxDecoration(
          color: StoicColors.ivory,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: onClose,
                style: IconButton.styleFrom(
                  backgroundColor: StoicColors.stone.withValues(alpha: 0.1),
                ),
                icon: const Icon(Icons.close, color: StoicColors.obsidian),
              ),
            ),
            const SizedBox(height: 8),
            StoicFadeSlideIn(
              offsetY: 8,
              child: Column(
                children: [
                  Text(
                    'Salve seu progresso',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 32,
                          height: 1.2,
                          color: StoicColors.obsidian,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sincronize check-ins, favoritos e histórico entre dispositivos.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: StoicColors.textMuted,
                          height: 1.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                AuthButton(
                  variant: AuthButtonVariant.apple,
                  label: 'Continuar com Apple',
                  onPressed: () => onSelectMethod(AuthMethod.apple),
                ),
                const SizedBox(height: 12),
                AuthButton(
                  variant: AuthButtonVariant.google,
                  label: 'Continuar com Google',
                  onPressed: () => onSelectMethod(AuthMethod.google),
                ),
                const SizedBox(height: 12),
                AuthButton(
                  variant: AuthButtonVariant.email,
                  label: 'Entrar com e-mail',
                  onPressed: () => onSelectMethod(AuthMethod.email),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AuthLink(
              label: 'Agora não',
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}
