import 'dart:math';

import '../data/verse_repository.dart';
import '../models/app_preferences.dart';
import '../models/scripture.dart';
import '../models/verse.dart';

/// Pure verse-selection logic. No I/O, fully testable.
///
/// Daily verses are deterministic: the same calendar day and preferences
/// always yield the same verse, so the app, the Android widget and the iOS
/// widget agree without talking to each other.
class VersePicker {
  const VersePicker(this.repository);

  final VerseRepository repository;

  /// The verse for [day] given a scripture [choice].
  ///
  /// Days are grouped into cycles of `pool.length` days. Each cycle uses its
  /// own shuffled order of the pool, so every verse is shown once per cycle
  /// and no verse repeats within a cycle.
  Verse verseFor(DateTime day, ScriptureChoice choice) {
    final pool = _pool(choice);
    final n = pool.length;
    final dayNumber = _dayNumber(day);
    final cycle = (dayNumber / n).floor();
    final position = dayNumber - cycle * n;
    return pool[_permutation(n, cycle)[position]];
  }

  /// A random verse, avoiding [exclude] when the pool has more than one verse.
  Verse random(ScriptureChoice choice, {Verse? exclude, Random? rng}) {
    final r = rng ?? Random();
    final pool = List.of(_pool(choice));
    if (pool.length > 1 && exclude != null) {
      pool.removeWhere((v) => v == exclude);
    }
    return pool[r.nextInt(pool.length)];
  }

  /// Verses for [days] consecutive days starting at [from].
  ///
  /// [overrides] maps a day key (`yyyy-MM-dd`) to a verse the user explicitly
  /// chose (for example via "shuffle"); it wins over the deterministic pick.
  List<ScheduledVerse> schedule(
    DateTime from,
    int days,
    ScriptureChoice choice, {
    Map<String, Verse> overrides = const {},
  }) {
    final start = dateOnly(from);
    return [
      for (var i = 0; i < days; i++)
        _scheduled(
          DateTime(start.year, start.month, start.day + i),
          choice,
          overrides,
        ),
    ];
  }

  ScheduledVerse _scheduled(
    DateTime day,
    ScriptureChoice choice,
    Map<String, Verse> overrides,
  ) {
    final key = formatDayKey(day);
    final verse = overrides[key] ?? verseFor(day, choice);
    return ScheduledVerse(day: day, verse: verse);
  }

  List<Verse> _pool(ScriptureChoice choice) => [
    for (final s in choice.scriptures) ...repository.versesOf(s),
  ];

  /// Deterministic Fisher-Yates shuffle of `0..n-1` seeded by [seed].
  static List<int> _permutation(int n, int seed) {
    final order = List<int>.generate(n, (i) => i);
    var state = _mix(seed, 0x5BD1E995);
    for (var i = n - 1; i > 0; i--) {
      state = _mix(state, i);
      final j = state % (i + 1);
      final tmp = order[i];
      order[i] = order[j];
      order[j] = tmp;
    }
    return order;
  }

  /// Days since 1970-01-01 in the local calendar.
  static int _dayNumber(DateTime day) {
    final d = dateOnly(day);
    return DateTime.utc(
      d.year,
      d.month,
      d.day,
    ).difference(DateTime.utc(1970)).inDays;
  }

  /// Small 32-bit integer hash. Deterministic across platforms (masked to
  /// 32 bits so it behaves identically on the VM and on the web).
  static int _mix(int value, int salt) {
    var x = (value * 0x9E3779B1 + salt * 0x85EBCA6B) & 0xFFFFFFFF;
    x ^= x >> 15;
    x = (x * 0x2C1B3C6D) & 0xFFFFFFFF;
    x ^= x >> 12;
    x = (x * 0x297A2D39) & 0xFFFFFFFF;
    x ^= x >> 15;
    return x;
  }

  /// Convenience for tests and debugging: which scriptures a choice covers.
  static List<Scripture> scripturesFor(ScriptureChoice choice) =>
      choice.scriptures;
}
