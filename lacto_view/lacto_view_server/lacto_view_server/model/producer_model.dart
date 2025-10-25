import '../model/person_model.dart';

class Producer {
  final String cadpro;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Producer({
    required this.cadpro,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Producer.fromJson(Map<String, dynamic> json) {
    return Producer(
      cadpro: json['cadpro'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
