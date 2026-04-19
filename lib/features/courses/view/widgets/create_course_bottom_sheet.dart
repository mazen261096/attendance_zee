import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../view_model/course_cubit.dart';
import '../../view_model/course_state.dart';

class CreateCourseBottomSheet extends StatefulWidget {
  const CreateCourseBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<CourseCubit>(),
        child: const CreateCourseBottomSheet(),
      ),
    );
  }

  @override
  State<CreateCourseBottomSheet> createState() =>
      _CreateCourseBottomSheetState();
}

class _CreateCourseBottomSheetState extends State<CreateCourseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _codeController.dispose();
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
      child: BlocConsumer<CourseCubit, CourseState>(
        listener: (context, state) {
          if (state.isCreateCourseSuccess) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Course created successfully!'),
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
                  'Create Course',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add a new course for your students',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                // Name
                _buildLabel(theme, 'Course Name', isDark),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Data Structures',
                    prefixIcon: Icon(Icons.school_outlined, size: 20),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Course name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Code
                _buildLabel(theme, 'Course Code', isDark),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _codeController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'e.g. CS301',
                    prefixIcon: Icon(Icons.qr_code_rounded, size: 20),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Course code is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Description
                _buildLabel(theme, 'Description (Optional)', isDark),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  textInputAction: TextInputAction.done,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Brief description of the course...',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 48),
                      child: Icon(Icons.description_outlined, size: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Create Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.isCreateCourseLoading
                        ? null
                        : () => _submit(context),
                    child: state.isCreateCourseLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Create Course'),
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

  void _submit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<CourseCubit>().createCourse(
            name: _nameController.text.trim(),
            code: _codeController.text.trim().toUpperCase(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
          );
    }
  }
}
