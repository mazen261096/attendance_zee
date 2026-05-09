class ProfileModel {
  final String id;
  final String name;
  final String? avatarUrl;
  final DateTime createdAt;
  final String preferredTheme;
  final String preferredLanguage;

  ProfileModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.createdAt,
    this.preferredTheme = 'system',
    this.preferredLanguage = 'en',
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      name: json['name'] ?? '',
      avatarUrl: json['avatar_url'],
      createdAt: DateTime.parse(json['created_at']),
      preferredTheme: json['preferred_theme'] ?? 'system',
      preferredLanguage: json['preferred_language'] ?? 'en',
    );
  }

  ProfileModel copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    DateTime? createdAt,
    String? preferredTheme,
    String? preferredLanguage,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      preferredTheme: preferredTheme ?? this.preferredTheme,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar_url': avatarUrl,
        'created_at': createdAt.toIso8601String(),
        'preferred_theme': preferredTheme,
        'preferred_language': preferredLanguage,
      };
}
