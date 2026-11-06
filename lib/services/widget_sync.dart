import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import '../core/constants.dart';
import '../models/app_preferences.dart';
import '../models/verse.dart';

/// Pushes verse data and styling to the native home-screen widgets.
class WidgetSync {
  const WidgetSync();

  /// Must be called once per isolate before any other call (iOS App Group).
  Future<void> init() async {
    await HomeWidget.setAppGroupId(AppConstants.appGroupId);
  }

  Future<void> push({
    required ScheduledVerse today,
    required List<ScheduledVerse> schedule,
    required AppPreferences preferences,
  }) async {
    final style = preferences.widgetStyle;
    final accent = preferences.accent;

    await Future.wait([
      HomeWidget.saveWidgetData<String>(WidgetKeys.verseText, today.verse.text),
      HomeWidget.saveWidgetData<String>(
        WidgetKeys.verseReference,
        today.verse.reference,
      ),
      HomeWidget.saveWidgetData<String>(
        WidgetKeys.verseSource,
        today.verse.scripture.title,
      ),
      HomeWidget.saveWidgetData<String>(
        WidgetKeys.verseScripture,
        today.verse.scripture.id,
      ),
      HomeWidget.saveWidgetData<String>(WidgetKeys.verseDate, today.dayKey),
      HomeWidget.saveWidgetData<String>(
        WidgetKeys.schedule,
        jsonEncode([for (final s in schedule) s.toJson()]),
      ),
      HomeWidget.saveWidgetData<String>(WidgetKeys.style, style.id),
      HomeWidget.saveWidgetData<String>(
        WidgetKeys.backgroundColor,
        toHex(style.background(accent)),
      ),
      HomeWidget.saveWidgetData<String>(
        WidgetKeys.foregroundColor,
        toHex(style.foreground(accent)),
      ),
      HomeWidget.saveWidgetData<String>(
        WidgetKeys.accentColor,
        toHex(style.highlight(accent)),
      ),
      // Stored as a string: home_widget encodes doubles as raw long bits on
      // Android, which is awkward to read from a plain AppWidgetProvider.
      HomeWidget.saveWidgetData<String>(
        WidgetKeys.textScale,
        preferences.widgetTextSize.scale.toString(),
      ),
    ]);

    await HomeWidget.updateWidget(
      androidName: AppConstants.androidWidgetName,
      iOSName: AppConstants.iosWidgetName,
    );
  }

  /// `#AARRGGBB`, parsed natively by both widgets.
  static String toHex(Color color) {
    final argb = color.toARGB32();
    return '#${argb.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }
}
