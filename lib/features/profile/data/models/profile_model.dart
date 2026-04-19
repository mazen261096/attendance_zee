class ProfileModel {
  final String id;
  final String name;
  final String? avatarUrl;
  final DateTime createdAt;

  ProfileModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      name: json['name'] ?? '',
      avatarUrl: json['avatar_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  ProfileModel copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar_url': avatarUrl,
        'created_at': createdAt.toIso8601String(),
      };
}
