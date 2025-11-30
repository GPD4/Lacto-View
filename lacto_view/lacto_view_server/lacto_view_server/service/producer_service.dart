import 'package:dart_firebase_admin/firestore.dart';
import '../model/person_model.dart';

/// Resultado da busca de produtores com dados da propriedade
class ProducerSearchResult {
  final String personId;
  final String name;
  final String? email;
  final String phone;
  final String? propertyId;
  final String? propertyName;
  final String? city;
  final String? state;
  final int tanksQtd;

  ProducerSearchResult({
    required this.personId,
    required this.name,
    this.email,
    required this.phone,
    this.propertyId,
    this.propertyName,
    this.city,
    this.state,
    this.tanksQtd = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'person_id': personId,
      'name': name,
      'email': email,
      'phone': phone,
      'property_id': propertyId,
      'property_name': propertyName,
      'city': city,
      'state': state,
      'tanks_qtd': tanksQtd,
    };
  }
}

class ProducerService {
  final Firestore _firestore;

  ProducerService(this._firestore);

  /// Busca produtores por nome e retorna com dados da propriedade vinculada
  Future<List<ProducerSearchResult>> searchByName(String name, {int limit = 5}) async {
    if (name.isEmpty) return [];

    print('--- DEBUG ProducerService: Buscando produtores com nome "$name"');

    final personCollection = _firestore.collection('person');
    final String searchKey = name.toUpperCase();

    // Busca por name_uppercase primeiro (sem índice composto)
    // e filtra por role em memória
    final query = personCollection
        .where('name_uppercase', WhereFilter.greaterThanOrEqual, searchKey)
        .where('name_uppercase', WhereFilter.lessThan, searchKey + 'Z')
        .limit(limit * 3); // Busca mais para compensar o filtro

    final result = await query.get();
    
    // Filtra apenas produtores
    final producerDocs = result.docs.where((doc) {
      final data = doc.data();
      return data['role'] == 'producer';
    }).take(limit).toList();

    print('--- DEBUG: Encontrados ${producerDocs.length} produtores (de ${result.docs.length} pessoas)');

    final producers = <ProducerSearchResult>[];

    for (final doc in producerDocs) {
      final data = doc.data();
      final personId = doc.id;

      // Busca a propriedade vinculada ao produtor (subcoleção producer_property)
      String? propertyId;
      String? propertyName;
      String? city;
      String? state;
      int tanksQtd = 1;

      try {
        final producerPropertyRef = personCollection
            .doc(personId)
            .collection('producer_property');
        
        final propertyLinks = await producerPropertyRef.limit(1).get();
        
        if (propertyLinks.docs.isNotEmpty) {
          final linkData = propertyLinks.docs.first.data();
          propertyId = linkData['property_id'] as String?;

          // Se tem property_id, busca os dados da propriedade
          if (propertyId != null) {
            final propertyDoc = await _firestore
                .collection('property')
                .doc(propertyId)
                .get();

            if (propertyDoc.exists) {
              final propData = propertyDoc.data();
              propertyName = propData?['name'] as String?;
              city = propData?['city'] as String?;
              state = propData?['state'] as String?;
              tanksQtd = propData?['tanks_qtd'] as int? ?? 1;
            }
          }
        }
      } catch (e) {
        print('--- DEBUG: Erro ao buscar propriedade do produtor $personId: $e');
      }

      producers.add(ProducerSearchResult(
        personId: personId,
        name: data['name'] as String? ?? '',
        email: data['email'] as String?,
        phone: data['phone'] as String? ?? '',
        propertyId: propertyId,
        propertyName: propertyName,
        city: city,
        state: state,
        tanksQtd: tanksQtd,
      ));
    }

    print('--- DEBUG: Retornando ${producers.length} produtores com propriedades');
    return producers;
  }
}
