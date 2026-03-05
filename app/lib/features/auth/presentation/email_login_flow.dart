import 'package:flutter/material.dart';

import '../../../app_state.dart';
import 'code_verification_screen.dart';
import 'email_login_screen.dart';
import 'email_sent_screen.dart';
import 'login_error_screen.dart';
import 'login_success_screen.dart';

enum _EmailFlowStep { input, sent, verify, success, error }

class EmailLoginFlow extends StatefulWidget {
  const EmailLoginFlow({super.key, required this.state});

  final AppState state;

  @override
  State<EmailLoginFlow> createState() => _EmailLoginFlowState();
}

class _EmailLoginFlowState extends State<EmailLoginFlow> {
  _EmailFlowStep _step = _EmailFlowStep.input;
  String _email = '';
  String? _error;

  void _handleSubmit(String email) {
    setState(() {
      _email = email;
      _step = _EmailFlowStep.sent;
    });
  }

  void _handleEnterCode() {
    setState(() => _step = _EmailFlowStep.verify);
  }

  Future<void> _handleResend() async {
    try {
      await widget.state.api.post('/v1/auth/send-otp', body: {'email': _email});
    } catch (_) {
      // Cooldown na tela já protege contra spam; erro silencioso aqui é aceitável.
    }
  }

  void _handleVerified(String _) {
    setState(() => _step = _EmailFlowStep.success);
  }

  void _handleDismiss() {
    Navigator.of(context).pop(false);
  }

  void _handleSuccessContinue() {
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case _EmailFlowStep.input:
        return EmailLoginScreen(
          api: widget.state.api,
          onBack: _handleDismiss,
          onSubmit: _handleSubmit,
          onDismiss: _handleDismiss,
        );
      case _EmailFlowStep.sent:
        return EmailSentScreen(
          email: _email,
          onOpenEmail: () {},
          onChangeEmail: () => setState(() => _step = _EmailFlowStep.input),
          onEnterCode: _handleEnterCode,
        );
      case _EmailFlowStep.verify:
        return CodeVerificationScreen(
          email: _email,
          api: widget.state.api,
          sessionService: widget.state.sessionService,
          onBack: () => setState(() => _step = _EmailFlowStep.sent),
          onVerified: _handleVerified,
          onResend: _handleResend,
        );
      case _EmailFlowStep.success:
        return LoginSuccessScreen(
          onContinue: _handleSuccessContinue,
        );
      case _EmailFlowStep.error:
        return LoginErrorScreen(
          errorMessage: _error,
          onRetry: () => setState(() => _step = _EmailFlowStep.input),
          onDismiss: _handleDismiss,
        );
    }
  }
}
