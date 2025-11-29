class Property {
  final String? id;
  final String name;
  final String cep;
  final String? street;
  final String city;
  final String state;
  final int tanksQtd;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Property({
    this.id,
    required this.name,
    required this.cep,
    required this.street,
    required this.city,
    required this.state,
    required this.tanksQtd,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      name: json['name'],
      cep: json['cep'],
      street: json['street'],
      city: json['city'],
      state: json['state'],
      tanksQtd: json['tanks_qtd'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'cep': cep,
      'street': street,
      'city': city,
      'state': state,
      'tanks_qtd': tanksQtd,
      'is_active': isActive,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cep': cep,
      'street': street,
      'city': city,
      'state': state,
      'tanks_qtd': tanksQtd,
      'is_active': isActive,
    };
  }
}
