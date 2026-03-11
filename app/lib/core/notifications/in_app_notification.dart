import 'dart:async';

import 'package:flutter/material.dart';

import '../design_system/tokens/design_tokens.dart';

/// Shows a subtle banner at the top of the screen when a push notification
/// arrives while the app is in the foreground.
///
/// Uses [Overlay] directly so it always appears regardless of Scaffold hierarchy.
/// Auto-dismisses after [autoDismissDuration].
class InAppNotificationBanner {
  static const Duration autoDismissDuration = Duration(seconds: 5);

  static OverlayEntry? _current;

  /// Show an in-app notification banner via [Overlay].
  ///
  /// [onTap] is called when the user taps "Ver" (view) on the banner.
  static void show(
    BuildContext context, {
    required String? title,
    required String? body,
    VoidCallback? onTap,
  }) {
    if (title == null && body == null) return;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    // Dismiss any existing banner before showing a new one.
    _dismiss();

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _InAppBannerWidget(
        title: title,
        body: body,
        onTap: onTap,
        onDismiss: _dismiss,
      ),
    );

    _current = entry;
    overlay.insert(entry);

    Timer(autoDismissDuration, _dismiss);
  }

  static void _dismiss() {
    _current?.remove();
    _current = null;
  }
}

class _InAppBannerWidget extends StatefulWidget {
  const _InAppBannerWidget({
    required this.title,
    required this.body,
    this.onTap,
    required this.onDismiss,
  });

  final String? title;
  final String? body;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  @override
  State<_InAppBannerWidget> createState() => _InAppBannerWidgetState();
}

class _InAppBannerWidgetState extends State<_InAppBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slide,
        child: Material(
          elevation: 4,
          child: Container(
            color: AethorColors.cardBackground,
            padding: EdgeInsets.fromLTRB(16, topPadding + 12, 8, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.title != null)
                        Text(
                          widget.title!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AethorColors.obsidian,
                          ),
                        ),
                      if (widget.body != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            widget.body!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AethorColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (widget.onTap != null)
                  TextButton(
                    onPressed: () {
                      widget.onDismiss();
                      widget.onTap!();
                    },
                    child: const Text('Ver'),
                  ),
                TextButton(
                  onPressed: widget.onDismiss,
                  child: const Text('Fechar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
