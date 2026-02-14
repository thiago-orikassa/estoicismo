import 'package:flutter/material.dart';

import '../tokens/design_tokens.dart';

class AuthEmailField extends StatefulWidget {
  const AuthEmailField({
    super.key,
    required this.value,
    required this.onChanged,
    this.onSubmitted,
    this.placeholder = 'seu@email.com',
    this.error,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback? onSubmitted;
  final String placeholder;
  final String? error;

  @override
  State<AuthEmailField> createState() => _AuthEmailFieldState();
}

class _AuthEmailFieldState extends State<AuthEmailField> {
  final FocusNode _focusNode = FocusNode();
  late final TextEditingController _controller;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant AuthEmailField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
      _controller.selection = TextSelection.collapsed(
        offset: widget.value.length,
      );
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focused == _focusNode.hasFocus) return;
    setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.error != null && widget.error!.isNotEmpty;
    final borderColor = hasError
        ? StoicColors.copper
        : (_focused ? StoicColors.deepBlue : StoicColors.sand);
    final fillColor =
        hasError ? StoicColors.copper.withValues(alpha: 0.05) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(StoicRadius.md),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: SizedBox(
            height: 52,
            child: TextField(
              focusNode: _focusNode,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.none,
              autocorrect: false,
              enableSuggestions: false,
              onSubmitted: (_) => widget.onSubmitted?.call(),
              onChanged: widget.onChanged,
              controller: _controller,
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: StoicColors.textSubtle,
                    ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: StoicColors.obsidian,
                    fontSize: 16,
                  ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              widget.error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: StoicColors.copper,
                    fontSize: 13,
                  ),
            ),
          ),
      ],
    );
  }
}
