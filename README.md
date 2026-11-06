# Reversed

A home-screen widget for iOS and Android that shows a verse of the day from the
**Bhagavad Gita** or the **Bible**. Pick one scripture or let the app surprise
you, choose a theme, add the widget, done.

- **Daily verse** – deterministic per day, so the app and both widgets always agree.
- **Scripture preference** – Gita, Bible, or "surprise me".
- **Shuffle** – a different verse for today, from the app or straight from the widget.
- **Theme settings** – light/dark/system, six accent colours, four widget styles
  (Glass, Accent, Paper, Midnight) and three widget text sizes.
- **Lock-screen widgets on iOS** – rectangular, inline and circular families.
- **Offline** – verses ship inside the app; no network, no accounts, no tracking.

## Tech stack

Flutter (Dart) for the app, native WidgetKit (SwiftUI) and AppWidget (Kotlin)
views for the widgets, bridged by the [`home_widget`](https://pub.dev/packages/home_widget)
package. See [docs/TECH_STACK.md](docs/TECH_STACK.md) for the reasoning and
the alternatives considered.

| Layer | Choice |
| --- | --- |
| App UI | Flutter 3.35, Material 3 |
| State | `flutter_riverpod` 3 |
| Storage | `shared_preferences` (app) + App Group / `SharedPreferences` (widgets) |
| App → widget bridge | `home_widget` |
| iOS widget | WidgetKit + SwiftUI (home + lock screen), App Intents for the shuffle button (iOS 17+) |
| Android widget | `AppWidgetProvider` + `RemoteViews` |

## How the widget stays fresh without opening the app

The Dart side computes a **14-day schedule** of verses and writes it (as JSON)
into the shared storage both widgets can read:

- **iOS** turns the schedule into a WidgetKit timeline with one entry per
  midnight, so the system swaps the verse for you.
- **Android** re-renders every 30 minutes and on date changes, picking the
  schedule entry for today's date.

Opening the app, changing a setting, or tapping shuffle rewrites the schedule.
The widget's shuffle icon runs Dart in a background isolate
(`widgetInteractivityCallback` in `lib/main.dart`), picks a new verse for
today, and refreshes the widget.

## Project layout

```
lib/
  main.dart                 app entry + widget background callback
  app.dart                  MaterialApp, theming
  core/                     constants (keys shared with native code), theme
  models/                   Scripture, Verse, AppPreferences
  data/                     bundled verses (gita_verses.dart, bible_verses.dart)
  services/
    verse_picker.dart       pure, testable verse selection (daily + random)
    verse_engine.dart       orchestrates picking, persistence, widget sync
    preferences_store.dart  shared_preferences wrapper
    widget_sync.dart        pushes verse + style to native widgets
  providers/                Riverpod providers / notifiers
  features/home, settings   screens
android/app/src/main/kotlin/com/codeaskush/reversed/VerseWidgetProvider.kt
android/app/src/main/res/{layout,xml,drawable}/   widget layout + metadata
ios/ReversedWidget/         WidgetKit extension sources (add target in Xcode)
ios/Runner/BackgroundIntent.swift                 App Intent for widget shuffle
test/                       unit tests for picker, data, preferences
docs/                       tech stack notes, iOS widget setup
```

## Getting started

Requirements: Flutter 3.35+ (Dart 3.9+), Android Studio or Xcode 15+.

```bash
flutter pub get
flutter analyze
flutter test
flutter run            # pick a device/emulator
```

### Android

Works out of the box: `flutter run` on a device or emulator, then long-press
the home screen → Widgets → Reversed. The in-app "Add widget" button uses the
pin-widget API on launchers that support it.

### iOS

The WidgetKit extension target has to be created once in Xcode (Flutter cannot
generate it). Follow [docs/ios-widget-setup.md](docs/ios-widget-setup.md); it
takes about five minutes. After that, `flutter run` works as usual.

## Adding verses or scriptures

- Add verses to `lib/data/gita_verses.dart` or `lib/data/bible_verses.dart`.
- To add a scripture: add a value to `Scripture` (`lib/models/scripture.dart`),
  a verse file, a case in `VerseRepository.versesOf`, and a `ScriptureChoice`
  entry. Tests in `test/verse_data_test.dart` guard the data.

## Sources

- Bible: King James Version (public domain).
- Bhagavad Gita: English renderings based on public-domain translations
  (Swami Swarupananda, 1909; Edwin Arnold, 1885).

## License

MIT – see [LICENSE](LICENSE).
