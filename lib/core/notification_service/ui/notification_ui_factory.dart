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
      case NotificationType.joinApproved:
        return _joinApprovedConfig;
      case NotificationType.newJoinRequest:
        return _newJoinRequestConfig;
      case NotificationType.attendanceOpen:
        return _attendanceOpenConfig;
      case NotificationType.attendanceClosed:
        return _attendanceClosedConfig;
      case NotificationType.newGradeItem:
        return _newGradeItemConfig;
      case NotificationType.gradeReceived:
        return _gradeReceivedConfig;
      case NotificationType.newCourseFile:
        return _newCourseFileConfig;
      case NotificationType.newLectureFile:
        return _newLectureFileConfig;
    }
  }

  static NotificationUIConfig getConfigFromString(String? typeString) {
    final type = NotificationType.tryParse(typeString);
    if (type == null) return _defaultConfig;
    return getConfig(type);
  }

  static final _joinApprovedConfig = NotificationUIConfig(
    icon: Icons.person_add_alt_1_rounded,
    getColor: (_) => const Color(0xFF8B5CF6),
    defaultTitle: 'Join Approved',
    defaultBody: 'You have been accepted into the course',
  );

  static final _newJoinRequestConfig = NotificationUIConfig(
    icon: Icons.person_add_rounded,
    getColor: (_) => const Color(0xFFF97316),
    defaultTitle: 'New Join Request',
    defaultBody: 'A student wants to join your course',
  );

  static final _attendanceOpenConfig = NotificationUIConfig(
    icon: Icons.fact_check_rounded,
    getColor: (_) => const Color(0xFF10B981),
    defaultTitle: 'Attendance Open',
    defaultBody: 'Attendance is now open',
  );

  static final _attendanceClosedConfig = NotificationUIConfig(
    icon: Icons.lock_clock_rounded,
    getColor: (_) => const Color(0xFFEF4444),
    defaultTitle: 'Attendance Closed',
    defaultBody: 'Attendance has been closed',
  );

  static final _newGradeItemConfig = NotificationUIConfig(
    icon: Icons.assignment_rounded,
    getColor: (_) => const Color(0xFFF59E0B),
    defaultTitle: 'New Grade Item',
    defaultBody: 'A new exam or assignment has been added',
  );

  static final _gradeReceivedConfig = NotificationUIConfig(
    icon: Icons.assessment_rounded,
    getColor: (_) => const Color(0xFF06B6D4),
    defaultTitle: 'Grade Received',
    defaultBody: 'Your grade has been posted',
  );

  static final _newCourseFileConfig = NotificationUIConfig(
    icon: Icons.attach_file_rounded,
    getColor: (_) => const Color(0xFF4F46E5),
    defaultTitle: 'New Course File',
    defaultBody: 'A new file has been uploaded to the course',
  );

  static final _newLectureFileConfig = NotificationUIConfig(
    icon: Icons.attach_file_rounded,
    getColor: (_) => const Color(0xFF0EA5E9),
    defaultTitle: 'New Lecture File',
    defaultBody: 'A new file has been uploaded to the lecture',
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
