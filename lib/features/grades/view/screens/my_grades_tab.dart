import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../data/models/student_grade_model.dart';
import '../../view_model/grade_cubit.dart';
import '../../view_model/grade_state.dart';

class MyGradesTab extends StatefulWidget {
  const MyGradesTab({super.key});

  @override
  State<MyGradesTab> createState() => _MyGradesTabState();
}

class _MyGradesTabState extends State<MyGradesTab> {
  String? _selectedCourse; // null = All

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<GradeCubit, GradeState>(
      builder: (context, state) {
        // Extract unique course names
        final courseNames = state.myGrades
            .map((g) => g.courseName)
            .where((n) => n != null)
            .cast<String>()
            .toSet()
            .toList()
          ..sort();

        // Filter grades
        final filtered = _selectedCourse == null
            ? state.myGrades
            : state.myGrades
                .where((g) => g.courseName == _selectedCourse)
                .toList();

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<GradeCubit>().getAllMyGrades();
            },
            child: CustomScrollView(
              slivers: [
                // ── Header ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
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
                      ],
                    ),
                  ),
                ),

                // ── Course Filter Chips ──
                if (courseNames.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: courseNames.length + 1,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _buildChip(
                                label: 'All',
                                isSelected: _selectedCourse == null,
                                onTap: () =>
                                    setState(() => _selectedCourse = null),
                                isDark: isDark,
                              );
                            }
                            final course = courseNames[index - 1];
                            return _buildChip(
                              label: course,
                              isSelected: _selectedCourse == course,
                              onTap: () =>
                                  setState(() => _selectedCourse = course),
                              isDark: isDark,
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 14)),

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
                else if (filtered.isEmpty)
                  const SliverFillRemaining(
                    child: AppEmptyState(
                      icon: Icons.filter_list_off_rounded,
                      title: 'No Grades',
                      subtitle: 'No grades found for\nthis course',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    sliver: SliverList.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final grade = filtered[index];
                        return _buildGradeRow(grade, isDark);
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

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppConfig.primaryColor
              : isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppConfig.primaryColor
                : isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : isDark
                    ? Colors.grey[400]
                    : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildGradeRow(StudentGradeModel grade, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grade.gradeItemName ?? 'Grade Item',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                if (grade.courseName != null && _selectedCourse == null) ...[
                  const SizedBox(height: 2),
                  Text(
                    grade.courseName!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppConfig.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${grade.degree.toStringAsFixed(grade.degree == grade.degree.roundToDouble() ? 0 : 1)} / ${(grade.maxDegree ?? 100).toStringAsFixed((grade.maxDegree ?? 100) == (grade.maxDegree ?? 100).roundToDouble() ? 0 : 1)}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: AppConfig.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
