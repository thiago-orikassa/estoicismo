import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/design_system/components/components.dart';
import '../../../core/design_system/tokens/design_tokens.dart';

class LoginSuccessScreen extends StatefulWidget {
  const LoginSuccessScreen({
    super.key,
    required this.onContinue,
    this.autoRedirect = true,
    this.redirectDelay = const Duration(milliseconds: 2500),
  });

  final VoidCallback onContinue;
  final bool autoRedirect;
  final Duration redirectDelay;

  @override
  State<LoginSuccessScreen> createState() => _LoginSuccessScreenState();
}

class _LoginSuccessScreenState extends State<LoginSuccessScreen>
    with SingleTickerProviderStateMixin {
  Timer? _redirectTimer;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: widget.redirectDelay,
    );

    if (widget.autoRedirect) {
      _progressController.forward();
      _redirectTimer = Timer(widget.redirectDelay, widget.onContinue);
    }
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AethorColors.ivory,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AuthStateMessage(
                  type: AuthStateMessageType.success,
                  title: 'Conta conectada com sucesso',
                  subtitle: 'Seu progresso está seguro e sincronizado.',
                ),
                if (widget.autoRedirect) ...[
                  const SizedBox(height: 32),
                  Semantics(
                    label: 'Redirecionando em instantes',
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, _) {
                        return Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _progressController.value,
                                backgroundColor:
                                    AethorColors.sand.withValues(alpha: 0.4),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AethorColors.deepBlue,
                                ),
                                minHeight: 4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Redirecionando...',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AethorColors.textMuted),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 32),
                  AuthButton(
                    variant: AuthButtonVariant.primary,
                    label: 'Continuar',
                    onPressed: widget.onContinue,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
