import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

import 'deep_link_intent.dart';

typedef AppLinkCallback = Future<void> Function(AppLinkIntent intent);
typedef PushEventCallback = Future<void> Function(
    Map<String, dynamic> properties);
typedef TokenRefreshCallback = Future<void> Function(String token);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Background messages are handled silently; no UI interaction needed.
}

class PushService {
  PushService();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _appLinksSub;
  StreamSubscription<RemoteMessage>? _messageSub;
  StreamSubscription<RemoteMessage>? _messageOpenedSub;
  StreamSubscription<String>? _tokenRefreshSub;

  bool _firebaseAvailable = false;

  Future<void> initialize({
    required AppLinkCallback onAppLink,
    required PushEventCallback onPushReceived,
    required PushEventCallback onPushOpened,
    TokenRefreshCallback? onTokenRefresh,
  }) async {
    await _bootstrapFirebaseMessaging(
      onAppLink: onAppLink,
      onPushReceived: onPushReceived,
      onPushOpened: onPushOpened,
      onTokenRefresh: onTokenRefresh,
    );
    await _bootstrapAppLinks(onAppLink: onAppLink, onPushOpened: onPushOpened);
  }

  Future<void> dispose() async {
    await _appLinksSub?.cancel();
    await _messageSub?.cancel();
    await _messageOpenedSub?.cancel();
    await _tokenRefreshSub?.cancel();
  }

  /// Request notification permission from the user.
  /// On Android 13+, uses permission_handler; on iOS, uses Firebase Messaging.
  /// Returns true if permission was granted.
  /// Note: Firebase.initializeApp() is called in main() before the widget tree,
  /// so FirebaseMessaging.instance is always available here.
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }

    // iOS: use Firebase Messaging's own permission dialog.
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Returns the current FCM token, or null if Firebase is unavailable.
  ///
  /// On iOS, waits up to 10 seconds for the APNs token to be available
  /// before requesting the FCM token — the APNs token is not immediately
  /// ready on app launch.
  Future<String?> getToken() async {
    if (!_firebaseAvailable) return null;
    try {
      if (Platform.isIOS) {
        String? apnsToken;
        for (int i = 0; i < 10; i++) {
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          if (apnsToken != null) break;
          await Future.delayed(const Duration(seconds: 1));
        }
        if (apnsToken == null) return null;
      }
      return await FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }

  Future<void> _bootstrapFirebaseMessaging({
    required AppLinkCallback onAppLink,
    required PushEventCallback onPushReceived,
    required PushEventCallback onPushOpened,
    TokenRefreshCallback? onTokenRefresh,
  }) async {
    try {
      // Firebase is initialized in main() with DefaultFirebaseOptions.
      // Accessing Firebase.app() verifies it is available without re-initializing.
      Firebase.app();
      _firebaseAvailable = true;
    } catch (_) {
      _firebaseAvailable = false;
      return;
    }

    if (!_firebaseAvailable) return;

    final messaging = FirebaseMessaging.instance;
    await messaging.setAutoInitEnabled(true);

    // On iOS, suppress system banners while the app is in the foreground —
    // we handle foreground display ourselves via InAppNotificationBanner.
    if (Platform.isIOS) {
      await messaging.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: true,
        sound: false,
      );
    }

    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );

    _messageSub = FirebaseMessaging.onMessage.listen((message) async {
      await onPushReceived(_pushProperties(message));
    });

    _messageOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen(
      (message) async {
        await onPushOpened(_pushProperties(message, opened: true));
        await _openDeepLinkFromMessage(
          message,
          source: 'push_opened_background',
          onAppLink: onAppLink,
        );
      },
    );

    if (onTokenRefresh != null) {
      _tokenRefreshSub = messaging.onTokenRefresh.listen((token) async {
        await onTokenRefresh(token);
      });
    }

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      await onPushOpened(_pushProperties(initialMessage, opened: true));
      await _openDeepLinkFromMessage(
        initialMessage,
        source: 'push_opened_cold_start',
        onAppLink: onAppLink,
      );
    }
  }

  Future<void> _bootstrapAppLinks({
    required AppLinkCallback onAppLink,
    required PushEventCallback onPushOpened,
  }) async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        final intent = parseAppLinkIntent(initial, source: 'app_link_initial');
        if (intent != null) {
          await onPushOpened({
            'event_source': intent.source,
            'deeplink': intent.rawUri.toString(),
            'target': intent.target.name,
            'focus_checkin': intent.focusCheckin,
            if (intent.dateLocal != null) 'date_local': intent.dateLocal!,
          });
          await onAppLink(intent);
        }
      }
    } catch (_) {
      // Best effort: app links must not break app startup.
    }

    _appLinksSub = _appLinks.uriLinkStream.listen((uri) async {
      final intent = parseAppLinkIntent(uri, source: 'app_link_runtime');
      if (intent == null) return;
      await onPushOpened({
        'event_source': intent.source,
        'deeplink': intent.rawUri.toString(),
        'target': intent.target.name,
        'focus_checkin': intent.focusCheckin,
        if (intent.dateLocal != null) 'date_local': intent.dateLocal!,
      });
      await onAppLink(intent);
    });
  }

  Future<void> _openDeepLinkFromMessage(
    RemoteMessage message, {
    required String source,
    required AppLinkCallback onAppLink,
  }) async {
    final deeplinkRaw = _resolveDeeplinkFromMessage(message);
    final uri = tryParseUri(deeplinkRaw);
    if (uri == null) return;

    final intent = parseAppLinkIntent(uri, source: source);
    if (intent == null) return;
    await onAppLink(intent);
  }

  String? _resolveDeeplinkFromMessage(RemoteMessage message) {
    final data = message.data;
    final deeplink = data['deeplink']?.toString();
    if (deeplink != null && deeplink.trim().isNotEmpty) return deeplink;

    final route = data['route']?.toString().trim().toLowerCase();
    if (route == null || route.isEmpty) return null;
    if (route == 'today' ||
        route == 'history' ||
        route == 'favorites' ||
        route == 'settings') {
      return 'aethor://$route';
    }
    return null;
  }

  Map<String, dynamic> _pushProperties(
    RemoteMessage message, {
    bool opened = false,
  }) {
    return {
      'message_id': message.messageId ?? '',
      'event_source': 'fcm',
      'opened': opened,
      if (message.sentTime != null)
        'sent_at_utc': message.sentTime!.toUtc().toIso8601String(),
      if (message.notification?.title != null)
        'notification_title': message.notification!.title!,
      if (message.notification?.body != null)
        'notification_body': message.notification!.body!,
      if (message.data['deeplink'] != null)
        'deeplink': message.data['deeplink'].toString(),
      if (message.data['route'] != null)
        'route': message.data['route'].toString(),
    };
  }
}
