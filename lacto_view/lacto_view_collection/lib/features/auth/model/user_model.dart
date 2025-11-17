class UserAuth {
  final String id;
  final String name;
  final String email;
  final String role;
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

  factory UserAuth.fromJson(Map<String, dynamic> json) {
    return UserAuth(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      profileImg: json['profile_img'],
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'profile_img': profileImg,
      'token': token,
    };
  }
}
