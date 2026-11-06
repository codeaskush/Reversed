# Tech stack decision

## The one thing that shapes everything

Neither Flutter nor React Native can draw a home-screen widget. On iOS a widget
is a **WidgetKit extension written in SwiftUI**; on Android it is an
**AppWidgetProvider rendering RemoteViews** (or Glance). Both are sandboxed
from the app process, so the cross-platform framework only ever runs *inside
the app*. Its job for the widget is to compute data and hand it over.

That makes the framework choice mostly about (a) how good the bridge to the
native widgets is and (b) how pleasant the app itself is to build.

## Flutter vs React Native for this app

| | Flutter | React Native (Expo) |
| --- | --- | --- |
| Widget bridge | `home_widget`: one package covers both platforms, data sharing, widget refresh, launch-from-widget, and **interactive widgets that run Dart in the background** (iOS 17 App Intents, Android broadcast). Mature, actively maintained. | Two separate packages: `react-native-android-widget` (Android, JSX → RemoteViews) and `@bacons/apple-targets` or hand-written WidgetKit (iOS). Interactive iOS widgets need custom native code. |
| Headless/background execution | First-class: a Dart entry point can run in a background isolate for widget taps. | Headless JS on Android is OK; iOS background JS for widget intents is awkward. |
| Settings/theme UI | Material 3 built in; `ColorScheme.fromSeed` gives a full theme from one accent colour. | Needs a UI kit (Paper, Tamagui, NativeWind). |
| Native code you must write anyway | Kotlin widget provider + Swift WidgetKit view. | Same. |
| Toolchain | Single SDK, `flutter create`, `flutter test`. | Node + Expo/CLI + Metro + CocoaPods. |
| Where it loses | Hot reload doesn't reach the native widget; you still touch Xcode once. | Same, plus two bridges to keep in sync. |

**Decision: Flutter + `home_widget`.** Fewer moving parts for exactly the
feature this app is about, a built-in theming system for the settings
screen, and the background-isolate story makes the widget's shuffle button
work on both platforms with one Dart function.

If you were already a React Native shop, `react-native-android-widget` +
a hand-written WidgetKit extension would be fine. For a greenfield widget-first
app, Flutter is the shorter path.

## Supporting choices

- **State:** `flutter_riverpod` 3. Small surface, compile-safe, no code-gen
  needed; `AsyncNotifier` makes "today's verse" naturally reactive to
  preference changes.
- **Persistence:** `shared_preferences` for app settings. Widget data goes
  through `home_widget`, which writes to the iOS App Group `UserDefaults` and
  Android `SharedPreferences` the native widgets read.
- **Verse data:** bundled Dart constants. The catalogue is small, it must work
  offline, and a constant list is trivially testable. Move to JSON assets or
  SQLite when the catalogue grows past a few hundred verses.
- **Daily selection:** deterministic per calendar day (shuffled cycles so
  every verse appears once per cycle, no repeats inside a cycle). The app
  pre-computes a 14-day schedule so the widgets roll over at midnight on their
  own: WidgetKit consumes it as a timeline; Android re-reads it on its periodic
  update and on date-change broadcasts.
- **Android widget rendering:** classic `RemoteViews` rather than Glance. The
  layout is three text views and an icon; Glance would add a Compose runtime
  dependency for no benefit here.
- **Minimum OS:** Android 7 (API 24, Flutter default); iOS 14 for the widget,
  iOS 17 for the shuffle button (it degrades to a static icon below 17).

## What is intentionally not here (yet)

- Remote verse catalogue / CMS.
- Notifications ("verse at 7 am").
- Lock-screen (accessory) widgets on iOS — easy to add as more
  `supportedFamilies` once the base widget is in place.
- Original-language text (Sanskrit / Hebrew / Greek) alongside translations.
