class MilkCollection {
  final String? id;
  final String? producerId;
  final String producerName;
  final String? producerPropertyId;
  final String propertyName;
  final String collectorId;
  final String collectorName;
  final String rejectionReason;
  final bool rejection;
  final double volumeLt;
  final double temperature;
  final bool producerPresent;
  final double ph;
  final String numtanque;
  final bool sample;
  final String tubeNumber;
  final String observation;
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
    required this.analysisId,
    required this.createdAt,
    this.updatedAt,
    this.syncedAt,
  });

  // Factory para criar a instância a partir de um JSON
  factory MilkCollection.fromJson(Map<String, dynamic> json) {
    return MilkCollection(
      id: json['id'],
      producerId: json['producer_id'],
      producerName: json['producer_name'],
      producerPropertyId: json['producer_property_id'],
      propertyName: json['property_name'],
      rejectionReason: json['rejection_reason'],
      rejection: json['rejection'],
      temperature: (json['temperature'] as num).toDouble(),
      volumeLt: (json['volume_lt'] as num).toDouble(),
      producerPresent: json['producer_present'],
      ph: (json['ph'] as num).toDouble(),
      numtanque: json['numtanque'],
      sample: json['sample'],
      tubeNumber: json['tube_number'],
      observation: json['observation'],
      status: json['status'],
      collectorId: json['collector_id'],
      collectorName: json['collector_name'], // ADICIONADO
      analysisId: json['analysis_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      syncedAt: json['synced_at'] != null
          ? DateTime.parse(json['synced_at'])
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
      'collector_name': collectorName, // ADICIONADO
      'analysis_id': analysisId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }
}
