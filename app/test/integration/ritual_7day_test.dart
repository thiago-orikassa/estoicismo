import 'package:flutter_test/flutter_test.dart';

import 'package:aethor_app/core/notifications/deep_link_intent.dart';

/// Integration-level test that verifies the 7-day ritual flow
/// purely through deep link parsing and intent construction.
///
/// Full widget integration tests that depend on ApiClient mocking
/// and Firebase are expected to be run on device (QA-03 manual protocol).
void main() {
  group('Ritual 7-day: deep link → navigation intent × 7', () {
    test('7 consecutive daily push deep links produce correct intents', () {
      const baseDate = '2026-02-09';
      final dates = List.generate(7, (i) {
        final day = 9 + i;
        return '2026-02-${day.toString().padLeft(2, '0')}';
      });

      for (var i = 0; i < 7; i++) {
        final uri = Uri.parse(
          'aethor://today?date_local=${dates[i]}&focus=checkin',
        );
        final intent = parseAppLinkIntent(uri, source: 'push_opened_day_$i');

        expect(intent, isNotNull, reason: 'Day $i intent should not be null');
        expect(intent!.target, AppLinkTarget.today,
            reason: 'Day $i should target today');
        expect(intent.dateLocal, dates[i],
            reason: 'Day $i date mismatch');
        expect(intent.focusCheckin, isTrue,
            reason: 'Day $i should focus checkin');
      }
    });

    test('mixed navigation targets after daily flow do not corrupt state', () {
      // Simulate: 3 days of push → history → settings → favorites → back to today.
      final sequence = [
        ('aethor://today?date_local=2026-02-09&focus=checkin', AppLinkTarget.today),
        ('aethor://today?date_local=2026-02-10&focus=checkin', AppLinkTarget.today),
        ('aethor://today?date_local=2026-02-11&focus=checkin', AppLinkTarget.today),
        ('aethor://history', AppLinkTarget.history),
        ('aethor://settings', AppLinkTarget.settings),
        ('aethor://favorites', AppLinkTarget.favorites),
        ('aethor://today?date_local=2026-02-15', AppLinkTarget.today),
      ];

      for (var i = 0; i < sequence.length; i++) {
        final (deeplink, expectedTarget) = sequence[i];
        final uri = Uri.parse(deeplink);
        final intent = parseAppLinkIntent(uri, source: 'integration_$i');

        expect(intent, isNotNull, reason: 'Step $i should produce valid intent');
        expect(intent!.target, expectedTarget,
            reason: 'Step $i target mismatch');
      }
    });

    test('paywall deep link does not navigate (unknown route returns null)', () {
      final uri = Uri.parse('aethor://paywall');
      final intent = parseAppLinkIntent(uri, source: 'test');
      expect(intent, isNull, reason: 'Unknown routes should not navigate');
    });

    test('HTTPS host-based deep link parses correctly', () {
      final uri = Uri.parse('https://aethor.app/today?date_local=2026-02-15');
      final intent = parseAppLinkIntent(uri, source: 'app_link_runtime');

      expect(intent, isNotNull);
      expect(intent!.target, AppLinkTarget.today);
      expect(intent.dateLocal, '2026-02-15');
    });
  });
}
