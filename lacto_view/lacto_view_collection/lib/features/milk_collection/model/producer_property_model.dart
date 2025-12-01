/// Enum para definir o tipo de busca
enum SearchMode { property, producer }

/// Modelo que representa uma propriedade ou produtor para seleção na coleta
class ProducerProperty {
  final String? propertyId;
  final String? propertyName;
  final String? city;
  final String? state;
  final int tanksQtd;
  final String? producerId;
  final String? producerName;
  final String? producerPhone;
  final String? producerEmail;

  ProducerProperty({
    this.propertyId,
    this.propertyName,
    this.city,
    this.state,
    this.tanksQtd = 1,
    this.producerId,
    this.producerName,
    this.producerPhone,
    this.producerEmail,
  });

  /// Factory para criar a partir de resposta de busca por propriedade
  factory ProducerProperty.fromPropertyJson(Map<String, dynamic> json) {
    return ProducerProperty(
      propertyId: json['id'] as String? ?? '',
      propertyName: json['name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      tanksQtd: json['tanks_qtd'] as int? ?? 1,
      producerId: json['producer_id'] as String?,
      producerName: json['producer_name'] as String?,
    );
  }

  /// Factory para criar a partir de resposta de busca por produtor
  factory ProducerProperty.fromProducerJson(Map<String, dynamic> json) {
    return ProducerProperty(
      propertyId: json['property_id'] as String?,
      propertyName: json['property_name'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      tanksQtd: json['tanks_qtd'] as int? ?? 1,
      producerId: json['person_id'] as String? ?? '',
      producerName: json['name'] as String? ?? '',
      producerPhone: json['phone'] as String?,
      producerEmail: json['email'] as String?,
    );
  }

  /// Retorna a localização formatada (cidade - estado)
  String get location {
    if (city != null && state != null && city!.isNotEmpty && state!.isNotEmpty) {
      return '$city - $state';
    }
    return city ?? state ?? '';
  }

  /// Retorna o nome para exibição (produtor ou propriedade)
  String get displayName => producerName ?? propertyName ?? 'Sem nome';

  /// Retorna o subtítulo para exibição
  String get displaySubtitle {
    if (propertyName != null && propertyName!.isNotEmpty) {
      return propertyName!;
    }
    return location;
  }

  /// Retorna lista de tanques disponíveis baseado na quantidade
  List<String> get availableTanks => 
    List.generate(tanksQtd, (i) => '${i + 1}');

  /// Verifica se tem propriedade vinculada
  bool get hasProperty => propertyId != null && propertyId!.isNotEmpty;
}
