import '../../../../core/utils/enums.dart';

class CourseMemberModel {
  final String id;
  final String courseId;
  final String userId;
  final MemberRole role;
  final DateTime joinedAt;

  /// Optional: populated when fetching with profile join
  final String? userName;
  final String? userAvatarUrl;

  CourseMemberModel({
    required this.id,
    required this.courseId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.userName,
    this.userAvatarUrl,
  });

  factory CourseMemberModel.fromJson(Map<String, dynamic> json) {
    // Handle nested profile data from joins
    final profile = json['profiles'] as Map<String, dynamic>?;

    return CourseMemberModel(
      id: json['id'],
      courseId: json['course_id'],
      userId: json['user_id'],
      role: MemberRole.fromString(json['role'] ?? 'student'),
      joinedAt: DateTime.parse(json['joined_at']),
      userName: profile?['name'],
      userAvatarUrl: profile?['avatar_url'],
    );
  }

  bool get isAdmin => role == MemberRole.admin;

  Map<String, dynamic> toJson() => {
        'id': id,
        'course_id': courseId,
        'user_id': userId,
        'role': role.name,
        'joined_at': joinedAt.toIso8601String(),
      };
}
