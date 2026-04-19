class CourseModel {
  final String id;
  final String name;
  final String? description;
  final String code;
  final String ownerId;
  final DateTime createdAt;

  CourseModel({
    required this.id,
    required this.name,
    this.description,
    required this.code,
    required this.ownerId,
    required this.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      code: json['code'] ?? '',
      ownerId: json['owner_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  CourseModel copyWith({
    String? id,
    String? name,
    String? description,
    String? code,
    String? ownerId,
    DateTime? createdAt,
  }) {
    return CourseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      code: code ?? this.code,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'code': code,
        'owner_id': ownerId,
        'created_at': createdAt.toIso8601String(),
      };
}
