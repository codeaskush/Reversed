import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_preferences.dart';
import '../models/verse.dart';

/// Persists [AppPreferences] and the "today's override" verse.
class PreferencesStore {
  PreferencesStore(this._prefs);

  final SharedPreferences _prefs;

  static const _prefix = 'prefs.';
  static const _overrideDayKey = 'override.day';
  static const _overrideVerseKey = 'override.verse';

  AppPreferences load() {
    final map = <String, String?>{
      for (final key in AppPreferences.defaults.toMap().keys)
        key: _prefs.getString('$_prefix$key'),
    };
    return AppPreferences.fromMap(map);
  }

  Future<void> save(AppPreferences preferences) async {
    for (final entry in preferences.toMap().entries) {
      await _prefs.setString('$_prefix${entry.key}', entry.value);
    }
  }

  /// The verse id the user explicitly picked for [day], if any.
  String? overrideFor(DateTime day) {
    if (_prefs.getString(_overrideDayKey) != formatDayKey(day)) return null;
    return _prefs.getString(_overrideVerseKey);
  }

  Future<void> setOverride(DateTime day, String verseId) async {
    await _prefs.setString(_overrideDayKey, formatDayKey(day));
    await _prefs.setString(_overrideVerseKey, verseId);
  }

  Future<void> clearOverride() async {
    await _prefs.remove(_overrideDayKey);
    await _prefs.remove(_overrideVerseKey);
  }
}
