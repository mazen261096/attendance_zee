import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../auth/view_model/auth_cubit.dart';
import '../../view_model/profile_cubit.dart';
import '../../view_model/profile_state.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // ── Avatar ──
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        AppConfig.primaryColor,
                        AppConfig.primaryLightColor,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppConfig.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: state.profile?.avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            state.profile!.avatarUrl!,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                            errorBuilder: (_, __, ___) =>
                                _buildInitial(state),
                          ),
                        )
                      : _buildInitial(state),
                ),
                const SizedBox(height: 16),
                // Name
                Text(
                  state.profile?.name ?? 'Loading...',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  SupabaseService().currentUser?.email ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                // ── Menu Items ──
                _MenuItem(
                  icon: Icons.edit_outlined,
                  label: 'Edit Profile',
                  onTap: () => context.push(Routes.editProfile),
                  isDark: isDark,
                ),
                _MenuItem(
                  icon: Icons.lock_outline,
                  label: 'Change Password',
                  onTap: () => context.push(Routes.changePassword),
                  isDark: isDark,
                ),
                _MenuItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () => context.push(Routes.settings),
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _MenuItem(
                  icon: Icons.logout_rounded,
                  label: 'Sign Out',
                  isDestructive: true,
                  onTap: () => _confirmSignOut(context),
                  isDark: isDark,
                ),
                const SizedBox(height: 32),
                // App version
                Text(
                  '${AppConfig.appName} v${AppConfig.appVersion}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInitial(ProfileState state) {
    final initial = (state.profile?.name ?? '?')[0].toUpperCase();
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              getIt<AuthCubit>().signOut();
              context.go(Routes.login);
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppConfig.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppConfig.errorColor
        : isDark
            ? Colors.white
            : Colors.black87;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDestructive
                ? AppConfig.errorColor.withValues(alpha: 0.1)
                : isDark
                    ? const Color(0xFF1E1E2E)
                    : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        title: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, color: color),
        ),
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
