import 'package:flutter/material.dart';

import '../../../core/design_system/components/components.dart';
import '../../../core/design_system/motion/motion.dart';
import '../../../core/design_system/tokens/design_tokens.dart';

class EmailSentScreen extends StatelessWidget {
  const EmailSentScreen({
    super.key,
    required this.email,
    required this.onOpenEmail,
    required this.onChangeEmail,
    this.onEnterCode,
  });

  final String email;
  final VoidCallback onOpenEmail;
  final VoidCallback onChangeEmail;
  final VoidCallback? onEnterCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StoicColors.ivory,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StoicFadeSlideIn(
                offsetY: 8,
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: StoicColors.deepBlue,
                      ),
                      child: const Icon(
                        Icons.mail_outline,
                        color: StoicColors.ivory,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Verifique seu e-mail',
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontSize: 32,
                                height: 1.2,
                                color: StoicColors.obsidian,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enviamos um código de acesso para',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: StoicColors.textMuted,
                            height: 1.5,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: StoicColors.obsidian,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (onEnterCode != null) ...[
                AuthButton(
                  variant: AuthButtonVariant.primary,
                  label: 'Inserir código',
                  onPressed: onEnterCode!,
                ),
                const SizedBox(height: 12),
              ],
              AuthButton(
                variant: AuthButtonVariant.secondary,
                label: 'Abrir app de e-mail',
                onPressed: onOpenEmail,
              ),
              const SizedBox(height: 12),
              AuthLink(
                label: 'Usar outro e-mail',
                onPressed: onChangeEmail,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
