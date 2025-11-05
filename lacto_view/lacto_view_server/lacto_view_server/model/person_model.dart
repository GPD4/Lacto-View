class Person {
  final String? id;
  final String name;
  final String cpfCnpj;
  final String role;
  final String profileImg;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Person({
    this.id,
    required this.name,
    required this.cpfCnpj,
    required this.role,
    required this.profileImg,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Person.fromMap(Map<String, dynamic> map) {
    if (map['name'] == null || map['cpf_cnpj'] == null || map['role'] == null) {
      throw Exception(
          'Campos essenciais (name, cpf_cnpj, role) estão faltando.');
    }

    final now = DateTime.now();

    return Person(
      name: map['name'] as String,
      cpfCnpj: map['cpf_cnpj'] as String,
      role: map['role'] as String,
      profileImg: map['profile_img'] as String? ?? '',
      isActive: map['is_active'] as bool? ?? true,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory Person.fromJson(String docId, Map<String, dynamic> json) {
    //Validaçao dos dados recebidos
    if (json['name'] == null ||
        json['cpf_cnpj'] == null ||
        json['role'] == null) {
      throw Exception(
          'Campos essenciais (name, cpf_cnpj, role) estão faltando.');
    }
    return Person(
      id: docId,
      name: json['name'] as String,
      cpfCnpj: json['cpf_cnpj'] as String,
      role: json['role'] as String,
      profileImg: json['profile_img'] as String,
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cpf_cnpj': cpfCnpj,
      'role': role,
      'profile_img': profileImg,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Person copyWith({
    String? id,
    String? name,
    String? cpfCnpj,
    String? role,
    String? profileImg,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      cpfCnpj: cpfCnpj ?? this.cpfCnpj,
      role: role ?? this.role,
      profileImg: profileImg ?? this.profileImg,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
