import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../view_model/grade_cubit.dart';
import '../../view_model/grade_state.dart';

class TotalGradesScreen extends StatefulWidget {
  final String courseId;

  const TotalGradesScreen({super.key, required this.courseId});

  @override
  State<TotalGradesScreen> createState() => _TotalGradesScreenState();
}

class _TotalGradesScreenState extends State<TotalGradesScreen> {
  late final GradeCubit _gradeCubit;

  @override
  void initState() {
    super.initState();
    _gradeCubit = getIt<GradeCubit>();
    _gradeCubit.getTotalGrades(courseId: widget.courseId);
  }

  @override
  void dispose() {
    _gradeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider.value(
      value: _gradeCubit,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Total Grades',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
        ),
        body: BlocBuilder<GradeCubit, GradeState>(
          builder: (context, state) {
            if (state.isTotalGradesLoading) {
              return const AppLoadingIndicator();
            }
            if (state.totalGradeMembers.isEmpty) {
              return const AppEmptyState(
                icon: Icons.people_outline,
                title: 'No Members',
                subtitle: 'No students enrolled in\nthis course yet',
              );
            }

            final totalMax = state.totalMaxDegree;
            final maxStr = totalMax == totalMax.roundToDouble()
                ? totalMax.toStringAsFixed(0)
                : totalMax.toStringAsFixed(1);

            return RefreshIndicator(
              onRefresh: () async {
                _gradeCubit.getTotalGrades(courseId: widget.courseId);
              },
              child: Column(
                children: [
                  // Total max degree header
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppConfig.primaryColor,
                          AppConfig.primaryColor.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stars_rounded,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        const Text(
                          'Total Max Degree',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          maxStr,
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
                      itemCount: state.totalGradeMembers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final member = state.totalGradeMembers[index];
                        final rank = index + 1;
                        final degreeStr = member.totalDegree ==
                                member.totalDegree.roundToDouble()
                            ? member.totalDegree.toStringAsFixed(0)
                            : member.totalDegree.toStringAsFixed(1);

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
                              _buildRankBadge(rank, isDark),
                              const SizedBox(width: 12),
                              _buildAvatar(
                                  member.userName, member.userAvatarUrl),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  member.userName ?? 'Unknown',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppConfig.primaryColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$degreeStr / $maxStr',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: AppConfig.primaryColor,
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

  Widget _buildRankBadge(int rank, bool isDark) {
    Color bgColor;
    Color textColor;

    switch (rank) {
      case 1:
        bgColor = const Color(0xFFFFD700);
        textColor = Colors.black87;
        break;
      case 2:
        bgColor = const Color(0xFFC0C0C0);
        textColor = Colors.black87;
        break;
      case 3:
        bgColor = const Color(0xFFCD7F32);
        textColor = Colors.white;
        break;
      default:
        bgColor = isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.grey.shade100;
        textColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 12,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildAvatar(String? name, String? url) {
    if (url != null) {
      return CircleAvatar(radius: 20, backgroundImage: NetworkImage(url));
    }
    final initial = (name ?? '?')[0].toUpperCase();
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppConfig.primaryColor.withValues(alpha: 0.15),
      child: Text(
        initial,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppConfig.primaryColor,
          fontSize: 16,
        ),
      ),
    );
  }
}
