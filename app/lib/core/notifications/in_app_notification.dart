import 'dart:async';

import 'package:flutter/material.dart';

import '../design_system/tokens/design_tokens.dart';

/// Shows a subtle banner at the top of the screen when a push notification
/// arrives while the app is in the foreground.
///
/// Auto-dismisses after [autoDismissDuration]. Tappable to navigate via deeplink.
class InAppNotificationBanner {
  static const Duration autoDismissDuration = Duration(seconds: 5);

  /// Show an in-app notification banner using [ScaffoldMessenger].
  ///
  /// [onTap] is called when the user taps "Ver" (view) on the banner.
  /// [onDismiss] is called when the user taps "Fechar" (close) or auto-dismiss fires.
  static void show(
    BuildContext context, {
    required String? title,
    required String? body,
    VoidCallback? onTap,
    VoidCallback? onDismiss,
  }) {
    if (title == null && body == null) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.showMaterialBanner(
      MaterialBanner(
        backgroundColor: AethorColors.cardBackground,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null)
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AethorColors.obsidian,
                ),
              ),
            if (body != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  body,
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
        actions: [
          if (onTap != null)
            TextButton(
              onPressed: () {
                messenger.hideCurrentMaterialBanner();
                onTap();
              },
              child: const Text('Ver'),
            ),
          TextButton(
            onPressed: () {
              messenger.hideCurrentMaterialBanner();
              onDismiss?.call();
            },
            child: const Text('Fechar'),
          ),
        ],
      ),
    );

    // Auto-dismiss after the configured duration.
    Timer(autoDismissDuration, () {
      try {
        messenger.hideCurrentMaterialBanner();
      } catch (_) {
        // Banner may already be dismissed.
      }
    });
  }
}
