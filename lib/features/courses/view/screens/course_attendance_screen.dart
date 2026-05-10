import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../view_model/course_cubit.dart';
import '../../view_model/course_state.dart';

class CourseAttendanceScreen extends StatefulWidget {
  final String courseId;
  final String courseName;

  const CourseAttendanceScreen({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<CourseAttendanceScreen> createState() => _CourseAttendanceScreenState();
}

class _CourseAttendanceScreenState extends State<CourseAttendanceScreen> {
  late final CourseCubit _courseCubit;

  @override
  void initState() {
    super.initState();
    _courseCubit = getIt<CourseCubit>();
    _courseCubit.getAttendanceSummary(courseId: widget.courseId);
  }

  @override
  void dispose() {
    _courseCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider.value(
      value: _courseCubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.courseName),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocBuilder<CourseCubit, CourseState>(
          builder: (context, state) {
            if (state.isGetAttendanceSummaryLoading) {
              return const AppLoadingIndicator();
            }
            if (state.attendanceSummary.isEmpty) {
              return const AppEmptyState(
                icon: Icons.event_available_outlined,
                title: 'No Attendance Data',
                subtitle:
                    'Attendance records will appear\nhere once lectures begin',
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _courseCubit.getAttendanceSummary(courseId: widget.courseId);
              },
              child: Column(
                children: [
                  // Total lectures header
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppConfig.accentColor,
                          AppConfig.accentColor.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        const Text(
                          'Total Lectures',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${state.totalLectures}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Members list
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: state.attendanceSummary.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final member = state.attendanceSummary[index];
                        final userName =
                            member['user_name'] as String? ?? 'Unknown';
                        final avatarUrl =
                            member['user_avatar_url'] as String?;
                        final attended =
                            member['attended_count'] as int? ?? 0;
                        final total = state.totalLectures;
                        final percentage = total > 0
                            ? (attended / total * 100).round()
                            : 0;

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1A1A2E)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              _buildMemberAvatar(userName, avatarUrl),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: total > 0
                                            ? (attended / total)
                                                .clamp(0.0, 1.0)
                                            : 0,
                                        minHeight: 4,
                                        backgroundColor: isDark
                                            ? Colors.white
                                                .withValues(alpha: 0.06)
                                            : Colors.grey.shade200,
                                        valueColor:
                                            AlwaysStoppedAnimation(
                                          percentage >= 75
                                              ? AppConfig.successColor
                                              : percentage >= 50
                                                  ? Colors.orange
                                                  : Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppConfig.accentColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$attended / $total',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: AppConfig.accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMemberAvatar(String name, String? url) {
    if (url != null) {
      return CircleAvatar(radius: 20, backgroundImage: NetworkImage(url));
    }
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppConfig.accentColor.withValues(alpha: 0.15),
      child: Text(
        initial,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppConfig.accentColor,
          fontSize: 16,
        ),
      ),
    );
  }
}
