import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/verse_repository.dart';
import '../models/app_preferences.dart';
import '../models/verse.dart';
import '../services/preferences_store.dart';
import '../services/verse_engine.dart';
import '../services/widget_sync.dart';

/// Overridden in `main.dart` with the real instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) =>
      throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

final preferencesStoreProvider = Provider<PreferencesStore>(
  (ref) => PreferencesStore(ref.watch(sharedPreferencesProvider)),
);

final verseRepositoryProvider = Provider<VerseRepository>(
  (_) => const VerseRepository(),
);

final verseEngineProvider = Provider<VerseEngine>(
  (ref) => VerseEngine(
    store: ref.watch(preferencesStoreProvider),
    repository: ref.watch(verseRepositoryProvider),
    widgetSync: const WidgetSync(),
  ),
);

class PreferencesNotifier extends Notifier<AppPreferences> {
  @override
  AppPreferences build() => ref.watch(preferencesStoreProvider).load();

  Future<void> update(
    AppPreferences Function(AppPreferences current) change,
  ) async {
    final next = change(state);
    if (next == state) return;
    state = next;
    await ref.read(preferencesStoreProvider).save(next);
  }
}

final preferencesProvider =
    NotifierProvider<PreferencesNotifier, AppPreferences>(
      PreferencesNotifier.new,
    );

/// Today's verse. Rebuilds (and re-syncs the widget) whenever preferences change.
class TodayVerseNotifier extends AsyncNotifier<Verse> {
  @override
  Future<Verse> build() {
    final preferences = ref.watch(preferencesProvider);
    return ref.watch(verseEngineProvider).refresh(preferences);
  }

  Future<void> shuffle() async {
    final engine = ref.read(verseEngineProvider);
    final preferences = ref.read(preferencesProvider);
    state = await AsyncValue.guard(() => engine.shuffle(preferences));
  }

  Future<void> refresh() async {
    final engine = ref.read(verseEngineProvider);
    final preferences = ref.read(preferencesProvider);
    state = await AsyncValue.guard(() => engine.refresh(preferences));
  }
}

final todayVerseProvider = AsyncNotifierProvider<TodayVerseNotifier, Verse>(
  TodayVerseNotifier.new,
);
