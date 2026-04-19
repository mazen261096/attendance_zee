import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/enums.dart';

class GradeCard extends StatelessWidget {
  final String name;
  final GradeItemType type;
  final double? degree;
  final double maxDegree;
  final VoidCallback? onTap;

  const GradeCard({
    super.key,
    required this.name,
    required this.type,
    this.degree,
    required this.maxDegree,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _typeColor(type);
    final percentage =
        (degree != null && maxDegree > 0) ? (degree! / maxDegree) : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.grey.shade200,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(_typeIcon(type), color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      _TypeChip(type: type, color: color),
                    ],
                  ),
                ),
                if (degree != null) ...[
                  Text(
                    '${degree!.toStringAsFixed(degree! == degree!.roundToDouble() ? 0 : 1)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  Text(
                    ' / ${maxDegree.toStringAsFixed(maxDegree == maxDegree.roundToDouble() ? 0 : 1)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                  ),
                ] else
                  Text(
                    'Max: ${maxDegree.toStringAsFixed(maxDegree == maxDegree.roundToDouble() ? 0 : 1)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
              ],
            ),
            if (percentage != null) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${(percentage * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Color _typeColor(GradeItemType type) {
    switch (type) {
      case GradeItemType.exam:
        return AppConfig.primaryColor;
      case GradeItemType.quiz:
        return AppConfig.accentColor;
      case GradeItemType.assignment:
        return AppConfig.warningColor;
      case GradeItemType.attendance:
        return AppConfig.successColor;
    }
  }

  static IconData _typeIcon(GradeItemType type) {
    switch (type) {
      case GradeItemType.exam:
        return Icons.description_rounded;
      case GradeItemType.quiz:
        return Icons.quiz_rounded;
      case GradeItemType.assignment:
        return Icons.assignment_rounded;
      case GradeItemType.attendance:
        return Icons.fact_check_rounded;
    }
  }
}

class _TypeChip extends StatelessWidget {
  final GradeItemType type;
  final Color color;

  const _TypeChip({required this.type, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.name[0].toUpperCase() + type.name.substring(1),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
