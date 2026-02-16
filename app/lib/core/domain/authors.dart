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
