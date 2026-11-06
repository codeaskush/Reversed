import 'package:flutter_test/flutter_test.dart';
import 'package:reversed/data/verse_repository.dart';
import 'package:reversed/models/scripture.dart';

void main() {
  const repo = VerseRepository();

  test('every scripture has a healthy number of verses', () {
    for (final scripture in Scripture.values) {
      expect(
        repo.versesOf(scripture).length,
        greaterThanOrEqualTo(20),
        reason: scripture.title,
      );
    }
  });

  test('verse ids are unique and lookups work', () {
    final ids = repo.all.map((v) => v.id).toList();
    expect(ids.toSet().length, ids.length);
    for (final verse in repo.all) {
      expect(repo.byId(verse.id), verse);
    }
    expect(repo.byId('nope|1:1'), isNull);
  });

  test('verses have no empty or whitespace-padded text', () {
    for (final verse in repo.all) {
      expect(verse.text.trim(), verse.text, reason: verse.id);
      expect(verse.text, isNotEmpty, reason: verse.id);
      expect(verse.reference, isNotEmpty, reason: verse.id);
    }
  });
}
