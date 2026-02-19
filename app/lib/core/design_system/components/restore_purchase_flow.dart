import 'package:flutter/material.dart';

import '../tokens/aethor_icons.dart';
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
    required this.onPerformRestore,
  });

  final VoidCallback onClose;
  final VoidCallback onSuccess;
  final VoidCallback onContactSupport;
  final Future<bool> Function() onPerformRestore;

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
    try {
      final success = await widget.onPerformRestore();
      if (!mounted) return;
      setState(() => _state =
          success ? RestorePurchaseState.success : RestorePurchaseState.error);
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = RestorePurchaseState.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AethorColors.cardBackground,
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
                        color: AethorColors.obsidian,
                      ),
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(AethorIcons.close),
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
            valueColor: AlwaysStoppedAnimation<Color>(AethorColors.copper),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Restaurando compra...',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AethorColors.textMuted,
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
            const Icon(AethorIcons.checkCircleFill, color: AethorColors.deepBlue),
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
                color: AethorColors.textMuted,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AethorColors.deepBlue,
              foregroundColor: AethorColors.ivory,
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
            const Icon(AethorIcons.error, color: AethorColors.copper),
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
                color: AethorColors.textMuted,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AethorColors.deepBlue,
                ),
                child: const Text('Tentar novamente'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: onContactSupport,
                style: FilledButton.styleFrom(
                  backgroundColor: AethorColors.deepBlue,
                  foregroundColor: AethorColors.ivory,
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
