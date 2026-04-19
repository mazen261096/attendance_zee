import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../data/models/grade_item_model.dart';
import '../../view_model/grade_cubit.dart';
import '../../view_model/grade_state.dart';

class GradeItemDetailScreen extends StatefulWidget {
  final GradeItemModel gradeItem;

  const GradeItemDetailScreen({super.key, required this.gradeItem});

  @override
  State<GradeItemDetailScreen> createState() => _GradeItemDetailScreenState();
}

class _GradeItemDetailScreenState extends State<GradeItemDetailScreen> {
  late final GradeCubit _gradeCubit;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _gradeCubit = getIt<GradeCubit>();
    _gradeCubit.getGradesForItem(gradeItemId: widget.gradeItem.id);
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
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
          title: Text(
            widget.gradeItem.name,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppConfig.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Max: ${widget.gradeItem.maxDegree.toStringAsFixed(widget.gradeItem.maxDegree == widget.gradeItem.maxDegree.roundToDouble() ? 0 : 1)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppConfig.primaryColor,
                ),
              ),
            ),
          ],
        ),
        body: BlocConsumer<GradeCubit, GradeState>(
          listener: (context, state) {
            if (state.isSetGradeSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Grade saved!'),
                  backgroundColor: AppConfig.successColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.isGetGradesForItemLoading) {
              return const AppLoadingIndicator();
            }
            if (state.gradesForItem.isEmpty) {
              return const AppEmptyState(
                icon: Icons.people_outline,
                title: 'No Student Grades',
                subtitle: 'No students enrolled or\nno grades set yet',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: state.gradesForItem.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final grade = state.gradesForItem[index];
                // Create controller if needed
                _controllers.putIfAbsent(
                  grade.userId,
                  () => TextEditingController(
                    text: grade.degree.toStringAsFixed(
                        grade.degree == grade.degree.roundToDouble() ? 0 : 1),
                  ),
                );

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
                      // Avatar
                      _buildAvatar(grade.userName, grade.userAvatarUrl),
                      const SizedBox(width: 12),
                      // Name
                      Expanded(
                        child: Text(
                          grade.userName ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      // Grade input
                      SizedBox(
                        width: 72,
                        child: TextFormField(
                          controller: _controllers[grade.userId],
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 10),
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Save
                      IconButton(
                        icon: state.isSetGradeLoading
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppConfig.successColor,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline,
                                color: AppConfig.successColor),
                        onPressed: () {
                          final val = double.tryParse(
                              _controllers[grade.userId]?.text ?? '');
                          if (val == null) return;
                          _gradeCubit.setStudentGrade(
                            gradeItemId: widget.gradeItem.id,
                            userId: grade.userId,
                            degree: val,
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
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
