class MilkCollection {
  final String? id;
  final String? producerId;
  final String producerName;
  final String? producerPropertyId;
  final String propertyName;
  final String collectorId;
  final String collectorName;
  final String rejectionReason; // Pode ser vazio, nunca null no modelo
  final bool rejection;
  final double volumeLt;
  final double temperature;
  final bool producerPresent;
  final double ph;
  final String numtanque;
  final bool sample;
  final String tubeNumber; // Pode ser vazio
  final String observation; // Pode ser vazio
  final String status;
  final int? analysisId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? syncedAt;

  MilkCollection({
    this.id,
    required this.producerId,
    required this.producerName,
    required this.producerPropertyId,
    required this.propertyName,
    required this.rejectionReason,
    required this.rejection,
    required this.volumeLt,
    required this.temperature,
    required this.producerPresent,
    required this.ph,
    required this.numtanque,
    required this.sample,
    required this.tubeNumber,
    required this.observation,
    required this.status,
    required this.collectorId,
    required this.collectorName,
    this.analysisId,
    required this.createdAt,
    this.updatedAt,
    this.syncedAt,
  });

  // Factory para criar a instância a partir de um JSON
  factory MilkCollection.fromJson(Map<String, dynamic> json) {
    return MilkCollection(
      id: json['id'] as String?,
      producerId: json['producer_id'] as String?,
      producerName: json['producer_name'] as String? ?? '',
      producerPropertyId: json['producer_property_id'] as String?,
      propertyName: json['property_name'] as String? ?? '',
      // Trata null como string vazia
      rejectionReason: json['rejection_reason'] as String? ?? '',
      rejection: json['rejection'] as bool? ?? false,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      volumeLt: (json['volume_lt'] as num?)?.toDouble() ?? 0.0,
      producerPresent: json['producer_present'] as bool? ?? false,
      ph: (json['ph'] as num?)?.toDouble() ?? 0.0,
      numtanque: json['numtanque'] as String? ?? '',
      sample: json['sample'] as bool? ?? false,
      tubeNumber: json['tube_number'] as String? ?? '',
      observation: json['observation'] as String? ?? '',
      status: json['status'] as String? ?? 'pendente',
      collectorId: json['collector_id'] as String? ?? '',
      collectorName: json['collector_name'] as String? ?? '',
      analysisId: json['analysis_id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      syncedAt: json['synced_at'] != null
          ? DateTime.parse(json['synced_at'] as String)
          : null,
    );
  }

  // Método para converter a instância para um JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'producer_id': producerId,
      'producer_property_id': producerPropertyId,
      'producer_name': producerName,
      'property_name': propertyName,
      'rejection_reason': rejectionReason,
      'rejection': rejection,
      'temperature': temperature,
      'volume_lt': volumeLt,
      'producer_present': producerPresent,
      'ph': ph,
      'numtanque': numtanque,
      'sample': sample,
      'tube_number': tubeNumber,
      'observation': observation,
      'status': status,
      'collector_id': collectorId,
      'collector_name': collectorName,
      'analysis_id': analysisId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }
}
