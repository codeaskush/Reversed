import '../models/scripture.dart';
import '../models/verse.dart';
import 'bible_verses.dart';
import 'gita_verses.dart';

/// In-app verse catalogue. Verses are bundled with the app so the widget
/// works fully offline.
class VerseRepository {
  const VerseRepository();

  List<Verse> versesOf(Scripture scripture) => switch (scripture) {
    Scripture.gita => gitaVerses,
    Scripture.bible => bibleVerses,
  };

  List<Verse> get all => [...gitaVerses, ...bibleVerses];

  /// Looks a verse up by [Verse.id]; returns `null` if unknown.
  Verse? byId(String id) {
    for (final verse in all) {
      if (verse.id == id) return verse;
    }
    return null;
  }
}
