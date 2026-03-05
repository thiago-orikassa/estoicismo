import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/design_tokens.dart';

// Zero-width space used as sentinel in empty fields so iOS fires onChanged
// even when the user presses backspace on an apparently-empty cell.
const _kSentinel = '\u200B';

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

  // Logical state: '' = empty, '0'-'9' = digit.
  // Controllers may hold _kSentinel when logically empty; _fieldValues never does.
  late List<String> _fieldValues;

  int? _focusedIndex;
  String? _lastCompletedValue;

  @override
  void initState() {
    super.initState();
    _fieldValues = List.filled(widget.length, '');
    _controllers = List.generate(widget.length, (i) {
      final d = _digitAt(widget.value, i);
      _fieldValues[i] = d;
      return TextEditingController(text: d.isEmpty ? _kSentinel : d);
    });
    _focusNodes = List.generate(widget.length, (i) => _makeNode(i));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _focusNodes.isNotEmpty) _focusNodes.first.requestFocus();
    });
  }

  FocusNode _makeNode(int index) {
    final node = FocusNode();
    node.onKeyEvent = (_, event) => _handleKey(index, event);
    node.addListener(() {
      if (!mounted) return;
      if (node.hasFocus) {
        setState(() => _focusedIndex = index);
      } else if (_focusedIndex == index) {
        setState(() => _focusedIndex = null);
      }
    });
    return node;
  }

  @override
  void didUpdateWidget(covariant AuthCodeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.length != widget.length) {
      _rebuildAll();
      return;
    }
    if (oldWidget.value != widget.value) _syncControllers(widget.value);
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final n in _focusNodes) n.dispose();
    super.dispose();
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  String _digitAt(String value, int index) {
    if (index < 0 || index >= value.length) return '';
    final c = value[index];
    return RegExp(r'\d').hasMatch(c) ? c : '';
  }

  /// Sets both the logical value and the controller text for one cell.
  void _setCell(int index, String digit) {
    _fieldValues[index] = digit;
    _controllers[index].text = digit.isEmpty ? _kSentinel : digit;
    _controllers[index].selection = TextSelection.collapsed(
      offset: _controllers[index].text.length,
    );
  }

  void _notifyChange() {
    final value = _fieldValues.join(); // '' entries produce nothing → compact string
    widget.onChanged(value);
    if (value.length == widget.length) {
      if (_lastCompletedValue != value) {
        _lastCompletedValue = value;
        widget.onComplete?.call(value);
      }
    }
  }

  void _rebuildAll() {
    for (final c in _controllers) c.dispose();
    for (final n in _focusNodes) n.dispose();
    _fieldValues = List.filled(widget.length, '');
    _controllers
      ..clear()
      ..addAll(List.generate(widget.length, (i) {
        final d = _digitAt(widget.value, i);
        _fieldValues[i] = d;
        return TextEditingController(text: d.isEmpty ? _kSentinel : d);
      }));
    _focusNodes
      ..clear()
      ..addAll(List.generate(widget.length, _makeNode));
  }

  void _syncControllers(String value) {
    for (var i = 0; i < widget.length; i++) {
      final digit = _digitAt(value, i);
      if (_fieldValues[i] != digit) _setCell(i, digit);
    }
  }

  // ── input handling ────────────────────────────────────────────────────────

  void _handleChanged(int index, String raw) {
    // Strip sentinel; keep only digits.
    final digits = raw.replaceAll(_kSentinel, '').replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) {
      final wasEmpty = _fieldValues[index].isEmpty;
      _setCell(index, '');
      if (wasEmpty && index > 0) {
        // Second backspace on empty cell → clear previous cell and move there.
        _setCell(index - 1, '');
        _focusNodes[index - 1].requestFocus();
      }
      _notifyChange();
      return;
    }

    if (digits.length > 1) {
      _applyBulk(index, digits);
      return;
    }

    _setCell(index, digits);
    if (index < widget.length - 1) _focusNodes[index + 1].requestFocus();
    _notifyChange();
  }

  void _applyBulk(int start, String digits) {
    var cursor = start;
    for (final ch in digits.split('')) {
      if (cursor >= widget.length) break;
      _setCell(cursor++, ch);
    }
    _focusNodes[min(cursor, widget.length - 1)].requestFocus();
    _notifyChange();
  }

  KeyEventResult _handleKey(int index, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_fieldValues[index].isEmpty && index > 0) {
        _setCell(index - 1, '');
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

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (index) {
        final digit = _fieldValues[index];
        final isFocused = _focusedIndex == index;
        final borderColor = widget.error
            ? AethorColors.copper
            : isFocused
                ? AethorColors.deepBlue
                : digit.isNotEmpty
                    ? AethorColors.stone.withValues(alpha: 0.3)
                    : AethorColors.sand;
        final textColor = widget.error
            ? AethorColors.copper
            : digit.isNotEmpty
                ? AethorColors.obsidian
                : AethorColors.textSubtle;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SizedBox(
            width: 48,
            height: 56,
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              textAlign: TextAlign.center,
              // Allow digits + sentinel; length handled in _handleChanged.
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d\u200B]')),
              ],
              scrollPadding: EdgeInsets.zero,
              onChanged: (v) => _handleChanged(index, v),
              onTap: () {
                setState(() => _focusedIndex = index);
                _controllers[index].selection = TextSelection.collapsed(
                  offset: _controllers[index].text.length,
                );
              },
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AethorRadius.md),
                  borderSide: BorderSide(color: borderColor, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AethorRadius.md),
                  borderSide: BorderSide(color: borderColor, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AethorRadius.md),
                  borderSide: BorderSide(color: borderColor, width: 2),
                ),
              ),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
            ),
          ),
        );
      }),
    );
  }
}
