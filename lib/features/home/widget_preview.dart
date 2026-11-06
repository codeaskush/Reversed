import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/app_preferences.dart';
import '../../models/verse.dart';

/// In-app replica of the home-screen widget, drawn over a mock wallpaper so
/// translucent styles can be judged before adding the real widget.
class WidgetPreview extends StatelessWidget {
  const WidgetPreview({
    super.key,
    required this.verse,
    required this.preferences,
  });

  final Verse verse;
  final AppPreferences preferences;

  @override
  Widget build(BuildContext context) {
    final style = preferences.widgetStyle;
    final accent = preferences.accent;
    final bg = style.background(accent);
    final fg = style.foreground(accent);
    final hi = style.highlight(accent);
    final scale = preferences.widgetTextSize.scale;

    final card = Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wb_sunny_outlined, size: 16, color: hi),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'VERSE OF THE DAY',
                  style: TextStyle(
                    color: hi,
                    fontSize: 11,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.shuffle_rounded, size: 18, color: hi),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            verse.displayReference,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: fg,
              fontSize: 15 * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              verse.text,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fg,
                fontSize: 15 * scale,
                height: 1.35,
                fontFamily: AppTheme.verseFontFamily,
                fontFamilyFallback: AppTheme.verseFontFallback,
              ),
            ),
          ),
        ],
      ),
    );

    final radius = BorderRadius.circular(22);
    final widgetCard = ClipRRect(
      borderRadius: radius,
      child: style.isTranslucent
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: radius,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: card,
              ),
            )
          : DecoratedBox(
              decoration: BoxDecoration(color: bg, borderRadius: radius),
              child: card,
            ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8FB3D9), Color(0xFFD8C3B0), Color(0xFF6E8CA8)],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: AspectRatio(aspectRatio: 2.1, child: widgetCard),
      ),
    );
  }
}
