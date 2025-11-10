import 'package:dart_firebase_admin/auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:dart_firebase_admin/firestore.dart';
import 'package:test/test.dart';
import '../model/person_model.dart';
import '../model/producer_model.dart';

class PersonService {
  final Auth _auth;
  final Firestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _personRef;
  late final CollectionReference<Map<String, dynamic>> _userRef;
  late final CollectionReference<Map<String, dynamic>> _producerRef;
  late final CollectionReference<Map<String, dynamic>> _collectorRef;

  PersonService(this._firestore, this._auth) {
    _personRef = _firestore.collection('person');
    _userRef = _firestore.collection('user');
    _producerRef = _firestore.collection('producer');
    _collectorRef = _firestore.collection('collector');
  }

  Future<Person> createPerson(
      Person person, String password, String? cadpro) async {
    final loginKeys = [person.cpfCnpj, person.email, person.phone];

    final existingUser = await _userRef
        .where('login_keys', WhereFilter.arrayContainsAny, loginKeys)
        .limit(1)
        .get();

    if (existingUser.docs.isNotEmpty) {
      throw Exception('CPF, Email ou Telefone já estão em uso');
    }

// Trata o campo Cadpro
    if (person.role == 'producer' && (cadpro == null || cadpro.isEmpty)) {
      throw Exception('Role = "producer", mas o "cadpro" está ausente');
    }

    //criptografar a senha(hashing)
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    final hashedPassword = hash.toString();

    try {
      final newPersonRef = _personRef.doc();
      final newPersonId = newPersonRef.id;

      //O 'user' usará o mesmo ID
      final newUserRef = _userRef.doc(newPersonId);

      //Prepara os dados do 'Person'
      final personData = person.toMap();
      final now = DateTime.now().toIso8601String();
      personData['created_at'] = now;
      personData['updated_at'] = now;
      personData.remove('id');

      //Prepara os dados do 'User'
      final userData = {
        'person_id': newPersonId,
        'login_keys': loginKeys,
        'password': hashedPassword, //Salva a HASH, não a senha crua
      };

      await _firestore.runTransaction((transaction) async {
        //Cria o Person
        transaction.set(newPersonRef, personData);
        //Cria o User
        transaction.set(newUserRef, userData);
        //Cria o Producer
        if (person.role == 'producer' && cadpro != null) {
          final newProducerRef = _producerRef.doc(newPersonId);

          final producerData = {
            'person_id': newPersonId,
            'cadpro': cadpro,
            'created_at': now,
            'updated_at': now,
          };
          transaction.set(newProducerRef, producerData);
        }
      });

      return person.copyWith(
        id: newPersonId,
        createdAt: DateTime.parse(now),
        updatedAt: DateTime.parse(now),
      );
    } catch (e) {
      print("Erro ao criar usuario: $e");
      rethrow;
    }
  }

  //Future<Person> editPerson(String uid, Person person) async {}

  //Future<Person> deletePerson(String uid, Person person) async {}

  //Future<Person> searchByNameOrCpfCnpj(String uid, Person person) async {}

  //Future<Person> filterByRole(String uid, Person person) async {}
}
