class Person {
  final String? id;
  final String name;
  final String cpfCnpj;
  final String? cadpro;
  final String? email;
  final String phone;
  final String? password;
  final String role;
  final String? propertyId;
  final String? profileImg;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Person({
    this.id,
    required this.name,
    required this.cpfCnpj,
    this.cadpro,
    required this.email,
    required this.phone,
    this.password,
    required this.role,
    this.propertyId,
    this.profileImg,
    this.isActive = true,
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
      phone: json['phone'],
      password: json['password'],
      role: json['role'],
      propertyId: json['property_id'],
      profileImg: json['profile_img'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'cpf_cnpj': cpfCnpj,
      'cadpro': cadpro,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
      'property_id': propertyId,
      'profile_img': profileImg,
      'is_active': isActive,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cpf_cnpj': cpfCnpj,
      'cadpro': cadpro,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
      'property_id': propertyId,
      'profile_img': profileImg,
      'is_active': isActive,
    };
  }
}
