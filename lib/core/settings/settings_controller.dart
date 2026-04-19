import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';

/// Manages theme and locale preferences.
///
/// Priority:
/// 1. Local storage (SharedPreferences) — fast, instant.
/// 2. Supabase profile — synced across devices.
/// 3. System default — fallback when nothing is stored.
class SettingsController with ChangeNotifier {
  SettingsController(this._prefs);

  final SharedPreferences _prefs;
  static const String _themeKey = 'theme_mode';
  static const String _localeKey = 'locale_code';

  late ThemeMode _themeMode;
  late Locale _locale;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  /// Load settings from local storage on app startup.
  /// If nothing is stored locally, defaults to system.
  void loadSettings() {
    // Load Theme
    final themeString = _prefs.getString(_themeKey);
    if (themeString == 'light') {
      _themeMode = ThemeMode.light;
    } else if (themeString == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system; // No local preference → use system
    }

    // Load Locale
    final localeString = _prefs.getString(_localeKey);
    if (localeString != null) {
      _locale = Locale(localeString);
    } else {
      _locale = const Locale('en'); // Default to English
    }

    notifyListeners();
  }

  /// Apply preferences from Supabase profile (called after profile load).
  /// Only applies if NO local preference was explicitly set.
  void applyFromProfile({String? preferredLanguage, String? preferredTheme}) {
    bool changed = false;

    // Apply theme from profile if no local preference was set
    if (!_prefs.containsKey(_themeKey) && preferredTheme != null) {
      if (preferredTheme == 'light') {
        _themeMode = ThemeMode.light;
      } else if (preferredTheme == 'dark') {
        _themeMode = ThemeMode.dark;
      }
      // Save locally so next startup is instant
      _prefs.setString(_themeKey, preferredTheme);
      changed = true;
    }

    // Apply locale from profile if no local preference was set
    if (!_prefs.containsKey(_localeKey) && preferredLanguage != null) {
      _locale = Locale(preferredLanguage);
      _prefs.setString(_localeKey, preferredLanguage);
      changed = true;
    }

    if (changed) notifyListeners();
  }

  /// Update theme mode — saves locally + syncs to Supabase.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;
    notifyListeners();

    // Save locally
    final storageValue = newThemeMode == ThemeMode.light ? 'light' : 'dark';
    await _prefs.setString(_themeKey, storageValue);

    // Sync to Supabase (fire-and-forget)
    _syncToSupabase(preferredTheme: storageValue);
  }

  /// Update locale — saves locally + syncs to Supabase.
  Future<void> updateLocale(Locale? newLocale) async {
    if (newLocale == null) return;
    if (newLocale == _locale) return;

    _locale = newLocale;
    notifyListeners();

    // Save locally
    await _prefs.setString(_localeKey, newLocale.languageCode);

    // Sync to Supabase (fire-and-forget)
    _syncToSupabase(preferredLanguage: newLocale.languageCode);
  }

  /// Sync preferences to Supabase profile (silent, non-blocking).
  Future<void> _syncToSupabase({
    String? preferredTheme,
    String? preferredLanguage,
  }) async {
    try {
      final currentUser = SupabaseService().currentUser;
      if (currentUser == null) return;

      final Map<String, dynamic> data = {};
      if (preferredTheme != null) data['preferred_theme'] = preferredTheme;
      if (preferredLanguage != null) {
        data['preferred_language'] = preferredLanguage;
      }

      if (data.isNotEmpty) {
        await SupabaseService.client
            .from('profiles')
            .update(data)
            .eq('id', currentUser.id);
      }
    } catch (e) {
      debugPrint('Failed to sync settings to Supabase: $e');
      // Non-critical — local settings are already saved
    }
  }
}
