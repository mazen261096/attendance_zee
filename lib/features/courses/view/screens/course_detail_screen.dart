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
  late final String _currentUserId;
  late bool _isAdmin;

  @override
  void initState() {
    super.initState();
    _currentUserId = SupabaseService().currentUser?.id ?? '';
    _isAdmin = widget.course.ownerId == _currentUserId;

    _tabController = TabController(
      length: _isAdmin ? 4 : 3,
      vsync: this,
    );

    _courseCubit = getIt<CourseCubit>();
    _lectureCubit = getIt<LectureCubit>();

    // Load data
    _courseCubit.getCourseMembers(courseId: widget.course.id);
    _lectureCubit.getCourseLectures(courseId: widget.course.id);
    if (_isAdmin) {
      _courseCubit.getJoinRequests(courseId: widget.course.id);
    }
    _courseCubit.getCourseFiles(courseId: widget.course.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _courseCubit.close();
    _lectureCubit.close();
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
        // Grades link
        ListTile(
          onTap: () =>
              context.push(Routes.courseGradesPath(widget.course.id)),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppConfig.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.assessment_rounded,
                color: AppConfig.successColor, size: 20),
          ),
          title: const Text('Manage Grades',
              style: TextStyle(fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.chevron_right_rounded),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        const SizedBox(height: 32),
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
