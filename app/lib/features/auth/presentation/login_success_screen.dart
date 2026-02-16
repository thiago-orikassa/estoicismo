import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/design_system/components/components.dart';
import '../../../core/design_system/tokens/design_tokens.dart';

class LoginSuccessScreen extends StatefulWidget {
  const LoginSuccessScreen({
    super.key,
    required this.onContinue,
    this.autoRedirect = true,
    this.redirectDelay = const Duration(milliseconds: 2000),
  });

  final VoidCallback onContinue;
  final bool autoRedirect;
  final Duration redirectDelay;

  @override
  State<LoginSuccessScreen> createState() => _LoginSuccessScreenState();
}

class _LoginSuccessScreenState extends State<LoginSuccessScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.autoRedirect) {
      _timer = Timer(widget.redirectDelay, widget.onContinue);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
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
                if (!widget.autoRedirect) ...[
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
