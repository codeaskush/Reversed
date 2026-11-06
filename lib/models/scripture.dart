/// A scripture the app can draw verses from.
enum Scripture {
  gita(id: 'gita', title: 'Bhagavad Gita', shortTitle: 'Gita'),
  bible(id: 'bible', title: 'Bible', shortTitle: 'Bible');

  const Scripture({
    required this.id,
    required this.title,
    required this.shortTitle,
  });

  /// Stable identifier used in storage and JSON. Never rename.
  final String id;
  final String title;
  final String shortTitle;

  static Scripture fromId(String id) =>
      values.firstWhere((s) => s.id == id, orElse: () => Scripture.gita);
}
