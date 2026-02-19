import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  Future<void> logEvent(
    String eventName, {
    Map<String, Object>? parameters,
  }) async {
    // Firebase Analytics limits: event name max 40 chars,
    // param key max 40 chars, param value max 100 chars.
    final sanitized = <String, Object>{};
    if (parameters != null) {
      for (final entry in parameters.entries) {
        final key = entry.key.length > 40
            ? entry.key.substring(0, 40)
            : entry.key;
        final value = entry.value;
        if (value is String && value.length > 100) {
          sanitized[key] = value.substring(0, 100);
        } else {
          sanitized[key] = value;
        }
      }
    }

    await _analytics.logEvent(
      name: eventName,
      parameters: sanitized,
    );
  }

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }
}
