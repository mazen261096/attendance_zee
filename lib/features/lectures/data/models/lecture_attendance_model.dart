import '../../../../core/utils/enums.dart';

class LectureAttendanceModel {
  final String id;
  final String lectureId;
  final String userId;
  final AttendanceStatus status;
  final DateTime checkedInAt;

  /// Optional: populated when fetching with profile join
  final String? userName;
  final String? userAvatarUrl;

  LectureAttendanceModel({
    required this.id,
    required this.lectureId,
    required this.userId,
    required this.status,
    required this.checkedInAt,
    this.userName,
    this.userAvatarUrl,
  });

  factory LectureAttendanceModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;

    return LectureAttendanceModel(
      id: json['id'],
      lectureId: json['lecture_id'],
      userId: json['user_id'],
      status: AttendanceStatus.fromString(json['status'] ?? 'absent'),
      checkedInAt: DateTime.parse(json['checked_in_at']),
      userName: profile?['name'],
      userAvatarUrl: profile?['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lecture_id': lectureId,
        'user_id': userId,
        'status': status.value,
        'checked_in_at': checkedInAt.toIso8601String(),
      };
}
