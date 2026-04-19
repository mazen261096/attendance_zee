import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/widgets/role_badge.dart';
import '../../data/models/course_model.dart';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  final MemberRole role;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.role,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.grey.shade200,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Course icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppConfig.primaryColor.withValues(alpha: 0.15),
                    AppConfig.primaryLightColor.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: AppConfig.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            // Course info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          course.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      RoleBadge(role: role, small: true),
                    ],
                  ),
                  if (course.description != null &&
                      course.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      course.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Code: ${course.code}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        letterSpacing: 0.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
