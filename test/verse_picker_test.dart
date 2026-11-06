import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:reversed/data/verse_repository.dart';
import 'package:reversed/models/app_preferences.dart';
import 'package:reversed/models/scripture.dart';
import 'package:reversed/models/verse.dart';
import 'package:reversed/services/verse_picker.dart';

void main() {
  const repo = VerseRepository();
  const picker = VersePicker(repo);

  group('verseFor', () {
    test('is deterministic for the same day', () {
      final day = DateTime(2026, 11, 6, 13, 45);
      expect(
        picker.verseFor(day, ScriptureChoice.random),
        picker.verseFor(DateTime(2026, 11, 6), ScriptureChoice.random),
      );
    });

    test('respects the scripture choice', () {
      for (var i = 0; i < 60; i++) {
        final day = DateTime(2026, 1, 1 + i);
        expect(
          picker.verseFor(day, ScriptureChoice.gita).scripture,
          Scripture.gita,
        );
        expect(
          picker.verseFor(day, ScriptureChoice.bible).scripture,
          Scripture.bible,
        );
      }
    });

    test('random choice draws from both scriptures over time', () {
      final seen = <Scripture>{};
      for (var i = 0; i < 30; i++) {
        seen.add(
          picker
              .verseFor(DateTime(2026, 3, 1 + i), ScriptureChoice.random)
              .scripture,
        );
      }
      expect(seen, Scripture.values.toSet());
    });

    test('shows every verse once per cycle with no repeats', () {
      final pool = repo.versesOf(Scripture.gita);
      // Cycles are aligned to multiples of the pool size in days since epoch.
      final epochDays = DateTime.utc(
        2026,
      ).difference(DateTime.utc(1970)).inDays;
      final start = DateTime(
        2026,
        1,
        1 + (pool.length - epochDays % pool.length) % pool.length,
      );
      final seen = <Verse>[];
      for (var i = 0; i < pool.length * 3; i++) {
        seen.add(
          picker.verseFor(
            DateTime(start.year, start.month, start.day + i),
            ScriptureChoice.gita,
          ),
        );
      }
      for (var c = 0; c < 3; c++) {
        final cycle = seen.sublist(c * pool.length, (c + 1) * pool.length);
        expect(
          cycle.toSet().length,
          pool.length,
          reason: 'cycle $c repeats a verse',
        );
      }
      // Different cycles use different orders.
      expect(
        seen.sublist(0, pool.length),
        isNot(seen.sublist(pool.length, pool.length * 2)),
      );
    });
  });

  group('schedule', () {
    test('produces consecutive days starting at the given date', () {
      final schedule = picker.schedule(
        DateTime(2026, 12, 30, 9),
        5,
        ScriptureChoice.bible,
      );
      expect(schedule.map((s) => s.dayKey), [
        '2026-12-30',
        '2026-12-31',
        '2027-01-01',
        '2027-01-02',
        '2027-01-03',
      ]);
    });

    test('applies overrides for a specific day', () {
      final override = repo.versesOf(Scripture.bible).last;
      final schedule = picker.schedule(
        DateTime(2026, 5, 5),
        3,
        ScriptureChoice.bible,
        overrides: {'2026-05-06': override},
      );
      expect(schedule[1].verse, override);
      expect(
        schedule[0].verse,
        picker.verseFor(DateTime(2026, 5, 5), ScriptureChoice.bible),
      );
    });

    test('serialises to the JSON shape the native widgets expect', () {
      final json = picker
          .schedule(DateTime(2026, 5, 5), 1, ScriptureChoice.gita)
          .single
          .toJson();
      expect(
        json.keys,
        containsAll(['date', 'scripture', 'source', 'reference', 'text']),
      );
      expect(json['date'], '2026-05-05');
      expect(json['scripture'], 'gita');
      expect(json['source'], 'Bhagavad Gita');
    });
  });

  group('random', () {
    test('never returns the excluded verse', () {
      final rng = Random(42);
      final exclude = repo.versesOf(Scripture.gita).first;
      for (var i = 0; i < 200; i++) {
        expect(
          picker.random(ScriptureChoice.gita, exclude: exclude, rng: rng),
          isNot(exclude),
        );
      }
    });

    test('stays within the chosen scripture', () {
      final rng = Random(7);
      for (var i = 0; i < 100; i++) {
        expect(
          picker.random(ScriptureChoice.bible, rng: rng).scripture,
          Scripture.bible,
        );
      }
    });
  });
}
