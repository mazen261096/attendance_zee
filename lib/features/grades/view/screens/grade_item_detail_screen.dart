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
  final Map<String, FocusNode> _focusNodes = {};

  /// Tracks the last saved value per user to avoid redundant saves.
  final Map<String, String> _lastSavedValues = {};

  @override
  void initState() {
    super.initState();
    _gradeCubit = getIt<GradeCubit>();
    _gradeCubit.loadMembersWithGrades(
      courseId: widget.gradeItem.courseId,
      gradeItemId: widget.gradeItem.id,
    );
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final f in _focusNodes.values) {
      f.dispose();
    }
    _gradeCubit.close();
    super.dispose();
  }

  void _onFocusLost(String userId) {
    final controller = _controllers[userId];
    if (controller == null) return;
    _saveGrade(userId, controller.text);
  }

  void _saveGrade(String userId, String value) {
    final trimmed = value.trim();
    final controller = _controllers[userId];
    final lastSaved = _lastSavedValues[userId] ?? '';

    // Skip if empty — revert to original
    if (trimmed.isEmpty) {
      controller?.text = lastSaved;
      return;
    }

    // If same as last saved, no action needed
    if (lastSaved == trimmed) return;

    final val = double.tryParse(trimmed);
    if (val == null) {
      // Invalid number — revert
      controller?.text = lastSaved;
      return;
    }

    // Validate max degree
    if (val > widget.gradeItem.maxDegree) {
      controller?.text = lastSaved;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Degree cannot exceed ${_fmt(widget.gradeItem.maxDegree)}',
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Validate negative
    if (val < 0) {
      controller?.text = lastSaved;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Degree cannot be negative'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    _lastSavedValues[userId] = trimmed;
    _gradeCubit.setStudentGrade(
      gradeItemId: widget.gradeItem.id,
      userId: userId,
      degree: val,
    );
  }

  String _fmt(double n) =>
      n == n.roundToDouble() ? n.toStringAsFixed(0) : n.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                'Max: ${_fmt(widget.gradeItem.maxDegree)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppConfig.primaryColor,
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<GradeCubit, GradeState>(
          builder: (context, state) {
            if (state.isGetGradesForItemLoading) {
              return const AppLoadingIndicator();
            }
            if (state.gradesForItem.isEmpty) {
              return const AppEmptyState(
                icon: Icons.people_outline,
                title: 'No Members',
                subtitle: 'No students enrolled in\nthis course yet',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: state.gradesForItem.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final grade = state.gradesForItem[index];

                // Create controller if needed
                final controller = _controllers.putIfAbsent(
                  grade.userId,
                  () {
                    final text = grade.hasGrade ? _fmt(grade.degree) : '';
                    if (text.isNotEmpty) {
                      _lastSavedValues[grade.userId] = text;
                    }
                    return TextEditingController(text: text);
                  },
                );

                // Create focus node if needed
                final focusNode = _focusNodes.putIfAbsent(
                  grade.userId,
                  () {
                    final node = FocusNode();
                    node.addListener(() {
                      if (!node.hasFocus) {
                        _onFocusLost(grade.userId);
                      }
                    });
                    return node;
                  },
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
                      _buildAvatar(grade.userName, grade.userAvatarUrl),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              grade.userName ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            if (!grade.hasGrade)
                              Text(
                                'Not graded',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Grade input — saves on unfocus only
                      SizedBox(
                        width: 72,
                        child: TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                          onFieldSubmitted: (value) =>
                              _saveGrade(grade.userId, value),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 10),
                            isDense: true,
                            hintText: '—',
                            hintStyle: TextStyle(
                              color: isDark
                                  ? Colors.grey[600]
                                  : Colors.grey[400],
                              fontWeight: FontWeight.w400,
                            ),
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
