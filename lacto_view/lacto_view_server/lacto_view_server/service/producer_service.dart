import 'package:dart_firebase_admin/firestore.dart';
import '../model/producer_model.dart';

class ProducerService {
  final Firestore _firestore;
  late final CollectionReference _producerRef;

  ProducerService(this._firestore) {
    _producerRef = _firestore.collection('producer');
  }

  Future<List<Producer>> searchByName(String name) async {
    final producerCollection = _firestore.collection('person');

    final String searchKey = name.toUpperCase();

    final query = producerCollection
        .where('role', WhereFilter.equal, 'producer')
        .where('name_uppercase', WhereFilter.greaterThanOrEqual, searchKey)
        .where('name_uppercase', WhereFilter.lessThan, searchKey + 'z')
        .orderBy('name_uppercase');

    final result = await query.get();

    final producerList = <Producer>[];
    for (final doc in result.docs) {
      final data = doc.data();
      producerList.add(Producer.fromJson(data));
    }

    return producerList;
  }
}
