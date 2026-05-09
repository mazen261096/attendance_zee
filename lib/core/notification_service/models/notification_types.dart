import 'package:flutter/material.dart';
import '../../utils/enums.dart';

// Re-export NotificationType from enums.dart so everything uses the same type
export '../../utils/enums.dart' show NotificationType;

/// Data payload from a notification (for navigation)
class NotificationData {
  final NotificationType type;
  final Map<String, dynamic> data;

  const NotificationData(this.type, this.data);

  String? get courseId => data['course_id'] as String?;
  String? get lectureId => data['lecture_id'] as String?;
  String? get gradeItemId => data['grade_item_id'] as String?;
  String? get fileId => data['file_id'] as String?;
}

/// UI representation for a notification type
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

extension NotificationTypeUI on NotificationType {
  NotificationUI getUI(ThemeData theme) {
    switch (this) {
      case NotificationType.joinApproved:
        return const NotificationUI(
          icon: Icons.person_add_alt_1_rounded,
          color: Color(0xFF8B5CF6),
          title: 'Join Approved',
        );
      case NotificationType.newJoinRequest:
        return const NotificationUI(
          icon: Icons.person_add_rounded,
          color: Color(0xFFF97316),
          title: 'New Join Request',
        );
      case NotificationType.attendanceOpen:
        return const NotificationUI(
          icon: Icons.fact_check_rounded,
          color: Color(0xFF10B981),
          title: 'Attendance Open',
        );
      case NotificationType.attendanceClosed:
        return const NotificationUI(
          icon: Icons.lock_clock_rounded,
          color: Color(0xFFEF4444),
          title: 'Attendance Closed',
        );
      case NotificationType.newGradeItem:
        return const NotificationUI(
          icon: Icons.assignment_rounded,
          color: Color(0xFFF59E0B),
          title: 'New Exam',
        );
      case NotificationType.gradeReceived:
        return const NotificationUI(
          icon: Icons.assessment_rounded,
          color: Color(0xFF06B6D4),
          title: 'Grade Posted',
        );
      case NotificationType.newCourseFile:
        return const NotificationUI(
          icon: Icons.attach_file_rounded,
          color: Color(0xFF4F46E5),
          title: 'New File',
        );
      case NotificationType.newLectureFile:
        return const NotificationUI(
          icon: Icons.attach_file_rounded,
          color: Color(0xFF0EA5E9),
          title: 'New File',
        );
    }
  }
}
