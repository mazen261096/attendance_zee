import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../data/models/lecture_model.dart';

class LectureCard extends StatelessWidget {
  final LectureModel lecture;
  final VoidCallback onTap;

  const LectureCard({
    super.key,
    required this.lecture,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final status = lecture.lectureStatus;

    final statusColor = switch (status) {
      LectureStatus.upcoming => AppConfig.primaryColor,
      LectureStatus.active => AppConfig.successColor,
      LectureStatus.ended => Colors.grey,
    };

    final statusLabel = switch (status) {
      LectureStatus.upcoming => 'Upcoming',
      LectureStatus.active => 'Active',
      LectureStatus.ended => 'Ended',
    };

    final statusIcon = switch (status) {
      LectureStatus.upcoming => Icons.schedule_rounded,
      LectureStatus.active => Icons.radio_button_checked_rounded,
      LectureStatus.ended => Icons.event_available_rounded,
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: status == LectureStatus.active
                ? AppConfig.successColor.withValues(alpha: 0.3)
                : isDark
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
        child: Row(
          children: [
            // Status indicator icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                statusIcon,
                color: statusColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lecture.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _StatusChip(label: statusLabel, color: statusColor),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(lecture.startTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
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

  String _formatDateTime(DateTime dt) {
    // Convert to device local timezone for display
    final local = dt.toLocal();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = local.hour > 12 ? local.hour - 12 : local.hour;
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    final min = local.minute.toString().padLeft(2, '0');
    return '${months[local.month - 1]} ${local.day}, ${local.year} • $h:$min $ampm';
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
