import 'dart:math';

import 'package:flutter/material.dart';

import '../tokens/design_tokens.dart';

enum RestorePurchaseState {
  loading,
  success,
  error,
}

class RestorePurchaseDialog extends StatefulWidget {
  const RestorePurchaseDialog({
    super.key,
    required this.onClose,
    required this.onSuccess,
    required this.onContactSupport,
  });

  final VoidCallback onClose;
  final VoidCallback onSuccess;
  final VoidCallback onContactSupport;

  @override
  State<RestorePurchaseDialog> createState() => _RestorePurchaseDialogState();
}

class _RestorePurchaseDialogState extends State<RestorePurchaseDialog> {
  RestorePurchaseState _state = RestorePurchaseState.loading;

  @override
  void initState() {
    super.initState();
    _startRestore();
  }

  Future<void> _startRestore() async {
    setState(() => _state = RestorePurchaseState.loading);
    await Future.delayed(const Duration(milliseconds: 1600));
    final success = Random().nextBool();
    if (!mounted) return;
    setState(() =>
        _state = success ? RestorePurchaseState.success : RestorePurchaseState.error);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: StoicColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Restaurar compra',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: StoicColors.obsidian,
                      ),
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_state == RestorePurchaseState.loading)
              _LoadingState()
            else if (_state == RestorePurchaseState.success)
              _SuccessState(onContinue: widget.onSuccess)
            else
              _ErrorState(
                onRetry: _startRestore,
                onContactSupport: widget.onContactSupport,
              ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        const SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(StoicColors.copper),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Restaurando compra...',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: StoicColors.textMuted,
              ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SuccessState extends StatelessWidget {
  const _SuccessState({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: StoicColors.deepBlue),
            const SizedBox(width: 8),
            Text(
              'Compra restaurada',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Seu acesso Pro está ativo novamente.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: StoicColors.textMuted,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: StoicColors.deepBlue,
              foregroundColor: StoicColors.ivory,
            ),
            onPressed: onContinue,
            child: const Text('Continuar'),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry, required this.onContactSupport});

  final VoidCallback onRetry;
  final VoidCallback onContactSupport;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: StoicColors.copper),
            const SizedBox(width: 8),
            Text(
              'Não foi possível restaurar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Tente novamente ou fale com o suporte.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: StoicColors.textMuted,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: StoicColors.deepBlue,
                ),
                child: const Text('Tentar novamente'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: onContactSupport,
                style: FilledButton.styleFrom(
                  backgroundColor: StoicColors.deepBlue,
                  foregroundColor: StoicColors.ivory,
                ),
                child: const Text('Falar com suporte'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
