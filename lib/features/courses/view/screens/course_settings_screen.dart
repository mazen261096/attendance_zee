import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/stats_card.dart';
import '../../data/models/course_model.dart';
import '../../view_model/course_cubit.dart';
import '../../view_model/course_state.dart';
import '../../../lectures/view_model/lecture_cubit.dart';
import '../../../lectures/view_model/lecture_state.dart';

class CourseSettingsScreen extends StatefulWidget {
  final CourseModel course;

  const CourseSettingsScreen({super.key, required this.course});

  @override
  State<CourseSettingsScreen> createState() => _CourseSettingsScreenState();
}

class _CourseSettingsScreenState extends State<CourseSettingsScreen> {
  late final CourseCubit _courseCubit;
  late final LectureCubit _lectureCubit;

  @override
  void initState() {
    super.initState();
    _courseCubit = getIt<CourseCubit>();
    _lectureCubit = getIt<LectureCubit>();
    _courseCubit.getCourseMembers(courseId: widget.course.id);
    _lectureCubit.getCourseLectures(courseId: widget.course.id);
  }

  @override
  void dispose() {
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
          title: const Text('Course Settings'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: ListView(
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
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: widget.course.code));
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
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Copy Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.primaryColor,
                      foregroundColor: Colors.white,
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
        ),
      ),
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
              // Pop back to courses list
              context.pop();
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
