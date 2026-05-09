enum RequestState { initial, loading, loaded, error }

enum MemberRole {
  admin,
  student;

  static MemberRole fromString(String value) {
    return MemberRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MemberRole.student,
    );
  }
}

enum JoinRequestStatus {
  pending,
  approved,
  rejected;

  static JoinRequestStatus fromString(String value) {
    return JoinRequestStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => JoinRequestStatus.pending,
    );
  }
}

enum AttendanceStatus {
  present,
  absent,
  late_;

  String get value {
    if (this == AttendanceStatus.late_) return 'late';
    return name;
  }

  static AttendanceStatus fromString(String value) {
    if (value == 'late') return AttendanceStatus.late_;
    return AttendanceStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AttendanceStatus.absent,
    );
  }
}

enum GradeItemType {
  exam,
  quiz,
  assignment,
  attendance;

  static GradeItemType fromString(String value) {
    return GradeItemType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => GradeItemType.exam,
    );
  }
}

/// Matches the DB enum: join_approved, attendance_open, attendance_closed,
/// new_grade_item, grade_received, new_course_file, new_lecture_file, new_join_request
enum NotificationType {
  joinApproved('join_approved'),
  newJoinRequest('new_join_request'),
  attendanceOpen('attendance_open'),
  attendanceClosed('attendance_closed'),
  newGradeItem('new_grade_item'),
  gradeReceived('grade_received'),
  newCourseFile('new_course_file'),
  newLectureFile('new_lecture_file');

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

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationType.joinApproved,
    );
  }
}
