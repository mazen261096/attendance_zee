import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/utils/enums.dart';
import '../../view_model/grade_cubit.dart';
import '../../view_model/grade_state.dart';

class CreateGradeItemSheet extends StatefulWidget {
  final String courseId;

  const CreateGradeItemSheet({super.key, required this.courseId});

  static Future<void> show(BuildContext context, String courseId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<GradeCubit>(),
        child: CreateGradeItemSheet(courseId: courseId),
      ),
    );
  }

  @override
  State<CreateGradeItemSheet> createState() => _CreateGradeItemSheetState();
}

class _CreateGradeItemSheetState extends State<CreateGradeItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _maxDegreeController = TextEditingController(text: '100');
  GradeItemType _selectedType = GradeItemType.exam;

  @override
  void dispose() {
    _nameController.dispose();
    _maxDegreeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottomInset),
      child: BlocConsumer<GradeCubit, GradeState>(
        listener: (context, state) {
          if (state.isCreateGradeItemSuccess) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Grade item created!'),
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
          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Create Grade Item',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 24),
                // Name
                _buildLabel(theme, 'Item Name', isDark),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Midterm Exam',
                    prefixIcon: Icon(Icons.edit_outlined, size: 20),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Type
                _buildLabel(theme, 'Type', isDark),
                const SizedBox(height: 8),
                SegmentedButton<GradeItemType>(
                  segments: GradeItemType.values
                      .map((t) => ButtonSegment(
                            value: t,
                            label: Text(
                              t.name[0].toUpperCase() + t.name.substring(1),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ))
                      .toList(),
                  selected: {_selectedType},
                  onSelectionChanged: (s) {
                    setState(() => _selectedType = s.first);
                  },
                  style: SegmentedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),
                // Max Degree
                _buildLabel(theme, 'Max Degree', isDark),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _maxDegreeController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: '100',
                    prefixIcon: Icon(Icons.grade_outlined, size: 20),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Max degree is required';
                    }
                    final num = double.tryParse(val);
                    if (num == null || num <= 0) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                // Create
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.isCreateGradeItemLoading
                        ? null
                        : _submit,
                    child: state.isCreateGradeItemLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Create Grade Item'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(ThemeData theme, String text, bool isDark) {
    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.grey[300] : Colors.grey[700],
        letterSpacing: 0.5,
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<GradeCubit>().createGradeItem(
            courseId: widget.courseId,
            name: _nameController.text.trim(),
            type: _selectedType.name,
            maxDegree: double.parse(_maxDegreeController.text),
          );
    }
  }
}
