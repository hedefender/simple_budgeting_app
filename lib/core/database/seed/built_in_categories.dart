/// The built-in expense categories, in display order. The key is also the id.
///
/// The catalogue is data: a new category is one more line here (it is inserted
/// the next time the database opens), with its name in the ARB files. No
/// schema change is needed.
const List<String> builtInCategoryKeys = <String>[
  'energy',
  'water',
  'telecom',
  'food',
  'fuel_transport',
  'health',
  'insurance',
  'other',
];

/// The category the expense form preselects.
const String defaultCategoryKey = 'other';
