import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/constants.dart';
import 'data/verse_repository.dart';
import 'providers/providers.dart';
import 'services/preferences_store.dart';
import 'services/verse_engine.dart';
import 'services/widget_sync.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const widgetSync = WidgetSync();
  await widgetSync.init();
  await HomeWidget.registerInteractivityCallback(widgetInteractivityCallback);

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const ReversedApp(),
    ),
  );
}

/// Runs in a background isolate when the user taps an interactive element of
/// the home-screen widget (for example the "next verse" button). It has no
/// access to the app's Riverpod container, so it builds its own engine.
@pragma('vm:entry-point')
Future<void> widgetInteractivityCallback(Uri? uri) async {
  if (uri == null || uri.scheme != AppConstants.interactionScheme) return;

  const widgetSync = WidgetSync();
  await widgetSync.init();

  final store = PreferencesStore(await SharedPreferences.getInstance());
  final engine = VerseEngine(
    store: store,
    repository: const VerseRepository(),
    widgetSync: widgetSync,
  );
  final preferences = store.load();

  switch (uri.host) {
    case AppConstants.nextVerseHost:
      await engine.shuffle(preferences);
    default:
      await engine.refresh(preferences);
  }
}
