import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/design_system/components/components.dart';
import '../../../core/design_system/motion/motion.dart';
import '../../../core/design_system/tokens/aethor_icons.dart';
import '../../../core/design_system/tokens/design_tokens.dart';

class CodeVerificationScreen extends StatefulWidget {
  const CodeVerificationScreen({
    super.key,
    required this.email,
    this.onBack,
    this.onVerified,
    this.onResend,
  });

  final String email;
  final VoidCallback? onBack;
  final ValueChanged<String>? onVerified;
  final VoidCallback? onResend;

  @override
  State<CodeVerificationScreen> createState() => _CodeVerificationScreenState();
}

class _CodeVerificationScreenState extends State<CodeVerificationScreen> {
  String _code = '';
  bool _isVerifying = false;
  String? _error;
  int _resendCooldown = 0;
  Timer? _resendTimer;

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleCodeComplete(String code) async {
    if (_isVerifying) return;
    setState(() {
      _error = null;
      _isVerifying = true;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    if (code == '123456' || code == '000000') {
      widget.onVerified?.call(code);
      return;
    }

    setState(() {
      _error = 'Código inválido. Tente novamente.';
      _code = '';
      _isVerifying = false;
    });
  }

  void _startCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendCooldown = 30);

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _resendCooldown = (_resendCooldown - 1).clamp(0, 30);
      });
      if (_resendCooldown == 0) {
        timer.cancel();
      }
    });
  }

  void _handleResend() {
    if (_resendCooldown > 0) return;
    _startCooldown();
    widget.onResend?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AethorColors.ivory,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: widget.onBack,
                  icon: const Icon(AethorIcons.back, size: 20),
                  label: const Text('Voltar'),
                  style: TextButton.styleFrom(
                    foregroundColor: AethorColors.stone,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Center(
                  child: AethorFadeSlideIn(
                    offsetY: 12,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Confirme seu email',
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                fontSize: 32,
                                height: 1.2,
                                color: AethorColors.obsidian,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Enviamos um código de 6 dígitos para',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AethorColors.stone,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.email,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AethorColors.obsidian,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        AuthCodeField(
                          value: _code,
                          onChanged: (value) => setState(() => _code = value),
                          onComplete: _handleCodeComplete,
                          error: _error != null,
                        ),
                        const SizedBox(height: 16),
                        if (_error != null)
                          AuthStateMessage(
                            type: AuthStateMessageType.error,
                            title: _error!,
                          )
                        else if (_isVerifying)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const AuthLoadingSpinner(
                                size: AuthSpinnerSize.sm,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Verificando...',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AethorColors.stone,
                                    ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 16),
                        Text(
                          'O código expira em 10 minutos',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AethorColors.textMuted,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        if (_resendCooldown > 0)
                          Text(
                            'Reenviar em ${_resendCooldown}s',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AethorColors.textMuted,
                                    ),
                          )
                        else
                          AuthLink(
                            label: 'Não recebeu? Reenviar código',
                            onPressed: _handleResend,
                          ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AethorColors.deepBlue.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(AethorRadius.md),
                            border: Border.all(
                              color:
                                  AethorColors.deepBlue.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            'Demo: use 123456 ou 000000.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AethorColors.stone,
                                    ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Verifique também sua pasta de spam',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AethorColors.textMuted,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
