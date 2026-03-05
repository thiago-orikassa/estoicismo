import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/auth/session_service.dart';
import '../../../core/design_system/components/components.dart';
import '../../../core/design_system/tokens/aethor_icons.dart';
import '../../../core/design_system/tokens/design_tokens.dart';
import '../../../core/networking/api_client.dart';

class CodeVerificationScreen extends StatefulWidget {
  const CodeVerificationScreen({
    super.key,
    required this.email,
    required this.api,
    required this.sessionService,
    this.onBack,
    this.onVerified,
    this.onResend,
  });

  final String email;
  final ApiClient api;
  final SessionService sessionService;
  final VoidCallback? onBack;
  final ValueChanged<String>? onVerified;
  final VoidCallback? onResend;

  @override
  State<CodeVerificationScreen> createState() => _CodeVerificationScreenState();
}

class _CodeVerificationScreenState extends State<CodeVerificationScreen>
    with WidgetsBindingObserver {
  String _code = '';
  bool _isVerifying = false;
  String? _error;
  int _resendCooldown = 0;
  Timer? _resendTimer;

  // Stable keyboard height — only updated when keyboard shows/hides (>50 px change).
  // Avoids rebuilding on tiny height fluctuations iOS fires on every key press.
  double _keyboardHeight = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resendTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final h = MediaQuery.viewInsetsOf(context).bottom;
      if ((h - _keyboardHeight).abs() > 50) {
        setState(() => _keyboardHeight = h);
      }
    });
  }

  Future<void> _handleCodeComplete(String code) async {
    if (_isVerifying) return;
    setState(() {
      _error = null;
      _isVerifying = true;
    });

    try {
      final data = await widget.api.post('/v1/auth/verify-otp', body: {
        'email': widget.email,
        'code': code,
      });
      if (!mounted) return;
      await widget.sessionService.storeCredentials(
        userId: data['user_id'] as String,
        accessToken: data['access_token'] as String,
      );
      widget.onVerified?.call(code);
    } on HttpException catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _error = e.message.contains('expired')
            ? 'Código expirado.'
            : 'Código inválido.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _error = 'Erro ao verificar código. Tente novamente.';
      });
    }
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
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: _keyboardHeight),
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
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Center(
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
                          onChanged: (value) {
                            _code = value;
                            // Only rebuild to clear the error banner; don't rebuild on every keystroke.
                            if (_error != null) setState(() => _error = null);
                          },
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
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
