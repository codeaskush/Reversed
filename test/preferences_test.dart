import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reversed/models/app_preferences.dart';
import 'package:reversed/services/widget_sync.dart';

void main() {
  test('preferences round-trip through a string map', () {
    const prefs = AppPreferences(
      scriptureChoice: ScriptureChoice.bible,
      themeMode: ThemeMode.dark,
      accent: AccentPalette.teal,
      widgetStyle: WidgetStyle.midnight,
      widgetTextSize: WidgetTextSize.large,
    );
    expect(AppPreferences.fromMap(prefs.toMap()), prefs);
  });

  test('unknown or missing values fall back to defaults', () {
    final prefs = AppPreferences.fromMap({'scripture': 'quran', 'theme': null});
    expect(prefs, AppPreferences.defaults);
  });

  test('widget colours serialise as #AARRGGBB', () {
    expect(WidgetSync.toHex(const Color(0xFFE07A1F)), '#FFE07A1F');
    expect(WidgetSync.toHex(Colors.white), '#FFFFFFFF');
  });
}
