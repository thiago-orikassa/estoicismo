import 'package:flutter_test/flutter_test.dart';

import 'package:aethor_app/core/notifications/deep_link_intent.dart';

void main() {
  group('FCM payload → AppLinkIntent parsing', () {
    test('parses full deeplink URI with date_local and focus', () {
      final uri = Uri.parse(
        'aethor://today?date_local=2026-02-15&focus=checkin',
      );
      final intent = parseAppLinkIntent(uri, source: 'push_opened_background');

      expect(intent, isNotNull);
      expect(intent!.target, AppLinkTarget.today);
      expect(intent.dateLocal, '2026-02-15');
      expect(intent.focusCheckin, isTrue);
      expect(intent.source, 'push_opened_background');
    });

    test('parses route-only deeplink (history)', () {
      final uri = Uri.parse('aethor://history');
      final intent = parseAppLinkIntent(uri, source: 'push_opened_cold_start');

      expect(intent, isNotNull);
      expect(intent!.target, AppLinkTarget.history);
      expect(intent.dateLocal, isNull);
      expect(intent.focusCheckin, isFalse);
    });

    test('parses favorites route', () {
      final uri = Uri.parse('aethor://favorites');
      final intent = parseAppLinkIntent(uri, source: 'app_link_runtime');

      expect(intent, isNotNull);
      expect(intent!.target, AppLinkTarget.favorites);
    });

    test('parses settings route', () {
      final uri = Uri.parse('aethor://settings');
      final intent = parseAppLinkIntent(uri, source: 'app_link_initial');

      expect(intent, isNotNull);
      expect(intent!.target, AppLinkTarget.settings);
    });

    test('returns null for unknown route', () {
      final uri = Uri.parse('aethor://unknown-route');
      final intent = parseAppLinkIntent(uri, source: 'test');

      expect(intent, isNull);
    });

    test('rejects invalid date_local format', () {
      final uri = Uri.parse('aethor://today?date_local=15-02-2026');
      final intent = parseAppLinkIntent(uri, source: 'test');

      expect(intent, isNotNull);
      expect(intent!.dateLocal, isNull); // Invalid format → null
    });
  });

  group('Consecutive navigation intents', () {
    test('7 consecutive intents produce correct targets without corruption', () {
      final routes = [
        'aethor://today?date_local=2026-02-09&focus=checkin',
        'aethor://today?date_local=2026-02-10&focus=checkin',
        'aethor://today?date_local=2026-02-11&focus=checkin',
        'aethor://history',
        'aethor://favorites',
        'aethor://settings',
        'aethor://today?date_local=2026-02-15&focus=checkin',
      ];

      final expectedTargets = [
        AppLinkTarget.today,
        AppLinkTarget.today,
        AppLinkTarget.today,
        AppLinkTarget.history,
        AppLinkTarget.favorites,
        AppLinkTarget.settings,
        AppLinkTarget.today,
      ];

      final expectedDates = [
        '2026-02-09',
        '2026-02-10',
        '2026-02-11',
        null,
        null,
        null,
        '2026-02-15',
      ];

      for (var i = 0; i < routes.length; i++) {
        final uri = Uri.parse(routes[i]);
        final intent = parseAppLinkIntent(uri, source: 'test_day_$i');

        expect(intent, isNotNull, reason: 'Intent $i should not be null');
        expect(intent!.target, expectedTargets[i],
            reason: 'Target mismatch at index $i');
        expect(intent.dateLocal, expectedDates[i],
            reason: 'Date mismatch at index $i');
      }
    });
  });

  group('tryParseUri', () {
    test('parses valid URI', () {
      final uri = tryParseUri('aethor://today');
      expect(uri, isNotNull);
      expect(uri!.scheme, 'aethor');
    });

    test('returns null for empty string', () {
      expect(tryParseUri(''), isNull);
    });

    test('returns null for null', () {
      expect(tryParseUri(null), isNull);
    });

    test('returns null for whitespace-only', () {
      expect(tryParseUri('   '), isNull);
    });
  });
}
