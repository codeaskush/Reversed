import 'package:flutter/material.dart';

import '../models/app_preferences.dart';

/// Builds light/dark Material 3 themes from the chosen accent.
abstract final class AppTheme {
  static const verseFontFamily = 'Georgia';
  static const verseFontFallback = ['Times New Roman', 'Noto Serif', 'serif'];

  static ThemeData light(AccentPalette accent) =>
      _build(accent, Brightness.light);

  static ThemeData dark(AccentPalette accent) =>
      _build(accent, Brightness.dark);

  static ThemeData _build(AccentPalette accent, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent.color,
      brightness: brightness,
    );
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    return base.copyWith(
      appBarTheme: const AppBarTheme(centerTitle: false),
      cardTheme: base.cardTheme.copyWith(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Serif style used for verse text everywhere in the app.
  static TextStyle verseStyle(BuildContext context, {double size = 22}) =>
      Theme.of(context).textTheme.bodyLarge!.copyWith(
        fontFamily: verseFontFamily,
        fontFamilyFallback: verseFontFallback,
        fontSize: size,
        height: 1.45,
      );
}
