import 'package:flutter/material.dart';
import '../models/notification_types.dart';

/// Configuration for notification UI elements
class NotificationUIConfig {
  final IconData icon;
  final Color Function(ThemeData theme) getColor;
  final String defaultTitle;
  final String defaultBody;

  const NotificationUIConfig({
    required this.icon,
    required this.getColor,
    required this.defaultTitle,
    required this.defaultBody,
  });
}

/// Factory for creating notification UI components for Attendance-Zee
class NotificationUIFactory {
  NotificationUIFactory._();

  static NotificationUIConfig getConfig(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return _infoConfig;
      case NotificationType.attendance:
        return _attendanceConfig;
      case NotificationType.grade:
        return _gradeConfig;
      case NotificationType.joinRequest:
        return _joinRequestConfig;
      case NotificationType.lecture:
        return _lectureConfig;
      case NotificationType.course:
        return _courseConfig;
    }
  }

  static NotificationUIConfig getConfigFromString(String? typeString) {
    final type = NotificationType.tryParse(typeString);
    if (type == null) return _defaultConfig;
    return getConfig(type);
  }

  static final _infoConfig = NotificationUIConfig(
    icon: Icons.info_outline_rounded,
    getColor: (theme) => Colors.blue,
    defaultTitle: 'Information',
    defaultBody: 'You have a new notification',
  );

  static final _attendanceConfig = NotificationUIConfig(
    icon: Icons.check_circle_outline_rounded,
    getColor: (theme) => Colors.green,
    defaultTitle: 'Attendance',
    defaultBody: 'Attendance has been recorded',
  );

  static final _gradeConfig = NotificationUIConfig(
    icon: Icons.grade_rounded,
    getColor: (theme) => Colors.amber,
    defaultTitle: 'Grade Update',
    defaultBody: 'A new grade has been posted',
  );

  static final _joinRequestConfig = NotificationUIConfig(
    icon: Icons.person_add_alt_1_rounded,
    getColor: (theme) => Colors.purple,
    defaultTitle: 'Join Request',
    defaultBody: 'Someone wants to join your course',
  );

  static final _lectureConfig = NotificationUIConfig(
    icon: Icons.school_rounded,
    getColor: (theme) => theme.primaryColor,
    defaultTitle: 'Lecture',
    defaultBody: 'A new lecture has been scheduled',
  );

  static final _courseConfig = NotificationUIConfig(
    icon: Icons.menu_book_rounded,
    getColor: (theme) => Colors.teal,
    defaultTitle: 'Course Update',
    defaultBody: 'There is an update in your course',
  );

  static final _defaultConfig = NotificationUIConfig(
    icon: Icons.notifications,
    getColor: (theme) => theme.iconTheme.color ?? Colors.grey,
    defaultTitle: 'Notification',
    defaultBody: 'You have a new notification',
  );

  static IconData getIcon(NotificationType type) => getConfig(type).icon;
  static Color getColor(NotificationType type, ThemeData theme) =>
      getConfig(type).getColor(theme);
  static IconData getIconFromString(String? typeString) =>
      getConfigFromString(typeString).icon;
  static Color getColorFromString(String? typeString, ThemeData theme) =>
      getConfigFromString(typeString).getColor(theme);
}
