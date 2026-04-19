import '../../../../core/utils/enums.dart';

class JoinRequestModel {
  final String id;
  final String courseId;
  final String userId;
  final JoinRequestStatus status;
  final DateTime createdAt;

  /// Optional: populated when fetching with profile join
  final String? userName;
  final String? userAvatarUrl;

  JoinRequestModel({
    required this.id,
    required this.courseId,
    required this.userId,
    required this.status,
    required this.createdAt,
    this.userName,
    this.userAvatarUrl,
  });

  factory JoinRequestModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;

    return JoinRequestModel(
      id: json['id'],
      courseId: json['course_id'],
      userId: json['user_id'],
      status: JoinRequestStatus.fromString(json['status'] ?? 'pending'),
      createdAt: DateTime.parse(json['created_at']),
      userName: profile?['name'],
      userAvatarUrl: profile?['avatar_url'],
    );
  }

  bool get isPending => status == JoinRequestStatus.pending;
  bool get isApproved => status == JoinRequestStatus.approved;

  Map<String, dynamic> toJson() => {
        'id': id,
        'course_id': courseId,
        'user_id': userId,
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
      };
}
