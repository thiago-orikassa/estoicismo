enum AppLinkTarget {
  today,
  history,
  favorites,
  settings,
  unknown,
}

class AppLinkIntent {
  const AppLinkIntent({
    required this.target,
    required this.source,
    required this.rawUri,
    this.dateLocal,
    this.focusCheckin = false,
  });

  final AppLinkTarget target;
  final String source;
  final Uri rawUri;
  final String? dateLocal;
  final bool focusCheckin;
}

AppLinkIntent? parseAppLinkIntent(
  Uri uri, {
  required String source,
}) {
  final route = _normalizeRoute(uri);
  if (route.isEmpty) return null;

  final target = switch (route) {
    'today' => AppLinkTarget.today,
    'history' => AppLinkTarget.history,
    'favorites' => AppLinkTarget.favorites,
    'settings' => AppLinkTarget.settings,
    _ => AppLinkTarget.unknown,
  };
  if (target == AppLinkTarget.unknown) return null;

  final dateLocal = _sanitizeDateLocal(uri.queryParameters['date_local']);
  final focusCheckin =
      (uri.queryParameters['focus'] ?? '').trim().toLowerCase() == 'checkin';

  return AppLinkIntent(
    target: target,
    source: source,
    rawUri: uri,
    dateLocal: dateLocal,
    focusCheckin: focusCheckin,
  );
}

String _normalizeRoute(Uri uri) {
  final pathPart = uri.pathSegments.isNotEmpty
      ? uri.pathSegments.first.trim().toLowerCase()
      : '';
  if (pathPart.isNotEmpty) return pathPart;

  final hostPart = uri.host.trim().toLowerCase();
  return hostPart;
}

String? _sanitizeDateLocal(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  final isoDate = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  return isoDate.hasMatch(trimmed) ? trimmed : null;
}

Uri? tryParseUri(String? raw) {
  if (raw == null) return null;
  final value = raw.trim();
  if (value.isEmpty) return null;
  return Uri.tryParse(value);
}
