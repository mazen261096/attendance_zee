import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/supabase_service.dart';
import '../../data/models/course_model.dart';

class CourseDetailScreen extends StatelessWidget {
  final CourseModel course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUserId = SupabaseService().currentUser?.id ?? '';
    final isAdmin = course.ownerId == currentUserId;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Collapsing App Bar ──
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: Colors.white),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share_outlined,
                      size: 18, color: Colors.white),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: course.code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Course code copied!'),
                      backgroundColor: AppConfig.successColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppConfig.primaryDarkColor,
                      AppConfig.primaryColor,
                      AppConfig.primaryLightColor,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          course.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.tag_rounded,
                                      size: 14, color: Colors.white70),
                                  const SizedBox(width: 4),
                                  Text(
                                    course.code,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      letterSpacing: 1.5,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isAdmin
                                        ? Icons.admin_panel_settings_rounded
                                        : Icons.school_rounded,
                                    size: 14,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isAdmin ? 'Admin' : 'Student',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Grid ──
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.15,
              ),
              delegate: SliverChildListDelegate([
                _GridCard(
                  icon: Icons.event_note_rounded,
                  title: 'Lectures',
                  subtitle: 'View all lectures',
                  gradient: const [Color(0xFF6366F1), Color(0xFF818CF8)],
                  onTap: () => context.push(
                    Routes.courseLecturesPath(course.id),
                    extra: {'courseId': course.id, 'courseName': course.name, 'isAdmin': isAdmin},
                  ),
                ),
                if (isAdmin)
                  _GridCard(
                    icon: Icons.people_rounded,
                    title: 'Members',
                    subtitle: 'Students & requests',
                    gradient: const [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                    onTap: () => context.push(
                      Routes.courseMembersPath(course.id),
                      extra: {'courseId': course.id, 'courseName': course.name, 'isAdmin': isAdmin},
                    ),
                  ),
                _GridCard(
                  icon: Icons.fact_check_rounded,
                  title: 'Attendance',
                  subtitle: 'Track presence',
                  gradient: const [Color(0xFF10B981), Color(0xFF34D399)],
                  onTap: () => context.push(
                    Routes.courseAttendancePath(course.id),
                    extra: {'courseId': course.id, 'courseName': course.name},
                  ),
                ),
                if (isAdmin)
                  _GridCard(
                    icon: Icons.assessment_rounded,
                    title: 'Grades',
                    subtitle: 'Exams & scores',
                    gradient: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                    onTap: () => context.push(
                      Routes.courseGradesPath(course.id),
                    ),
                  ),
                _GridCard(
                  icon: Icons.folder_rounded,
                  title: 'Files',
                  subtitle: 'Course materials',
                  gradient: const [Color(0xFF06B6D4), Color(0xFF22D3EE)],
                  onTap: () => context.push(
                    Routes.courseFilesPath(course.id),
                    extra: {'courseId': course.id, 'courseName': course.name, 'isAdmin': isAdmin},
                  ),
                ),
                if (isAdmin)
                  _GridCard(
                    icon: Icons.settings_rounded,
                    title: 'Settings',
                    subtitle: 'Manage course',
                    gradient: const [Color(0xFF64748B), Color(0xFF94A3B8)],
                    onTap: () => context.push(
                      Routes.courseSettingsPath(course.id),
                      extra: course,
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Grid Card Widget ──

class _GridCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _GridCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.grey.shade100,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withValues(alpha: isDark ? 0.15 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon container with gradient
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: gradient[0].withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
