import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/design_tokens.dart';

class AuthCodeField extends StatefulWidget {
  const AuthCodeField({
    super.key,
    required this.value,
    required this.onChanged,
    this.onComplete,
    this.length = 6,
    this.error = false,
  });

  final int length;
  final String value;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onComplete;
  final bool error;

  @override
  State<AuthCodeField> createState() => _AuthCodeFieldState();
}

class _AuthCodeFieldState extends State<AuthCodeField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  int? _focusedIndex;
  String? _lastCompletedValue;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(text: _charAt(widget.value, index)),
    );
    _focusNodes = List.generate(widget.length, (_) => FocusNode());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _focusNodes.isNotEmpty) {
        _focusNodes.first.requestFocus();
      }
    });
  }

  @override
  void didUpdateWidget(covariant AuthCodeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.length != widget.length) {
      _rebuildControllers();
      return;
    }
    if (oldWidget.value != widget.value) {
      _syncControllers(widget.value);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _rebuildControllers() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    _controllers
      ..clear()
      ..addAll(
        List.generate(
          widget.length,
          (index) => TextEditingController(text: _charAt(widget.value, index)),
        ),
      );
    _focusNodes
      ..clear()
      ..addAll(List.generate(widget.length, (_) => FocusNode()));
  }

  void _syncControllers(String value) {
    for (var i = 0; i < widget.length; i++) {
      final target = _charAt(value, i);
      if (_controllers[i].text != target) {
        _controllers[i].text = target;
      }
    }
  }

  String _charAt(String value, int index) {
    if (index < 0 || index >= value.length) return '';
    return value[index];
  }

  void _notifyChange() {
    final value = _controllers.map((c) => c.text).join();
    widget.onChanged(value);
    if (value.length == widget.length && widget.onComplete != null) {
      if (_lastCompletedValue != value) {
        _lastCompletedValue = value;
        widget.onComplete!(value);
      }
    }
  }

  void _handleChanged(int index, String raw) {
    if (raw.isEmpty) {
      _controllers[index].text = '';
      _notifyChange();
      return;
    }

    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;

    if (digits.length > 1) {
      _applyBulkDigits(index, digits);
      return;
    }

    _controllers[index].text = digits;
    _controllers[index].selection = const TextSelection.collapsed(offset: 1);
    _notifyChange();

    if (index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  void _applyBulkDigits(int startIndex, String digits) {
    var cursor = startIndex;
    for (final char in digits.split('')) {
      if (cursor >= widget.length) break;
      _controllers[cursor].text = char;
      cursor += 1;
    }
    _notifyChange();

    final nextIndex = min(cursor, widget.length - 1);
    _focusNodes[nextIndex].requestFocus();
  }

  KeyEventResult _handleKey(int index, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _controllers[index - 1].text = '';
        _focusNodes[index - 1].requestFocus();
        _notifyChange();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft && index > 0) {
      _focusNodes[index - 1].requestFocus();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
        index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (index) {
        final value = _controllers[index].text;
        final isFocused = _focusedIndex == index;
        final borderColor = widget.error
            ? StoicColors.copper
            : isFocused
                ? StoicColors.deepBlue
                : value.isNotEmpty
                    ? StoicColors.stone.withValues(alpha: 0.3)
                    : StoicColors.sand;
        final textColor = widget.error
            ? StoicColors.copper
            : value.isNotEmpty
                ? StoicColors.obsidian
                : StoicColors.textSubtle;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Focus(
            focusNode: _focusNodes[index],
            onKeyEvent: (node, event) => _handleKey(index, event),
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                setState(() => _focusedIndex = index);
              } else if (_focusedIndex == index) {
                setState(() => _focusedIndex = null);
              }
            },
            child: SizedBox(
              width: 48,
              height: 56,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 1,
                onChanged: (value) => _handleChanged(index, value),
                onTap: () => setState(() => _focusedIndex = index),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(StoicRadius.md),
                    borderSide: BorderSide(color: borderColor, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(StoicRadius.md),
                    borderSide: BorderSide(color: borderColor, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(StoicRadius.md),
                    borderSide: BorderSide(color: borderColor, width: 2),
                  ),
                ),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
