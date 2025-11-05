import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_firebase_admin/firestore.dart';
import '../model/person_model.dart';

class PersonService {
  final Auth _auth;
  final Firestore _firestore;
  late final CollectionReference _personRef;

  PersonService(this._firestore, this._auth) {
    _personRef = _firestore.collection('person');
  }

  Future<Person> createPerson(String uid, Person person) async {
    final data = person.toMap();
    final serverTime = DateTime.now();

    data['created_at'] = serverTime.toIso8601String();
    data['updated_at'] = serverTime.toIso8601String();

    data.remove('id');

    try {
      await _personRef.doc(uid).set(data);

      return person.copyWith(
        id: uid,
        createdAt: serverTime,
        updatedAt: serverTime,
      );
    } catch (e) {
      print("Erro ao adicionar Person no DB(FireStore):");
      rethrow;
    }
  }
}
