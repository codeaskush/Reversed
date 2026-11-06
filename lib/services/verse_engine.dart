import '../core/constants.dart';
import '../data/verse_repository.dart';
import '../models/app_preferences.dart';
import '../models/verse.dart';
import 'preferences_store.dart';
import 'verse_picker.dart';
import 'widget_sync.dart';

/// Orchestrates verse selection, persistence and widget updates.
///
/// Used by the app UI and by the background isolate that handles widget taps,
/// so it must not depend on any Flutter widget tree or Riverpod container.
class VerseEngine {
  VerseEngine({
    required this.store,
    required this.repository,
    required this.widgetSync,
    DateTime Function()? clock,
  }) : picker = VersePicker(repository),
       _clock = clock ?? DateTime.now;

  final PreferencesStore store;
  final VerseRepository repository;
  final WidgetSync widgetSync;
  final VersePicker picker;
  final DateTime Function() _clock;

  /// Computes today's verse, refreshes the widget schedule and returns it.
  Future<Verse> refresh(AppPreferences preferences) async {
    final today = dateOnly(_clock());
    final overrides = _overrides(today, preferences);
    final schedule = picker.schedule(
      today,
      AppConstants.scheduleDays,
      preferences.scriptureChoice,
      overrides: overrides,
    );
    await widgetSync.push(
      today: schedule.first,
      schedule: schedule,
      preferences: preferences,
    );
    return schedule.first.verse;
  }

  /// Picks a different random verse for today, remembers it, and refreshes.
  Future<Verse> shuffle(AppPreferences preferences) async {
    final today = dateOnly(_clock());
    final current =
        _overrides(today, preferences)[formatDayKey(today)] ??
        picker.verseFor(today, preferences.scriptureChoice);
    final next = picker.random(preferences.scriptureChoice, exclude: current);
    await store.setOverride(today, next.id);
    return refresh(preferences);
  }

  Map<String, Verse> _overrides(DateTime today, AppPreferences preferences) {
    final id = store.overrideFor(today);
    if (id == null) return const {};
    final verse = repository.byId(id);
    // Drop overrides that no longer match the chosen scripture(s).
    if (verse == null ||
        !preferences.scriptureChoice.scriptures.contains(verse.scripture)) {
      return const {};
    }
    return {formatDayKey(today): verse};
  }
}
