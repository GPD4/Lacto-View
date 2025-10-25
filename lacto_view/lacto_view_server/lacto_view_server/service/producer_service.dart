import 'package:firedart/firedart.dart';
import '../model/producer_model.dart';

class ProducerService {
  final Firestore _firestore;

  ProducerService(this._firestore);

  Future<List<Producer>> searchByName(String name) async {
    final producerCollection = _firestore.collection('person');

    final String searchKey = name.toUpperCase();

    final query = producerCollection
        .where('role', isEqualTo: 'producer')
        .where('name_uppercase', isGreaterThanOrEqualTo: searchKey)
        .where('name_uppercase', isLessThan: searchKey + 'z')
        .orderBy('name_uppercase');

    final result = await query.get();

    final producerList = <Producer>[];
    for (final doc in result) {
      final data = doc.map;
      data['id'] = doc.id;
      producerList.add(Producer.fromJson(data));
    }

    return producerList;
  }
}
