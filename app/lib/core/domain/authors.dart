import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

const List<String> kAethorAuthors = [
  'Marco Aurélio',
  'Sêneca',
  'Epicteto',
  'Musônio Rufo',
];

const String kMixedAuthorsLabel = 'Misto';

const Map<String, String> _authorLabels = {
  'marcus_aurelius': 'Marco Aurélio',
  'seneca': 'Sêneca',
  'epictetus': 'Epicteto',
  'musonius_rufus': 'Musônio Rufo',
};

String authorDisplayName(String id) => _authorLabels[id] ?? id;

String localizedAuthorName(BuildContext context, String id) {
  final l10n = AppLocalizations.of(context);
  switch (id) {
    case 'marcus_aurelius':
      return l10n.authorMarcusAurelius;
    case 'seneca':
      return l10n.authorSeneca;
    case 'epictetus':
      return l10n.authorEpictetus;
    case 'musonius_rufus':
      return l10n.authorMusoniusRufus;
    case 'mixed':
      return l10n.authorMixed;
    default:
      return id;
  }
}
