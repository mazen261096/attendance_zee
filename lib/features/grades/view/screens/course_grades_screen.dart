import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../view_model/grade_cubit.dart';
import '../../view_model/grade_state.dart';
import '../widgets/grade_card.dart';
import '../widgets/create_grade_item_sheet.dart';

class CourseGradesScreen extends StatefulWidget {
  final String courseId;

  const CourseGradesScreen({super.key, required this.courseId});

  @override
  State<CourseGradesScreen> createState() => _CourseGradesScreenState();
}

class _CourseGradesScreenState extends State<CourseGradesScreen> {
  late final GradeCubit _gradeCubit;

  @override
  void initState() {
    super.initState();
    _gradeCubit = getIt<GradeCubit>();
    // Correct method name is getCourseGradeItems
    _gradeCubit.getCourseGradeItems(courseId: widget.courseId);
  }

  @override
  void dispose() {
    _gradeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _gradeCubit,
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'Course Grades',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ),
          body: BlocBuilder<GradeCubit, GradeState>(
            builder: (context, state) {
              if (state.isGetGradeItemsLoading) {
                return const AppLoadingIndicator();
              }
              if (state.gradeItems.isEmpty) {
                return AppEmptyState(
                  icon: Icons.assessment_outlined,
                  title: 'No Grade Items',
                  subtitle:
                      'Create grade items like exams,\nquizzes, or assignments',
                  actionLabel: 'Create Item',
                  onAction: () =>
                      CreateGradeItemSheet.show(context, widget.courseId),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  _gradeCubit.getCourseGradeItems(courseId: widget.courseId);
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
                        Routes.gradeItemDetailPath(widget.courseId, item.id),
                        extra: item,
                      ),
                    );
                  },
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () =>
                CreateGradeItemSheet.show(context, widget.courseId),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Grade Item'),
            backgroundColor: AppConfig.primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTotalGradesCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push(Routes.totalGradesPath(widget.courseId)),
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
}
