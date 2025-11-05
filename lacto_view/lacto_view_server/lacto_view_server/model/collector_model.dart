import '../model/person_model.dart';

class Collector {
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Collector({
    required this.createdAt,
    required this.updatedAt,
  });

  factory Collector.fromJson(Map<String, dynamic> json) {
    return Collector(
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
