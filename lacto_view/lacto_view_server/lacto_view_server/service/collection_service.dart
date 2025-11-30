import 'package:dart_firebase_admin/firestore.dart';
import '../model/collection_model.dart';
import '../service/producer_service.dart';

class CollectionService {
  final Firestore _firestore;
  final ProducerService _producerService;

  late final CollectionReference _collectionRef;

  CollectionService(this._firestore)
      : _producerService = ProducerService(_firestore) {
    _collectionRef = _firestore.collection('collection');
  }

  //busca de produtores pelo nome(metodo em producer_service.dart)
  Future<List<ProducerSearchResult>> searchProducerByName(String name) async {
    return await _producerService.searchByName(name);
  }

  //Cadastrar nova coleta
  Future<MilkCollection> addCollection(
      String uid, MilkCollection collection) async {
    final data = collection.toMap();
    final serverTime = DateTime.now();

    data['synced_at'] = serverTime.toIso8601String();
    data['created_at'] = serverTime.toIso8601String();
    data['updated_at'] = serverTime.toIso8601String();

    data['owner_uid'] = uid;

    final producer_name = data['producer_name'];

    if (producer_name is String) {
      data['producer_name'] = producer_name.toUpperCase();
    }

    final collector_name = data['collector_name'];

    if (collector_name is String) {
      data['collector_name'] = collector_name.toUpperCase();
    }

    final property_name = data['property_name'];

    if (property_name is String) {
      data['property_name'] = property_name.toUpperCase();
    }

    data.remove('id');

    try {
      //.add para criar o documento com ID automático na coleção 'collection'
      final docRef = await _collectionRef.add(data);

      return collection.copyWith(
        id: docRef.id,
        createdAt: serverTime,
        updatedAt: serverTime,
        syncedAt: serverTime,
      );
    } catch (e) {
      print("Erro ao adicionar coleta no DB(FireStore): $e");
      throw Exception('Falha ao registrar coleta');
    }
  }

  //Busca pelo nome do Produtor

  Future<List<MilkCollection>> searchProducer(
    String search, {
    int limit = 5,
  }) async {
    print('---DEBUG: Iniciando busca de Coletas ---');
    print('--- Termo da busca recebido: "$search"');

    final collectionCollection = _firestore.collection('collection');

    final String key = search.toUpperCase();

    print('--- Chave normalizada para busca: $key');

    final producerNameQuery = await collectionCollection
        .where('producer_name_uppercase', WhereFilter.greaterThanOrEqual, key)
        .where('producer_name_uppercase', WhereFilter.lessThan, key + 'Z')
        .limit(limit)
        .get();

    print(
        '--- Resultados encontrados (producer_name): ${producerNameQuery.docs.length}');

    final map = <String, MilkCollection>{};

    for (final doc in producerNameQuery.docs) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      map[doc.id] = MilkCollection.fromJson(data);
    }

    final total = map.values.toList().length;

    print('--- Total de resultados únicos combinados: $total');
    print('--- Fim da busca ---');

    return map.values.toList();
  }

//Busca por Nome do Colector

  Future<List<MilkCollection>> searchCollector(
    String search, {
    int limit = 5,
  }) async {
    final collectionCollection = _firestore.collection('collection');

    final String key = search.toUpperCase();

    final collectorNameQuery = await collectionCollection
        .where('collector_name_uppercase', WhereFilter.greaterThanOrEqual, key)
        .where('collector_name_uppercase', WhereFilter.lessThan, key + 'Z')
        .limit(limit)
        .get();

    print(
        '--- Resultados encontrados (collector_name): ${collectorNameQuery.docs.length}');

    final map = <String, MilkCollection>{};

    for (final doc in collectorNameQuery.docs) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      map[doc.id] = MilkCollection.fromJson(data);
    }

    final total = map.values.toList().length;

    print('--- Total de resultados únicos combinados: $total');
    print('--- Fim da busca ---');

    return map.values.toList();
  }

