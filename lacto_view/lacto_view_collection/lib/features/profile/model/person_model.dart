class Person {
  final String? id;
  final String name;
  final String cpfCnpj;
  final String? cadpro;
  final String? email;
  final String telefone;
  final String password;
  final String role;
  final String profileImg;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Person({
    this.id,
    required this.name,
    required this.cpfCnpj,
    required this.cadpro,
    required this.email,
    required this.telefone,
    required this.password,
    required this.role,
    required this.profileImg,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      name: json['name'],
      cpfCnpj: json['cpf_cnpj'],
      cadpro: json['cadpro'],
      email: json['email'],
      telefone: json['telefone'],
      password: json['password'],
      role: json['role'],
      profileImg: json['profile_img'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cpf_cnpj': cpfCnpj,
      'cadpro': cadpro,
      'email': email,
      'telefone': telefone,
      'password': password,
      'role': role,
      'profile_img': profileImg,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
