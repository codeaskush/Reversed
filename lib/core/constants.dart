/// Identifiers shared between the Dart side and the native widget code.
///
/// If you change any of these, update the matching native files:
/// - Android: `android/app/src/main/kotlin/com/codeaskush/reversed/VerseWidgetProvider.kt`
/// - iOS: `ios/ReversedWidget/ReversedWidget.swift`
abstract final class AppConstants {
  /// iOS App Group shared between the Runner app and the widget extension.
  static const appGroupId = 'group.com.codeaskush.reversed';

  /// Android `AppWidgetProvider` class name (relative to the app package).
  static const androidWidgetName = 'VerseWidgetProvider';

  /// iOS WidgetKit `kind` of the verse widget.
  static const iosWidgetName = 'ReversedWidget';

  /// How many days of verses are pre-computed for the widget so it can
  /// rotate daily without the app being opened.
  static const scheduleDays = 14;

  /// URI scheme used for widget -> app interactions.
  static const interactionScheme = 'reversed';

  /// `reversed://next` asks the background isolate for a new verse.
  static const nextVerseHost = 'next';
}

/// Keys written with `HomeWidget.saveWidgetData` and read by native widgets.
abstract final class WidgetKeys {
  static const verseText = 'verse_text';
  static const verseReference = 'verse_reference';
  static const verseSource = 'verse_source';
  static const verseScripture = 'verse_scripture';
  static const verseDate = 'verse_date';
  static const schedule = 'verse_schedule';
  static const style = 'widget_style';
  static const backgroundColor = 'widget_bg';
  static const foregroundColor = 'widget_fg';
  static const accentColor = 'widget_accent';
  static const textScale = 'widget_text_scale';
}
