import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_indicator.dart';

import '../../view_model/course_cubit.dart';
import '../../view_model/course_state.dart';
import '../widgets/course_card.dart';
import '../widgets/create_course_bottom_sheet.dart';
import '../widgets/join_course_dialog.dart';

class CoursesTab extends StatelessWidget {
  const CoursesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentUserId = SupabaseService().currentUser?.id ?? '';

    return BlocBuilder<CourseCubit, CourseState>(
      builder: (context, state) {
        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<CourseCubit>().getMyCourses();
            },
            child: CustomScrollView(
              slivers: [
                // ── Header ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
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
                        const SizedBox(height: 20),
                        // Quick Actions
                        Row(
                          children: [
                            Expanded(
                              child: _QuickActionCard(
                                icon: Icons.add_rounded,
                                label: 'Create\nCourse',
                                color: AppConfig.primaryColor,
                                onTap: () => CreateCourseBottomSheet.show(context),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _QuickActionCard(
                                icon: Icons.qr_code_rounded,
                                label: 'Join by\nCode',
                                color: AppConfig.accentColor,
                                onTap: () => JoinCourseDialog.show(context),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                // ── Content ──
                if (state.isGetCoursesLoading)
                  const SliverFillRemaining(
                    child: AppLoadingIndicator(),
                  )
                else if (state.hasGetCoursesError)
                  SliverFillRemaining(
                    child: AppErrorWidget(
                      message: state.getCoursesError,
                      onRetry: () =>
                          context.read<CourseCubit>().getMyCourses(),
                    ),
                  )
                else if (state.courses.isEmpty)
                  SliverFillRemaining(
                    child: AppEmptyState(
                      icon: Icons.school_outlined,
                      title: 'No Courses Yet',
                      subtitle:
                          'Create a course or join one\nusing a course code',
                      actionLabel: 'Create Course',
                      onAction: () =>
                          CreateCourseBottomSheet.show(context),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    sliver: SliverList.separated(
                      itemCount: state.courses.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final course = state.courses[index];
                        final role = course.ownerId == currentUserId
                            ? MemberRole.admin
                            : MemberRole.student;
                        return CourseCard(
                          course: course,
                          role: role,
                          onTap: () => context.push(
                            Routes.courseDetailPath(course.id),
                            extra: course,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
