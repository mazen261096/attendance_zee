import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
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
          child: Icon(icon, size: 20,
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
