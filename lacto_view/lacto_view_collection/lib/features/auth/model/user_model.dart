enum UserRole { admin, producer, collector, user }

class UserAuth {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? profileImg;
  final String token;

  UserAuth({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImg,
    required this.token,
  });

  // Function para converter String do banco em enum, 'role'.
  static UserRole _stringToRole(String? roleString) {
    switch (roleString) {
      case 'admin':
        return UserRole.admin;
      case 'producer':
        return UserRole.producer;
      case 'collector':
        return UserRole.collector;
      default:
        return UserRole.user;
    }
  }

  factory UserAuth.fromMap(Map<String, dynamic> map) {
    return UserAuth(
      id: map['id'] as String? ?? '',
      name: map['name'] ?? 'Sem Nome', // Recebendo o nome do Back
      email: map['email'] as String,
      role: _stringToRole(map['role'] as String?), // Converte String para Enum
      profileImg: map['profile_img'] as String?,
      token: map['token'] ?? '',
    );
  }

  factory UserAuth.fromJson(Map<String, dynamic> json) {
    return UserAuth(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: _stringToRole(json['role'] as String?),
      profileImg: json['profile_img'] as String?,
      token: json['token'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'profile_img': profileImg,
      'token': token,
    };
  }
}
