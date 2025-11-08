class MilkCollection {
  final int id;
  final int producerId;
  final String producerName;
  final int producerPropertyId;
  final String propertyName;
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
  final int collectorId;
  final int analysisId;
  final DateTime createdAt;
  final DateTime updatedAt;

  MilkCollection({
    required this.id,
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
    required this.analysisId,
    required this.createdAt,
    required this.updatedAt,
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
      ph: (json['ph'] as num).toDouble(), // CORRIGIDO: Type safety
      numtanque: json['numtanque'],
      sample: json['sample'],
      tubeNumber: json['tube_number'],
      observation: json['observation'],
      status: json['status'],
      collectorId: json['collector_id'],
      analysisId: json['analysis_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Método para converter a instância para um JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'producer_id': producerId,
      'producer_property_id': producerPropertyId,
      'producer_name': producerName, // CORRIGIDO: Padronizado
      'property_name': propertyName, // CORRIGIDO: Padronizado
      'rejection_reason': rejectionReason,
      'rejection': rejection,
      'temperature': temperature,
      'volume_lt': volumeLt,
      'producer_present': producerPresent,
      'ph': ph,
      'numtanque': numtanque, // CORRIGIDO: Adicionado campo
      'observation': observation,
      'sample': sample,
      'tube_number': tubeNumber,
      'status': status,
      'collector_id': collectorId,
      'analysis_id': analysisId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
