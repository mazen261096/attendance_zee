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

enum NotificationType {
  info,
  attendance,
  grade,
  joinRequest,
  lecture,
  course;

  String get value {
    switch (this) {
      case NotificationType.joinRequest:
        return 'join_request';
      default:
        return name;
    }
  }

  static NotificationType fromString(String value) {
    if (value == 'join_request') return NotificationType.joinRequest;
    return NotificationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationType.info,
    );
  }
}
