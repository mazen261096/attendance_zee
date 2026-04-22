import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/supabase_service.dart';

import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/stats_card.dart';
import '../../../lectures/view/widgets/lecture_card.dart';
import '../../../lectures/view_model/lecture_cubit.dart';
import '../../../lectures/view_model/lecture_state.dart';
import '../../../grades/view_model/grade_cubit.dart';
import '../../../grades/view_model/grade_state.dart';
import '../../../grades/view/widgets/grade_card.dart';
import '../../../grades/view/widgets/create_grade_item_sheet.dart';
import '../../data/models/course_model.dart';
import '../../view_model/course_cubit.dart';
import '../../view_model/course_state.dart';
import '../widgets/member_tile.dart';
import '../widgets/join_request_tile.dart';

class CourseDetailScreen extends StatefulWidget {
  final CourseModel course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final CourseCubit _courseCubit;
  late final LectureCubit _lectureCubit;
  late final GradeCubit _gradeCubit;
  late final String _currentUserId;
  late bool _isAdmin;

  @override
  void initState() {
    super.initState();
    _currentUserId = SupabaseService().currentUser?.id ?? '';
    _isAdmin = widget.course.ownerId == _currentUserId;

    _tabController = TabController(
      length: _isAdmin ? 6 : 5,
      vsync: this,
    );

    _courseCubit = getIt<CourseCubit>();
    _lectureCubit = getIt<LectureCubit>();
    _gradeCubit = getIt<GradeCubit>();

    // Load data
    _courseCubit.getCourseMembers(courseId: widget.course.id);
    _lectureCubit.getCourseLectures(courseId: widget.course.id);
    _courseCubit.getAttendanceSummary(courseId: widget.course.id);
    if (_isAdmin) {
      _courseCubit.getJoinRequests(courseId: widget.course.id);
    }
    _courseCubit.getCourseFiles(courseId: widget.course.id);
    _gradeCubit.getCourseGradeItems(courseId: widget.course.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _courseCubit.close();
    _lectureCubit.close();
    _gradeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _courseCubit),
        BlocProvider.value(value: _lectureCubit),
        BlocProvider.value(value: _gradeCubit),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Text(
            widget.course.name,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: widget.course.code));
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
              icon: const Icon(Icons.share_outlined, size: 22),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              const Tab(text: 'Lectures'),
              const Tab(text: 'Members'),
              const Tab(text: 'Attendance'),
              const Tab(text: 'Grades'),
              const Tab(text: 'Files'),
              if (_isAdmin) const Tab(text: 'Settings'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildLecturesTab(context, theme, isDark),
            _buildMembersTab(context, theme, isDark),
            _buildAttendanceTab(context, theme, isDark),
            _buildGradesTab(context, theme, isDark),
            _buildFilesTab(context, theme, isDark),
            if (_isAdmin) _buildSettingsTab(context, theme, isDark),
          ],
        ),
        floatingActionButton: _isAdmin
            ? FloatingActionButton.extended(
                onPressed: () {
                  context.push(
                    Routes.createLecturePath(widget.course.id),
                  );
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Lecture'),
                backgroundColor: AppConfig.primaryColor,
                foregroundColor: Colors.white,
              )
            : null,
      ),
    );
  }

  // ── Lectures Tab ──
  Widget _buildLecturesTab(
      BuildContext context, ThemeData theme, bool isDark) {
    return BlocBuilder<LectureCubit, LectureState>(
      builder: (context, state) {
        if (state.isGetLecturesLoading) {
          return const AppLoadingIndicator();
        }
        if (state.hasGetLecturesError) {
          return AppErrorWidget(
            message: state.getLecturesError,
            onRetry: () => _lectureCubit.getCourseLectures(
                courseId: widget.course.id),
          );
        }
        if (state.lectures.isEmpty) {
          return AppEmptyState(
            icon: Icons.event_note_outlined,
            title: 'No Lectures Yet',
            subtitle: _isAdmin
                ? 'Tap + to create your first lecture'
                : 'No lectures have been added yet',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            _lectureCubit.getCourseLectures(courseId: widget.course.id);
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: state.lectures.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final lecture = state.lectures[index];
              return LectureCard(
                lecture: lecture,
                onTap: () => context.push(
                  Routes.lectureDetailPath(
                    widget.course.id,
                    lecture.id,
                  ),
                  extra: lecture,
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ── Members Tab ──
  Widget _buildMembersTab(
      BuildContext context, ThemeData theme, bool isDark) {
    return BlocBuilder<CourseCubit, CourseState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async {
            _courseCubit.getCourseMembers(courseId: widget.course.id);
            if (_isAdmin) {
              _courseCubit.getJoinRequests(courseId: widget.course.id);
            }
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Join Requests (admin only) ──
              if (_isAdmin && state.joinRequests.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.pending_actions_rounded,
                        size: 18, color: AppConfig.warningColor),
                    const SizedBox(width: 8),
                    Text(
                      'Pending Requests (${state.joinRequests.length})',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppConfig.warningColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...state.joinRequests
                    .where((r) => r.isPending)
                    .map((req) => JoinRequestTile(
                          request: req,
                          onApprove: () => _courseCubit.approveJoinRequest(
                            requestId: req.id,
                          ),
                          onReject: () => _courseCubit.rejectJoinRequest(
                            requestId: req.id,
                          ),
                        )),
                const Divider(height: 32),
              ],
              // ── Members List ──
              Row(
                children: [
                  Icon(Icons.people_rounded,
                      size: 18,
                      color: isDark ? Colors.grey[400] : Colors.grey[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Members (${state.members.length})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (state.isGetMembersLoading)
                const AppLoadingIndicator(itemCount: 3)
              else if (state.members.isEmpty)
                const AppEmptyState(
                  icon: Icons.people_outline,
                  title: 'No Members',
                  subtitle: 'Share the code to invite students',
                )
              else
                ...state.members.map((member) => MemberTile(
                      member: member,
                      isCurrentUserAdmin: _isAdmin,
                      currentUserId: _currentUserId,
                      onRemove: (m) => _courseCubit.removeMember(
                        memberId: m.id,
                      ),
                    )),
            ],
          ),
        );
      },
    );
  }

  // ── Attendance Tab ──
  Widget _buildAttendanceTab(
      BuildContext context, ThemeData theme, bool isDark) {
    return BlocBuilder<CourseCubit, CourseState>(
      builder: (context, state) {
        if (state.isGetAttendanceSummaryLoading) {
          return const AppLoadingIndicator();
        }
        if (state.attendanceSummary.isEmpty) {
          return const AppEmptyState(
            icon: Icons.event_available_outlined,
            title: 'No Attendance Data',
            subtitle: 'Attendance records will appear\nhere once lectures begin',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            _courseCubit.getAttendanceSummary(courseId: widget.course.id);
          },
          child: Column(
            children: [
              // Total lectures header
              Container(
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    final userName = member['user_name'] as String? ?? 'Unknown';
                    final avatarUrl = member['user_avatar_url'] as String?;
                    final attended = member['attended_count'] as int? ?? 0;
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
                          // Avatar
                          _buildMemberAvatar(userName, avatarUrl),
                          const SizedBox(width: 12),
                          // Name + percentage
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                // Progress bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: total > 0
                                        ? (attended / total).clamp(0.0, 1.0)
                                        : 0,
                                    minHeight: 4,
                                    backgroundColor: isDark
                                        ? Colors.white.withValues(alpha: 0.06)
                                        : Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation(
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
                          // Count badge
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

  // ── Grades Tab ──
  Widget _buildGradesTab(
      BuildContext context, ThemeData theme, bool isDark) {
    return BlocBuilder<GradeCubit, GradeState>(
      builder: (context, state) {
        if (state.isGetGradeItemsLoading) {
          return const AppLoadingIndicator();
        }
        if (state.gradeItems.isEmpty) {
          return AppEmptyState(
            icon: Icons.assessment_outlined,
            title: 'No Grade Items',
            subtitle: _isAdmin
                ? 'Create grade items like exams,\nquizzes, or assignments'
                : 'No grade items have been\nadded yet',
            actionLabel: _isAdmin ? 'Create Item' : null,
            onAction: _isAdmin
                ? () => CreateGradeItemSheet.show(context, widget.course.id)
                : null,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            _gradeCubit.getCourseGradeItems(courseId: widget.course.id);
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: state.gradeItems.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              // First item: Total Grades card
              if (index == 0) {
                return _buildTotalGradesCard(context);
              }

              final item = state.gradeItems[index - 1];
              return GradeCard(
                name: item.name,
                type: item.type,
                maxDegree: item.maxDegree,
                onTap: () => context.push(
                  Routes.gradeItemDetailPath(widget.course.id, item.id),
                  extra: item,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTotalGradesCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(Routes.totalGradesPath(widget.course.id)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppConfig.primaryColor,
              AppConfig.primaryColor.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppConfig.primaryColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.leaderboard_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Grades',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'View all members ranking',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // ── Files Tab ──
  Widget _buildFilesTab(
      BuildContext context, ThemeData theme, bool isDark) {
    return BlocBuilder<CourseCubit, CourseState>(
      builder: (context, state) {
        if (state.isGetCourseFilesLoading) {
          return const AppLoadingIndicator();
        }
        if (state.courseFiles.isEmpty) {
          return const AppEmptyState(
            icon: Icons.folder_open_outlined,
            title: 'No Files',
            subtitle: 'No course materials have been uploaded yet',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: state.courseFiles.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final file = state.courseFiles[index];
            return ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppConfig.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.insert_drive_file_outlined,
                    color: AppConfig.accentColor, size: 22),
              ),
              title: Text(
                file.fileName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              trailing: _isAdmin
                  ? IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppConfig.errorColor, size: 20),
                      onPressed: () =>
                          _courseCubit.deleteCourseFile(fileId: file.id),
                    )
                  : const Icon(Icons.download_outlined, size: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            );
          },
        );
      },
    );
  }

  // ── Settings Tab (admin) ──
  Widget _buildSettingsTab(
      BuildContext context, ThemeData theme, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Course Code
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1A1A2E)
                : AppConfig.primaryColor.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppConfig.primaryColor.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            children: [
              const Icon(Icons.qr_code_rounded,
                  color: AppConfig.primaryColor, size: 36),
              const SizedBox(height: 12),
              Text(
                widget.course.code,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  fontFamily: 'monospace',
                  color: AppConfig.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Share this code with your students',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Stats
        BlocBuilder<CourseCubit, CourseState>(
          builder: (context, state) {
            return BlocBuilder<LectureCubit, LectureState>(
              builder: (context, lState) {
                return Row(
                  children: [
                    Expanded(
                      child: StatsCard(
                        icon: Icons.people_rounded,
                        value: '${state.members.length}',
                        label: 'Members',
                        color: AppConfig.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatsCard(
                        icon: Icons.event_note_rounded,
                        value: '${lState.lectures.length}',
                        label: 'Lectures',
                        color: AppConfig.accentColor,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        const SizedBox(height: 24),
        // Delete Course
        OutlinedButton.icon(
          onPressed: () => _confirmDeleteCourse(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppConfig.errorColor,
            side: const BorderSide(color: AppConfig.errorColor),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Delete Course'),
        ),
      ],
    );
  }

  void _confirmDeleteCourse(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Course'),
        content: const Text(
            'This will permanently delete this course and all its data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _courseCubit.deleteCourse(courseId: widget.course.id);
              context.pop();
            },
            child: const Text('Delete',
                style: TextStyle(color: AppConfig.errorColor)),
          ),
        ],
      ),
    );
  }
}
