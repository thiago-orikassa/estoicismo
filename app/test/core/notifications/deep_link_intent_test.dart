import 'package:aethor_app/core/notifications/deep_link_intent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parse custom scheme today with query params', () {
    final intent = parseAppLinkIntent(
      Uri.parse('aethor://today?date_local=2026-02-15&focus=checkin'),
      source: 'test',
    );

    expect(intent, isNotNull);
    expect(intent!.target, AppLinkTarget.today);
    expect(intent.dateLocal, '2026-02-15');
    expect(intent.focusCheckin, isTrue);
  });

  test('parse https app link to history', () {
    final intent = parseAppLinkIntent(
      Uri.parse('https://aethor.app/history'),
      source: 'test',
    );

    expect(intent, isNotNull);
    expect(intent!.target, AppLinkTarget.history);
  });

  test('ignore unsupported route', () {
    final intent = parseAppLinkIntent(
      Uri.parse('aethor://unknown'),
      source: 'test',
    );

    expect(intent, isNull);
  });

  test('sanitizes date_local invalid format', () {
    final intent = parseAppLinkIntent(
      Uri.parse('aethor://today?date_local=15-02-2026'),
      source: 'test',
    );

    expect(intent, isNotNull);
    expect(intent!.dateLocal, isNull);
  });
}
