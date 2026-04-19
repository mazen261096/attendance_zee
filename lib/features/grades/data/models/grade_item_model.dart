import '../../../../core/utils/enums.dart';

class GradeItemModel {
  final String id;
  final String courseId;
  final String name;
  final GradeItemType type;
  final double maxDegree;
  final String createdBy;
  final DateTime createdAt;

  GradeItemModel({
    required this.id,
    required this.courseId,
    required this.name,
    required this.type,
    required this.maxDegree,
    required this.createdBy,
    required this.createdAt,
  });

  factory GradeItemModel.fromJson(Map<String, dynamic> json) {
    return GradeItemModel(
      id: json['id'],
      courseId: json['course_id'],
      name: json['name'] ?? '',
      type: GradeItemType.fromString(json['type'] ?? 'exam'),
      maxDegree: (json['max_degree'] as num).toDouble(),
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  GradeItemModel copyWith({
    String? id,
    String? courseId,
    String? name,
    GradeItemType? type,
    double? maxDegree,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return GradeItemModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      name: name ?? this.name,
      type: type ?? this.type,
      maxDegree: maxDegree ?? this.maxDegree,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'course_id': courseId,
        'name': name,
        'type': type.name,
        'max_degree': maxDegree,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
      };
}
