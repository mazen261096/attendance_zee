import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_router.dart';
import '../routes/routes.dart';
import 'models/notification_types.dart';

export 'models/notification_types.dart';

class NotificationNavigation {
  static void navigate(BuildContext context, NotificationData data) {
    switch (data.type) {
      case NotificationType.attendance:
      case NotificationType.lecture:
        final courseId = data.courseId;
        final lectureId = data.lectureId;
        if (courseId != null && lectureId != null) {
          context.push(Routes.lectureDetailPath(courseId, lectureId));
        } else if (courseId != null) {
          context.push(Routes.courseDetailPath(courseId));
        }
        break;

      case NotificationType.grade:
      case NotificationType.course:
        final courseId = data.courseId;
        if (courseId != null) {
          context.push(Routes.courseDetailPath(courseId));
        }
        break;

      case NotificationType.joinRequest:
        final courseId = data.courseId;
        if (courseId != null) {
          context.push(Routes.courseDetailPath(courseId));
        }
        break;

      case NotificationType.info:
        // General info — just go to notifications
        context.push(Routes.notifications);
        break;
    }
  }

  static void handleFCMNotification(Map<String, dynamic> fcmData) {
    final context = AppRouter.navigatorKey.currentContext;
    if (context == null) return;

    final typeString = fcmData['type'] as String?;
    final type = NotificationType.tryParse(typeString);
    if (type == null) return;

    final data = NotificationData(type, fcmData);
    navigate(context, data);
  }
}
