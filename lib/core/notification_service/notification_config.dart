import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_router.dart';
import '../routes/app_shell.dart';
import '../routes/routes.dart';
import 'models/notification_types.dart';

export 'models/notification_types.dart';

class NotificationNavigation {
  static void navigate(BuildContext context, NotificationData data) {
    // Grade received → stay on notifications tab (user is already there)
    if (data.type == NotificationType.gradeReceived) return;

    final path = _getRoutePath(data);
    if (path != null) {
      if (kDebugMode) {
        print('NotificationNavigation: navigating to $path');
      }
      context.push(path);
    }
  }

  static String? _getRoutePath(NotificationData data) {
    switch (data.type) {
      case NotificationType.joinApproved:
        final courseId = data.courseId;
        if (courseId != null) return Routes.courseDetailPath(courseId);
        return null;

      case NotificationType.newJoinRequest:
        final courseId = data.courseId;
        if (courseId != null) return Routes.courseMembersPath(courseId);
        return null;

      case NotificationType.newCourseFile:
        final courseId = data.courseId;
        if (courseId != null) return Routes.courseFilesPath(courseId);
        return null;

      case NotificationType.attendanceOpen:
      case NotificationType.attendanceClosed:
      case NotificationType.newLectureFile:
        final courseId = data.courseId;
        final lectureId = data.lectureId;
        if (courseId != null && lectureId != null) {
          return Routes.lectureDetailPath(courseId, lectureId);
        } else if (courseId != null) {
          return Routes.courseDetailPath(courseId);
        }
        return null;

      case NotificationType.newGradeItem:
        final courseId = data.courseId;
        if (courseId != null) return Routes.courseGradesPath(courseId);
        return null;

      case NotificationType.gradeReceived:
        final courseId = data.courseId;
        final gradeItemId = data.gradeItemId;
        if (courseId != null && gradeItemId != null) {
          return Routes.gradeItemDetailPath(courseId, gradeItemId);
        } else if (courseId != null) {
          return Routes.courseGradesPath(courseId);
        }
        return null;
    }
  }

  /// Navigate from an FCM notification tap (data comes as Map<String, dynamic>)
  static void handleFCMNotification(Map<String, dynamic> fcmData) {
    if (kDebugMode) {
      print('handleFCMNotification called with: $fcmData');
    }

    final typeString = fcmData['type'] as String?;
    final type = NotificationType.tryParse(typeString);
    if (type == null) {
      if (kDebugMode) {
        print('handleFCMNotification: unknown type "$typeString", ignoring');
      }
      return;
    }

    // Grade received → go to notifications tab on home
    if (type == NotificationType.gradeReceived) {
      AppShell.pendingTabSwitch.value = 2; // notifications tab
      try {
        AppRouter.router.go(Routes.home);
        if (kDebugMode) {
          print('handleFCMNotification: switched to notifications tab ✓');
        }
      } catch (e) {
        if (kDebugMode) {
          print('handleFCMNotification: go failed: $e');
        }
      }
      return;
    }

    final data = NotificationData(type, fcmData);
    final path = _getRoutePath(data);
    if (path == null) {
      if (kDebugMode) {
        print('handleFCMNotification: no route path for $type');
      }
      return;
    }

    // Use GoRouter directly — more reliable than context.push
    try {
      AppRouter.router.push(path);
      if (kDebugMode) {
        print('handleFCMNotification: pushed $path ✓');
      }
    } catch (e) {
      if (kDebugMode) {
        print('handleFCMNotification: push failed: $e');
      }
    }
  }
}

