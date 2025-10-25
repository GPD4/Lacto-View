import 'package:firedart/firedart.dart';
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
  Future<MilkCollection> addCollection(MilkCollection collection) async {
    final data = collection.toMap();
    data.remove('id');

    final serverTime = DateTime.now();
    data['synced_at'] = serverTime.toIso8601String();

    try {
      //.add para criar o documento com ID automático na coleção 'collection'
      final document = await _collectionRef.add(data);

      return collection.copyWith(
        id: document.id,
        syncedAt: serverTime,
      );
    } catch (e) {
      print("Erro ao adicionar coleta no DB(FireStore): $e");
      throw Exception('Falha ao registrar coleta');
    }
  }
}
