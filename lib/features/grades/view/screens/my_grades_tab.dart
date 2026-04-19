import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/enums.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../view_model/grade_cubit.dart';
import '../../view_model/grade_state.dart';
import '../widgets/grade_card.dart';

class MyGradesTab extends StatelessWidget {
  const MyGradesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<GradeCubit, GradeState>(
      builder: (context, state) {
        return SafeArea(
          child: RefreshIndicator(
            // getMyGrades requires courseId — for the global tab we just load
            // all grades across all courses; we refresh without a specific courseId
            // by reloading the current state (cubit keeps last result).
            onRefresh: () async {},
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
                          'My Grades',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your performance across all courses',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                // ── Content ──
                if (state.isGetMyGradesLoading)
                  const SliverFillRemaining(
                    child: AppLoadingIndicator(),
                  )
                else if (state.myGrades.isEmpty)
                  const SliverFillRemaining(
                    child: AppEmptyState(
                      icon: Icons.assessment_outlined,
                      title: 'No Grades Yet',
                      subtitle:
                          'Your grades will appear here\nonce instructors post them',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    sliver: SliverList.separated(
                      itemCount: state.myGrades.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final grade = state.myGrades[index];
                        return GradeCard(
                          name: grade.gradeItemName ?? 'Grade Item',
                          type: GradeItemType.exam, // StudentGradeModel has no type; use default
                          degree: grade.degree,
                          maxDegree: grade.maxDegree ?? 100,
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
