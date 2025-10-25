import 'package:firedart/firedart.dart';
import '../model/person_model.dart';

class PersonService {
  final Firestore _firestore;

  PersonService(this._firestore);

  Future<List<Person>> findPersons({String? role}) async {
    // 1. Lógica de Acesso aos Dados (que antes estava no Repository)
    final collection = _firestore.collection('person');
    late QueryReference query;
    if (role != null && role.isNotEmpty) {
      if (!['producer', 'collector', 'admin'].contains(role)) {
        throw Exception('Role inválida!'); // 2. Lógica de Negócio (Validação)
      }
      query = collection.where('role', isEqualTo: role);
    }

    final result = await query.get();

    final personList = <Person>[];
    for (final doc in result) {
      final data = doc.map..['id'] = doc.id;
      personList.add(Person.fromJson(doc.id, doc.map));
    }
    return personList;
  }
}
