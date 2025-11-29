class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? profileImg;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImg,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      role: map['role'] as String,
      profileImg: map['profile_img'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'profile_img': profileImg,
    };
  }
}
