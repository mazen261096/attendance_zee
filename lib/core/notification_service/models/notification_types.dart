import 'package:flutter/material.dart';

/// 🔔 Notification Types — Attendance-Zee
///
/// Matches the DB enum: info, attendance, grade, join_request, lecture, course
enum NotificationType {
  info('info'),
  attendance('attendance'),
  grade('grade'),
  joinRequest('join_request'),
  lecture('lecture'),
  course('course');

  final String value;

  const NotificationType(this.value);

  static NotificationType? tryParse(String? value) {
    if (value == null) return null;
    try {
      return NotificationType.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }

  NotificationUI getUI(ThemeData theme) {
    switch (this) {
      case NotificationType.info:
        return NotificationUI(
          icon: Icons.info_outline_rounded,
          color: Colors.blue,
          title: 'Information',
        );
      case NotificationType.attendance:
        return NotificationUI(
          icon: Icons.check_circle_outline_rounded,
          color: Colors.green,
          title: 'Attendance',
        );
      case NotificationType.grade:
        return NotificationUI(
          icon: Icons.grade_rounded,
          color: Colors.amber,
          title: 'Grade Update',
        );
      case NotificationType.joinRequest:
        return NotificationUI(
          icon: Icons.person_add_alt_1_rounded,
          color: Colors.purple,
          title: 'Join Request',
        );
      case NotificationType.lecture:
        return NotificationUI(
          icon: Icons.school_rounded,
          color: theme.primaryColor,
          title: 'Lecture',
        );
      case NotificationType.course:
        return NotificationUI(
          icon: Icons.menu_book_rounded,
          color: Colors.teal,
          title: 'Course Update',
        );
    }
  }
}

class NotificationUI {
  final IconData icon;
  final Color color;
  final String title;

  const NotificationUI({
    required this.icon,
    required this.color,
    required this.title,
  });
}

class NotificationData {
  final NotificationType type;
  final Map<String, dynamic> data;

  const NotificationData(this.type, this.data);

  String? get courseId => data['course_id'] as String?;
  String? get lectureId => data['lecture_id'] as String?;
  String? get gradeItemId => data['grade_item_id'] as String?;
  String? get requestId => data['request_id'] as String?;
}
