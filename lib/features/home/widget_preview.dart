import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/app_preferences.dart';
import '../../models/verse.dart';

/// In-app replica of the home-screen widget so users can preview their
/// style and text-size choices before adding it.
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

    return AspectRatio(
      aspectRatio: 2.1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      verse.scripture.title.toUpperCase(),
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
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  verse.text,
                  maxLines: 5,
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
              const SizedBox(height: 6),
              Text(
                verse.reference,
                style: TextStyle(
                  color: hi,
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
