import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';

/// Manages theme and locale preferences.
///
/// Priority:
/// 1. Local storage (SharedPreferences / easy_localization) — fast, instant.
/// 2. Supabase profile — synced across devices.
/// 3. System default — fallback when nothing is stored.
///
/// NOTE: Locale is owned by easy_localization. We only drive ThemeMode here.
/// Locale changes go through `context.setLocale()` so easy_localization stays
/// the single source of truth and handles its own persistence automatically.
class SettingsController with ChangeNotifier {
  SettingsController(this._prefs);

  final SharedPreferences _prefs;
  static const String _themeKey = 'theme_mode';

  // ── internal state ─────────────────────────────────────────────────────────
  late ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  // ── init ───────────────────────────────────────────────────────────────────

  /// Load ThemeMode from local storage on app startup.
  void loadSettings() {
    final themeString = _prefs.getString(_themeKey);
    _themeMode = _parseThemeMode(themeString);
    notifyListeners();
  }

  // ── apply from Supabase profile ────────────────────────────────────────────

  /// Called after a successful profile fetch.
  /// Applies Supabase preferences ONLY when no local override exists.
  ///
  /// [context] is required to call `context.setLocale()` for easy_localization.
  Future<void> applyFromProfile({
    required BuildContext context,
    String? preferredTheme,
    String? preferredLanguage,
  }) async {
    bool changed = false;

    // Theme: apply from profile only if user never overrode it locally
    if (!_prefs.containsKey(_themeKey) && preferredTheme != null) {
      _themeMode = _parseThemeMode(preferredTheme);
      await _prefs.setString(_themeKey, preferredTheme);
      changed = true;
    }

    // Locale: easy_localization persists locale itself. We only override when
    // the user has never explicitly changed it (easy_localization stores in
    // the same SharedPreferences instance under its own key).
    if (preferredLanguage != null && context.mounted) {
      final easyLocKey = 'locale';
      final hasLocalLocale = _prefs.containsKey(easyLocKey);
      if (!hasLocalLocale) {
        await context.setLocale(Locale(preferredLanguage));
      }
    }

    if (changed) notifyListeners();
  }

  // ── update theme ───────────────────────────────────────────────────────────

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null || newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;
    notifyListeners();

    final storageValue = _themeModeToString(newThemeMode);
    await _prefs.setString(_themeKey, storageValue);

    // Sync to Supabase (fire-and-forget)
    _syncToSupabase(preferredTheme: storageValue);
  }

  // ── update locale ──────────────────────────────────────────────────────────

  /// Changes the app locale via easy_localization AND syncs to Supabase.
  ///
  /// easy_localization persists the locale automatically — we just add the
  /// Supabase sync on top.
  Future<void> updateLocale(BuildContext context, Locale newLocale) async {
    if (!context.mounted) return;

    // easy_localization handles persistence internally
    await context.setLocale(newLocale);

    // Sync to Supabase (fire-and-forget)
    _syncToSupabase(preferredLanguage: newLocale.languageCode);
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  /// Silently syncs preferences to Supabase profile (non-blocking).
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
      debugPrint('SettingsController: Failed to sync to Supabase: $e');
      // Non-critical — local settings are already saved.
    }
  }
}
