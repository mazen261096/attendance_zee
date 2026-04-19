enum LectureStatus { upcoming, active, ended }

class LectureModel {
  final String id;
  final String courseId;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAttendanceOpen;
  final String createdBy;
  final DateTime createdAt;

  LectureModel({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.isAttendanceOpen,
    required this.createdBy,
    required this.createdAt,
  });

  factory LectureModel.fromJson(Map<String, dynamic> json) {
    return LectureModel(
      id: json['id'],
      courseId: json['course_id'],
      title: json['title'] ?? '',
      description: json['description'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      isAttendanceOpen: json['is_attendance_open'] as bool? ?? false,
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// Time-based lecture status — independent of attendance toggle.
  /// Compares in UTC to work correctly across all timezones.
  LectureStatus get lectureStatus {
    final now = DateTime.now().toUtc();
    final start = startTime.toUtc();
    final end = endTime.toUtc();
    if (now.isBefore(start)) return LectureStatus.upcoming;
    if (now.isAfter(end)) return LectureStatus.ended;
    return LectureStatus.active;
  }

  LectureModel copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAttendanceOpen,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return LectureModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAttendanceOpen: isAttendanceOpen ?? this.isAttendanceOpen,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'course_id': courseId,
        'title': title,
        'description': description,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'is_attendance_open': isAttendanceOpen,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
      };
}
