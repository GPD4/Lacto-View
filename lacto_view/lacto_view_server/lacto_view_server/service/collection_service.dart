import 'package:dart_firebase_admin/firestore.dart';
import '../model/collection_model.dart';
import '../model/producer_model.dart';
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
  Future<List<Producer>> searchProducerByName(String name) async {
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

  //Future<MilkCollection> searchCollection(MilkCollection collection) - buscar coleta por: producer_name, collector_name, property_name
}
