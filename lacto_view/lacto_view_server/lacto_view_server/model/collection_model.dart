// /models/milk_collection.dart

class MilkCollection {
  final String? id; // Pode ser nulo antes de inserir no BD
  final String producerId;
  final String producerPropertyId;
  final String collectorId;
  final String? rejectionReason; // Usando nulos para campos opcionais
  final bool rejection;
  final double volumeLt;
  final double temperature;
  final bool producerPresent;
  final double? ph;
  final String numtanque;
  final bool sample;
  final String? tubeNumber;
  final String? observation;
  final String status;
  final int? analysisId; // Análise pode ser feita depois
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? syncedAt;

  MilkCollection({
    this.id,
    required this.producerId,
    required this.producerPropertyId,
    required this.collectorId,
    this.rejectionReason,
    required this.rejection,
    required this.volumeLt,
    required this.temperature,
    required this.producerPresent,
    this.ph,
    required this.numtanque,
    required this.sample,
    this.tubeNumber,
    this.observation,
    required this.status,
    this.analysisId,
    this.createdAt,
    this.updatedAt,
    this.syncedAt,
  });

  factory MilkCollection.fromJson(Map<String, dynamic> json) {
    // AQUI você faria a validação dos dados recebidos!
    // Ex: if ((json['volume_lt'] as num? ?? -1) < 0) throw Exception('Volume inválido');

    return MilkCollection(
      id: json['id'] as String?,
      producerId: json['producer_id'] as String,
      producerPropertyId: json['producer_property_id'] as String,
      rejectionReason: json['rejection_reason'] as String?,
      rejection: json['rejection'] as bool,
      volumeLt: (json['volume_lt'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      producerPresent: json['producer_present'] as bool,
      ph: (json['ph'] as num?)?.toDouble(),
      numtanque: json['numtanque'] as String,
      sample: json['sample'] as bool,
      tubeNumber: json['tube_number'] as String?,
      observation: json['observation'] as String?,
      status: json['status'] as String,
      collectorId: json['collector_id'] as String,
      analysisId: json['analysis_id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      syncedAt: json['synced_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'producer_id': producerId,
      'producer_property_id': producerPropertyId,
      'rejection_reason': rejectionReason,
      'rejection': rejection,
      'volume_lt': volumeLt,
      'temperature': temperature,
      'producer_present': producerPresent,
      'ph': ph,
      'numtanque': numtanque,
      'sample': sample,
      'tube_number': tubeNumber,
      'observation': observation,
      'status': status,
      'collector_id': collectorId,
      'analysis_id': analysisId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'synced_at': updatedAt?.toIso8601String(),
    };
  }

  MilkCollection copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? syncedAt,
  }) {
    return MilkCollection(
        id: id ?? this.id,
        producerId: this.producerId,
        producerPropertyId: this.producerPropertyId,
        collectorId: this.collectorId,
        rejection: this.rejection,
        volumeLt: this.volumeLt,
        temperature: this.temperature,
        producerPresent: this.producerPresent,
        numtanque: this.numtanque,
        sample: this.sample,
        status: this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncedAt: syncedAt ?? this.syncedAt);
  }
}
