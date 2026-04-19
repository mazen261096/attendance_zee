class UserModel {
  final String id;
  final String? email;
  final String? name;
  final String? avatarUrl;
  final DateTime createdAt;

  UserModel({
    required this.id,
    this.email,
    this.name,
    this.avatarUrl,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      avatarUrl: json['avatar_url'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'avatar_url': avatarUrl,
        'created_at': createdAt.toIso8601String(),
      };
}
