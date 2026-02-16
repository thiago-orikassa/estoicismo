import 'dart:io';

import 'package:flutter/services.dart';

/// Creates the "Lembrete Diário" notification channel on Android.
///
/// Must be called before sending any local or FCM notification so that
/// Android 8+ devices display notifications correctly.  On iOS this is
/// a no-op — channels are an Android-only concept.
class NotificationChannel {
  static const String channelId = 'daily_reminder';
  static const String channelName = 'Lembrete Diário';
  static const String channelDescription =
      'Notificações do lembrete diário de prática estoica';

  static bool _created = false;

  /// Ensures the notification channel exists.  Safe to call multiple times.
  static Future<void> ensureCreated() async {
    if (!Platform.isAndroid || _created) return;

    const channel = MethodChannel('aethor/notification_channel');
    try {
      await channel.invokeMethod<void>('createChannel', {
        'id': channelId,
        'name': channelName,
        'description': channelDescription,
        'importance': 4, // IMPORTANCE_HIGH
      });
      _created = true;
    } on MissingPluginException {
      // Channel creation is best-effort; FCM will use the default channel
      // declared in AndroidManifest meta-data if this fails.
    }
  }
}
