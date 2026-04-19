import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/enums.dart';
import '../../data/models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isUnread = !notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppConfig.errorColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppConfig.errorColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUnread
                ? (isDark
                    ? AppConfig.primaryColor.withValues(alpha: 0.06)
                    : AppConfig.primaryColor.withValues(alpha: 0.03))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _typeColor(notification.type).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _typeIcon(notification.type),
                  color: _typeColor(notification.type),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight:
                                  isUnread ? FontWeight.w700 : FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppConfig.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    if (notification.body != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        notification.body!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      _timeAgo(notification.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _typeColor(NotificationType type) {
    switch (type) {
      case NotificationType.attendance:
        return AppConfig.successColor;
      case NotificationType.grade:
        return AppConfig.warningColor;
      case NotificationType.joinRequest:
        return AppConfig.accentColor;
      case NotificationType.lecture:
        return AppConfig.primaryColor;
      case NotificationType.course:
        return AppConfig.primaryLightColor;
      case NotificationType.info:
        return Colors.grey;
    }
  }

  IconData _typeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.attendance:
        return Icons.fact_check_rounded;
      case NotificationType.grade:
        return Icons.assessment_rounded;
      case NotificationType.joinRequest:
        return Icons.person_add_rounded;
      case NotificationType.lecture:
        return Icons.event_note_rounded;
      case NotificationType.course:
        return Icons.school_rounded;
      case NotificationType.info:
        return Icons.info_outline_rounded;
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
