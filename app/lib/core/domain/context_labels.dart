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
