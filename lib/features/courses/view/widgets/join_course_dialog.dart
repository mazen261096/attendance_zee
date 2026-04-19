import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../view_model/course_cubit.dart';
import '../../view_model/course_state.dart';

class JoinCourseDialog extends StatefulWidget {
  const JoinCourseDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CourseCubit>(),
        child: const JoinCourseDialog(),
      ),
    );
  }

  @override
  State<JoinCourseDialog> createState() => _JoinCourseDialogState();
}

class _JoinCourseDialogState extends State<JoinCourseDialog> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<CourseCubit, CourseState>(
      listener: (context, state) {
        if (state.isJoinCourseSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Join request sent successfully!'),
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
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppConfig.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.qr_code_rounded,
                  color: AppConfig.accentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Join Course',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter the course code provided by your instructor.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'COURSE CODE',
                  hintStyle: TextStyle(
                    fontFamily: 'monospace',
                    letterSpacing: 2,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
                onFieldSubmitted: (_) => _submit(context),
              ),
              if (state.joinCourseError.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  state.joinCourseError,
                  style: const TextStyle(
                    color: AppConfig.errorColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed:
                  state.isJoinCourseLoading ? null : () => _submit(context),
              child: state.isJoinCourseLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Join'),
            ),
          ],
        );
      },
    );
  }

  void _submit(BuildContext context) {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    // Correct method name is joinCourseByCode
    context.read<CourseCubit>().joinCourseByCode(code: code);
  }
}
