class StudentGradeModel {
  final String id;
  final String gradeItemId;
  final String userId;
  final double degree;
  final String createdBy;
  final DateTime createdAt;

  /// Optional: populated when fetching with profile join
  final String? userName;
  final String? userAvatarUrl;

  /// Optional: populated when fetching with grade_item join
  final String? gradeItemName;
  final double? maxDegree;

  StudentGradeModel({
    required this.id,
    required this.gradeItemId,
    required this.userId,
    required this.degree,
    required this.createdBy,
    required this.createdAt,
    this.userName,
    this.userAvatarUrl,
    this.gradeItemName,
    this.maxDegree,
  });

  factory StudentGradeModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    final gradeItem = json['grade_items'] as Map<String, dynamic>?;

    return StudentGradeModel(
      id: json['id'],
      gradeItemId: json['grade_item_id'],
      userId: json['user_id'],
      degree: (json['degree'] as num).toDouble(),
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      userName: profile?['name'],
      userAvatarUrl: profile?['avatar_url'],
      gradeItemName: gradeItem?['name'],
      maxDegree: gradeItem != null
          ? (gradeItem['max_degree'] as num?)?.toDouble()
          : null,
    );
  }

  /// Percentage score (0.0 - 100.0)
  double? get percentage =>
      maxDegree != null && maxDegree! > 0 ? (degree / maxDegree!) * 100 : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'grade_item_id': gradeItemId,
        'user_id': userId,
        'degree': degree,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
      };
}
