import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/routes/routes.dart';
import '../../../core/services/supabase_service.dart';
import '../../auth/view_model/auth_cubit.dart';
import '../../profile/view_model/profile_cubit.dart';
import '../../profile/view_model/profile_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ProfileCubit _profileCubit;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _profileCubit = getIt<ProfileCubit>();
    final userId = SupabaseService().currentUser?.id;
    if (userId != null) {
      _profileCubit.getProfile(profileId: userId);
    }
  }

  @override
  void dispose() {
    _profileCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider.value(
      value: _profileCubit,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedTab,
          children: [
            _buildCoursesTab(context, theme, isDark),
            _buildProfileTab(context, theme, isDark),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedTab,
          onDestinationSelected: (i) => setState(() => _selectedTab = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book_rounded),
              label: 'Courses',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outlined),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesTab(BuildContext context, ThemeData theme, bool isDark) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Courses',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage your courses & attendance',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: Navigate to notifications
                        },
                        icon: const Icon(Icons.notifications_outlined),
                        style: IconButton.styleFrom(
                          backgroundColor: isDark
                              ? const Color(0xFF1E1E2E)
                              : Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Quick Actions
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.add_rounded,
                          label: 'Create\nCourse',
                          color: AppConfig.primaryColor,
                          onTap: () {
                            // TODO: Create course
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.qr_code_rounded,
                          label: 'Join by\nCode',
                          color: AppConfig.accentColor,
                          onTap: () {
                            // TODO: Join by code
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Empty State
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1E2E)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.school_outlined,
                      size: 40,
                      color: isDark
                          ? Colors.grey[600]
                          : Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No Courses Yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a course or join one\nusing a course code',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab(BuildContext context, ThemeData theme, bool isDark) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Avatar
                Stack(
                  children: [
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
                                errorBuilder: (_, __, ___) =>
                                    _buildAvatarPlaceholder(state),
                              ),
                            )
                          : _buildAvatarPlaceholder(state),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                // Menu Items
                _buildMenuItem(
                  context,
                  icon: Icons.edit_outlined,
                  label: 'Edit Profile',
                  onTap: () => context.push(Routes.editProfile),
                  isDark: isDark,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.lock_outline,
                  label: 'Change Password',
                  onTap: () {
                    // TODO: Navigate to change password
                  },
                  isDark: isDark,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  onTap: () {
                    // TODO: Navigate to notifications
                  },
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildMenuItem(
                  context,
                  icon: Icons.logout_rounded,
                  label: 'Sign Out',
                  isDestructive: true,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Sign Out'),
                        content: const Text(
                            'Are you sure you want to sign out?'),
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
                            child: Text(
                              'Sign Out',
                              style: TextStyle(color: AppConfig.errorColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarPlaceholder(ProfileState state) {
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

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    bool isDestructive = false,
  }) {
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
                    : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color,
          ),
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

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
