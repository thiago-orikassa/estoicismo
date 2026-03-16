import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

const Map<String, String> kContextLabels = {
  'trabalho': 'Disciplina',
  'relacionamentos': 'Relacionamentos',
  'ansiedade': 'Ansiedade',
  'foco': 'Foco',
  'decisao_dificil': 'Decisão difícil',
};

String contextLabel(String key) {
  return kContextLabels[key] ?? key.replaceAll('_', ' ');
}

String localizedContextLabel(BuildContext context, String key) {
  final l10n = AppLocalizations.of(context);
  switch (key) {
    case 'trabalho':
      return l10n.contextWork;
    case 'relacionamentos':
      return l10n.contextRelationships;
    case 'ansiedade':
      return l10n.contextAnxiety;
    case 'foco':
      return l10n.contextFocus;
    case 'decisao_dificil':
      return l10n.contextHardDecision;
    default:
      return key.replaceAll('_', ' ');
  }
}
