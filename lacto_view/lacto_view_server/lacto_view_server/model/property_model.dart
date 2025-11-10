class Property {
  final String? id;
  final String name;
  final String cep;
  final String? street;
  final String city;
  final String state;
  final int tanksQtd;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Property({
    this.id,
    required this.name,
    required this.cep,
    required this.street,
    required this.city,
    required this.state,
    required this.tanksQtd,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Property.fromMap(Map<String, dynamic> map) {
    if (map['name'] == null || map['cep'] == null) {
      throw Exception('Campos essenciais (name, cep) estão faltando');
    }
    final now = DateTime.now();

    return Property(
      name: map['name'] as String,
      cep: map['cep'] as String,
      street: map['street'] as String,
      city: map['city'] as String,
      state: map['state'] as String,
      tanksQtd: map['tanks_qtd'] as int,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory Property.fromJson(String docId, Map<String, dynamic> json) {
    if (json['name'] == null || json['cep'] == null) {
      throw Exception('Campos essenciais (name, cep) estão faltando');
    }
    return Property(
      id: docId,
      name: json['name'] as String,
      cep: json['cep'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      tanksQtd: json['tanks_qtd'] as int,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['update_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cep': cep,
      'street': street,
      'city': city,
      'state': state,
      'tanks_qtd': tanksQtd,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Property copyWith({
    String? id,
    String? name,
    String? cep,
    String? street,
    String? city,
    String? state,
    int? tanksQtd,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Property(
      id: id ?? this.id,
      name: name ?? this.name,
      cep: cep ?? this.cep,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      tanksQtd: tanksQtd ?? this.tanksQtd,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
