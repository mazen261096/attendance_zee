import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/settings/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = getIt<SettingsController>();
    final currentLocale = context.locale;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: settings,
          builder: (context, _) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // ── Appearance ──
                _SectionTitle(title: 'Appearance', isDark: isDark),
                const SizedBox(height: 12),
                _AppearanceCard(
                  isDark: isDark,
                  settings: settings,
                  currentLocale: currentLocale,
                  onThemeChanged: (mode) =>
                      settings.updateThemeMode(mode),
                  onLocaleChanged: (locale) =>
                      settings.updateLocale(context, locale),
                ),
                const SizedBox(height: 28),

                // ── About Section ──
                _SectionTitle(title: 'About', isDark: isDark),
                const SizedBox(height: 12),
                _buildAboutCard(theme, isDark),
                const SizedBox(height: 28),

                // ── Support ──
                _SectionTitle(title: 'Support', isDark: isDark),
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: Icons.email_outlined,
                  label: 'Contact Support',
                  subtitle: AppConfig.supportEmail,
                  isDark: isDark,
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.language_rounded,
                  label: 'Website',
                  subtitle: AppConfig.websiteUrl,
                  isDark: isDark,
                  onTap: () {},
                ),
                const SizedBox(height: 28),

                // ── Legal ──
                _SectionTitle(title: 'Legal', isDark: isDark),
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: Icons.description_outlined,
                  label: 'Terms of Service',
                  isDark: isDark,
                  onTap: () {},
                ),
                _buildMenuItem(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  isDark: isDark,
                  onTap: () {},
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAboutCard(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1A2E)
            : AppConfig.primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppConfig.primaryColor.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.school_rounded,
              color: AppConfig.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConfig.appName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Version ${AppConfig.appVersion}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Smart Attendance Management',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon,
              size: 20,
              color: isDark ? Colors.grey[400] : Colors.grey[700]),
        ),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
              )
            : null,
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: isDark ? Colors.grey[600] : Colors.grey[400],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

// ── Appearance Card ────────────────────────────────────────────────────────────

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard({
    required this.isDark,
    required this.settings,
    required this.currentLocale,
    required this.onThemeChanged,
    required this.onLocaleChanged,
  });

  final bool isDark;
  final SettingsController settings;
  final Locale currentLocale;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final surface =
        isDark ? const Color(0xFF1A1A2E) : AppConfig.primaryColor.withValues(alpha: 0.04);
    final border = AppConfig.primaryColor.withValues(alpha: 0.12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Theme Row ────────────────────────────────────────────────────
          _SettingRow(
            icon: Icons.palette_outlined,
            label: 'Theme',
            isDark: isDark,
            child: _ThemeSegmentedButton(
              current: settings.themeMode,
              onChanged: onThemeChanged,
            ),
          ),
          const SizedBox(height: 20),
          Divider(
            height: 1,
            color: AppConfig.primaryColor.withValues(alpha: 0.08),
          ),
          const SizedBox(height: 20),
          // ── Language Row ─────────────────────────────────────────────────
          _SettingRow(
            icon: Icons.translate_rounded,
            label: 'Language',
            isDark: isDark,
            child: _LanguageSegmentedButton(
              currentLocale: currentLocale,
              onChanged: onLocaleChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared Row Layout ─────────────────────────────────────────────────────────

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.child,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : AppConfig.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: AppConfig.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}

// ── Theme Segmented Button ────────────────────────────────────────────────────

class _ThemeSegmentedButton extends StatelessWidget {
  const _ThemeSegmentedButton({
    required this.current,
    required this.onChanged,
  });

  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ThemeMode>(
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: AppConfig.primaryColor,
        selectedForegroundColor: Colors.white,
        padding: EdgeInsets.zero,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      segments: const [
        ButtonSegment(
          value: ThemeMode.light,
          icon: Icon(Icons.light_mode_rounded, size: 16),
          label: Text('Light'),
        ),
        ButtonSegment(
          value: ThemeMode.system,
          icon: Icon(Icons.auto_mode_rounded, size: 16),
          label: Text('Auto'),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          icon: Icon(Icons.dark_mode_rounded, size: 16),
          label: Text('Dark'),
        ),
      ],
      selected: {current},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

// ── Language Segmented Button ─────────────────────────────────────────────────

class _LanguageSegmentedButton extends StatelessWidget {
  const _LanguageSegmentedButton({
    required this.currentLocale,
    required this.onChanged,
  });

  final Locale currentLocale;
  final ValueChanged<Locale> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: AppConfig.primaryColor,
        selectedForegroundColor: Colors.white,
        padding: EdgeInsets.zero,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      segments: const [
        ButtonSegment(
          value: 'en',
          label: Text('English'),
          icon: Text('🇬🇧', style: TextStyle(fontSize: 16)),
        ),
        ButtonSegment(
          value: 'ar',
          label: Text('العربية'),
          icon: Text('🇪🇬', style: TextStyle(fontSize: 16)),
        ),
      ],
      selected: {currentLocale.languageCode},
      onSelectionChanged: (s) => onChanged(Locale(s.first)),
    );
  }
}

// ── Section Title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.grey[500] : Colors.grey[500],
        letterSpacing: 1.2,
      ),
    );
  }
}
