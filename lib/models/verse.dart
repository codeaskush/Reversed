import 'scripture.dart';

/// A single verse with its source reference.
class Verse {
  const Verse({
    required this.scripture,
    required this.reference,
    required this.text,
  });

  final Scripture scripture;

  /// Human readable reference, e.g. `2.47` or `John 3:16`.
  final String reference;
  final String text;

  /// Stable identifier used to remember a chosen verse.
  String get id => '${scripture.id}|$reference';

  /// Reference as it is displayed, e.g. `Bhagavad Gita 2.47`.
  String get displayReference => '${scripture.title} $reference';

  Map<String, Object?> toJson() => {
    'scripture': scripture.id,
    'reference': reference,
    'text': text,
  };

  @override
  bool operator ==(Object other) => other is Verse && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Verse($displayReference)';
}

/// A verse assigned to a specific calendar day.
class ScheduledVerse {
  const ScheduledVerse({required this.day, required this.verse});

  final DateTime day;
  final Verse verse;

  /// `yyyy-MM-dd` in local time; the native widgets match on this string.
  String get dayKey => formatDayKey(day);

  Map<String, Object?> toJson() => {
    'date': dayKey,
    'scripture': verse.scripture.id,
    'source': verse.scripture.title,
    'reference': verse.reference,
    'text': verse.text,
  };
}

/// Formats a date as `yyyy-MM-dd` (local calendar day, no time zone suffix).
String formatDayKey(DateTime day) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${day.year}-${two(day.month)}-${two(day.day)}';
}

/// Strips the time component from a [DateTime].
DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