// Busca por Nome da Propriedade

  Future<List<MilkCollection>> searchProperty(
    String search, {
    int limit = 5,
  }) async {
    final collectionCollection = _firestore.collection('collection');

    final String key = search.toUpperCase();

    final propertyNameQuery = await collectionCollection
        .where('property_name_uppercase', WhereFilter.greaterThanOrEqual, key)
        .where('property_name_uppercase', WhereFilter.lessThan, key + 'Z')
        .limit(limit)
        .get();

    print(
        '--- Resultados encontrados (property_name): ${propertyNameQuery.docs.length}');

    final map = <String, MilkCollection>{};

    for (final doc in propertyNameQuery.docs) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      map[doc.id] = MilkCollection.fromJson(data);
    }

    final total = map.values.toList().length;

    print('--- Total de resultados únicos combinados: $total');
    print('--- Fim da busca ---');

    return map.values.toList();
  }

  Future<List<MilkCollection>> findAll({
    int limit = 20,
    DateTime? startAfter,
  }) async {
    print('--- DEBUG: Iniciando findAll com paginação ---');

    Query query =
        _collectionRef.orderBy('created_at', descending: true).limit(limit);

    if (startAfter != null) {
      print('--- Paginando a partir de: $startAfter ---');

      query = query.startAfter([startAfter]);
    }

    final querySnapshot = await query.get();

    print(
        '--- Items encontrados nesta pagina: ${querySnapshot.docs.length} ---');

    final collections = <MilkCollection>[];

    for (final doc in querySnapshot.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      data['id'] = doc.id;

      try {
        collections.add(MilkCollection.fromJson(data));
      } catch (e) {
        print("Erro ao deserializar coleta ${doc.id}: $e");
      }
    }
    print('--- Debug: Fim do findAll() ---');
    return collections;
  }

  /// Método unificado de busca de coletas
  /// 
  /// [type]: 'producer' | 'collector' | 'property' | 'id'
  /// [searchTerm]: termo de busca
  /// [startDate]: data inicial do filtro
  /// [endDate]: data final do filtro
  /// [producerId]: ID do produtor para filtrar apenas suas coletas
  /// [limit]: número máximo de resultados
  Future<List<MilkCollection>> searchCollections({
    required String type,
    String searchTerm = '',
    DateTime? startDate,
    DateTime? endDate,
    String? producerId,
    int limit = 20,
  }) async {
    print('--- DEBUG: Iniciando busca unificada de coletas ---');
    print('--- Tipo: $type, Termo: "$searchTerm"');

    final collectionCollection = _firestore.collection('collection');
    List<MilkCollection> results = [];

    // Se tem termo de busca, faz busca por tipo
    if (searchTerm.isNotEmpty) {
      final String key = searchTerm.toUpperCase();
      
      QuerySnapshot querySnapshot;
      
      switch (type) {
        case 'producer':
          querySnapshot = await collectionCollection
              .where('producer_name', WhereFilter.greaterThanOrEqual, key)
              .where('producer_name', WhereFilter.lessThan, key + '\uf8ff')
              .limit(limit)
              .get();
          break;
        case 'collector':
          querySnapshot = await collectionCollection
              .where('collector_name', WhereFilter.greaterThanOrEqual, key)
              .where('collector_name', WhereFilter.lessThan, key + '\uf8ff')
              .limit(limit)
              .get();
          break;
        case 'collectionNumber':
        case 'id':
          // Busca por ID específico
          final doc = await collectionCollection.doc(searchTerm).get();
          if (doc.exists) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            results.add(MilkCollection.fromJson(data));
          }
          return results;
        default:
          querySnapshot = await collectionCollection
              .orderBy('created_at', descending: true)
              .limit(limit)
              .get();
      }

      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        
        try {
          final collection = MilkCollection.fromJson(data);
          
          // Aplica filtros adicionais em memória
          bool incluir = true;
          
          // Filtro por produtor
          if (producerId != null && collection.producerId != producerId) {
            incluir = false;
          }
          
          // Filtro por data (só aplica se createdAt não for null)
          final createdAt = collection.createdAt;
          if (createdAt != null) {
            if (startDate != null && createdAt.isBefore(startDate)) {
              incluir = false;
            }
            if (endDate != null) {
              final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
              if (createdAt.isAfter(endOfDay)) {
                incluir = false;
              }
            }
          }
          
          if (incluir) {
            results.add(collection);
          }
        } catch (e) {
          print("Erro ao deserializar coleta ${doc.id}: $e");
        }
      }
    } else {
      // Sem termo de busca - busca todas com filtros
      Query query = collectionCollection.orderBy('created_at', descending: true);
      
      // Filtro por produtor (se especificado)
      if (producerId != null && producerId.isNotEmpty) {
        query = query.where('producer_id', WhereFilter.equal, producerId);
      }
      
      // Filtro por data inicial
      if (startDate != null) {
        query = query.where('created_at', WhereFilter.greaterThanOrEqual, startDate.toIso8601String());
      }
      
      // Filtro por data final
      if (endDate != null) {
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        query = query.where('created_at', WhereFilter.lessThanOrEqual, endOfDay.toIso8601String());
      }
      
      query = query.limit(limit);
      
      final querySnapshot = await query.get();
      
      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        
        try {
          results.add(MilkCollection.fromJson(data));
        } catch (e) {
          print("Erro ao deserializar coleta ${doc.id}: $e");
        }
      }
    }

    print('--- Total de resultados: ${results.length} ---');
    return results;
  }
}
