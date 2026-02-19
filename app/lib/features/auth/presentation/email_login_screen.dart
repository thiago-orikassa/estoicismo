import 'package:flutter/material.dart';

import '../../../core/design_system/components/components.dart';
import '../../../core/design_system/motion/motion.dart';
import '../../../core/design_system/tokens/aethor_icons.dart';
import '../../../core/design_system/tokens/design_tokens.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({
    super.key,
    required this.onBack,
    required this.onSubmit,
    required this.onDismiss,
  });

  final VoidCallback onBack;
  final ValueChanged<String> onSubmit;
  final VoidCallback onDismiss;

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  String _email = '';
  String? _error;
  bool _isLoading = false;

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(email);
  }

  Future<void> _handleSubmit() async {
    setState(() => _error = null);

    if (_email.trim().isEmpty) {
      setState(() => _error = 'Digite seu e-mail');
      return;
    }

    if (!_isValidEmail(_email.trim())) {
      setState(() => _error = 'E-mail inválido');
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;
    setState(() => _isLoading = false);
    widget.onSubmit(_email.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AethorColors.ivory,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: widget.onBack,
                style: IconButton.styleFrom(
                  backgroundColor: AethorColors.stone.withValues(alpha: 0.1),
                ),
                icon:
                    const Icon(AethorIcons.chevronLeft, color: AethorColors.obsidian),
              ),
              const SizedBox(height: 24),
              AethorFadeSlideIn(
                offsetY: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Entrar com e-mail',
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontSize: 36,
                                height: 1.2,
                                color: AethorColors.obsidian,
                              ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Você receberá um código para entrar sem senha.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AethorColors.textMuted,
                            height: 1.5,
                          ),
                    ),
                    const SizedBox(height: 32),
                    AuthEmailField(
                      value: _email,
                      onChanged: (value) => setState(() => _email = value),
                      onSubmitted: _handleSubmit,
                      error: _error,
                    ),
                    const SizedBox(height: 24),
                    AuthButton(
                      variant: AuthButtonVariant.primary,
                      label: _isLoading
                          ? 'Enviando...'
                          : 'Enviar código de acesso',
                      onPressed: _handleSubmit,
                      disabled: _isLoading || _email.trim().isEmpty,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.center,
                child: AuthLink(
                  label: 'Agora não',
                  onPressed: widget.onDismiss,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
