import 'package:flutter/material.dart';

import 'scripture.dart';

/// Which scripture(s) the daily verse is drawn from.
enum ScriptureChoice {
  gita(id: 'gita', label: 'Bhagavad Gita'),
  bible(id: 'bible', label: 'Bible'),
  random(id: 'random', label: 'Surprise me');

  const ScriptureChoice({required this.id, required this.label});

  final String id;
  final String label;

  /// The scriptures this choice can draw from.
  List<Scripture> get scriptures => switch (this) {
    ScriptureChoice.gita => const [Scripture.gita],
    ScriptureChoice.bible => const [Scripture.bible],
    ScriptureChoice.random => Scripture.values,
  };

  static ScriptureChoice fromId(String? id) => values.firstWhere(
    (c) => c.id == id,
    orElse: () => ScriptureChoice.random,
  );
}

/// Seed colours the user can pick for the app and widget accent.
enum AccentPalette {
  saffron(id: 'saffron', label: 'Saffron', color: Color(0xFFE07A1F)),
  indigo(id: 'indigo', label: 'Indigo', color: Color(0xFF3F51B5)),
  teal(id: 'teal', label: 'Teal', color: Color(0xFF00897B)),
  rose(id: 'rose', label: 'Rose', color: Color(0xFFC2185B)),
  olive(id: 'olive', label: 'Olive', color: Color(0xFF6B8E23)),
  slate(id: 'slate', label: 'Slate', color: Color(0xFF546E7A));

  const AccentPalette({
    required this.id,
    required this.label,
    required this.color,
  });

  final String id;
  final String label;
  final Color color;

  static AccentPalette fromId(String? id) =>
      values.firstWhere((a) => a.id == id, orElse: () => AccentPalette.saffron);
}

/// Visual treatment of the home-screen widget.
enum WidgetStyle {
  glass(id: 'glass', label: 'Glass'),
  accent(id: 'accent', label: 'Accent'),
  paper(id: 'paper', label: 'Paper'),
  midnight(id: 'midnight', label: 'Midnight');

  const WidgetStyle({required this.id, required this.label});

  final String id;
  final String label;

  static WidgetStyle fromId(String? id) =>
      values.firstWhere((s) => s.id == id, orElse: () => WidgetStyle.glass);

  /// Whether the widget sits on a translucent / blurred backdrop. iOS uses a
  /// system material; Android and the in-app preview use [background] as a
  /// translucent tint.
  bool get isTranslucent => this == WidgetStyle.glass;

  /// Background colour of the widget for a given accent.
  Color background(AccentPalette accent) => switch (this) {
    WidgetStyle.glass => const Color(0x59000000),
    WidgetStyle.accent => accent.color,
    WidgetStyle.paper => const Color(0xFFFAF4E6),
    WidgetStyle.midnight => const Color(0xFF14161C),
  };

  /// Primary text colour of the widget for a given accent.
  Color foreground(AccentPalette accent) => switch (this) {
    WidgetStyle.glass => Colors.white,
    WidgetStyle.accent => Colors.white,
    WidgetStyle.paper => const Color(0xFF2B2420),
    WidgetStyle.midnight => const Color(0xFFF2EFE8),
  };

  /// Secondary / highlight colour of the widget for a given accent.
  Color highlight(AccentPalette accent) => switch (this) {
    WidgetStyle.glass => Colors.white.withValues(alpha: 0.85),
    WidgetStyle.accent => Colors.white.withValues(alpha: 0.85),
    WidgetStyle.paper => accent.color,
    WidgetStyle.midnight => accent.color,
  };
}

/// Text size of the verse inside the widget.
enum WidgetTextSize {
  small(id: 'small', label: 'Small', scale: 0.9),
  medium(id: 'medium', label: 'Medium', scale: 1.0),
  large(id: 'large', label: 'Large', scale: 1.15);

  const WidgetTextSize({
    required this.id,
    required this.label,
    required this.scale,
  });

  final String id;
  final String label;
  final double scale;

  static WidgetTextSize fromId(String? id) =>
      values.firstWhere((s) => s.id == id, orElse: () => WidgetTextSize.medium);
}

/// All user-adjustable settings. Immutable; use [copyWith].
@immutable
class AppPreferences {
  const AppPreferences({
    this.scriptureChoice = ScriptureChoice.random,
    this.themeMode = ThemeMode.system,
    this.accent = AccentPalette.saffron,
    this.widgetStyle = WidgetStyle.glass,
    this.widgetTextSize = WidgetTextSize.medium,
  });

  final ScriptureChoice scriptureChoice;
  final ThemeMode themeMode;
  final AccentPalette accent;
  final WidgetStyle widgetStyle;
  final WidgetTextSize widgetTextSize;

  static const defaults = AppPreferences();

  AppPreferences copyWith({
    ScriptureChoice? scriptureChoice,
    ThemeMode? themeMode,
    AccentPalette? accent,
    WidgetStyle? widgetStyle,
    WidgetTextSize? widgetTextSize,
  }) {
    return AppPreferences(
      scriptureChoice: scriptureChoice ?? this.scriptureChoice,
      themeMode: themeMode ?? this.themeMode,
      accent: accent ?? this.accent,
      widgetStyle: widgetStyle ?? this.widgetStyle,
      widgetTextSize: widgetTextSize ?? this.widgetTextSize,
    );
  }

  Map<String, String> toMap() => {
    'scripture': scriptureChoice.id,
    'theme': themeMode.name,
    'accent': accent.id,
    'widgetStyle': widgetStyle.id,
    'widgetTextSize': widgetTextSize.id,
  };

  factory AppPreferences.fromMap(Map<String, String?> map) => AppPreferences(
    scriptureChoice: ScriptureChoice.fromId(map['scripture']),
    themeMode: ThemeMode.values.firstWhere(
      (m) => m.name == map['theme'],
      orElse: () => ThemeMode.system,
    ),
    accent: AccentPalette.fromId(map['accent']),
    widgetStyle: WidgetStyle.fromId(map['widgetStyle']),
    widgetTextSize: WidgetTextSize.fromId(map['widgetTextSize']),
  );

  @override
  bool operator ==(Object other) =>
      other is AppPreferences &&
      other.scriptureChoice == scriptureChoice &&
      other.themeMode == themeMode &&
      other.accent == accent &&
      other.widgetStyle == widgetStyle &&
      other.widgetTextSize == widgetTextSize;

  @override
  int get hashCode => Object.hash(
    scriptureChoice,
    themeMode,
    accent,
    widgetStyle,
    widgetTextSize,
  );
}
