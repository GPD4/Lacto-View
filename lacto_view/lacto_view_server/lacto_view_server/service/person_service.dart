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
  late final CollectionReference<Map<String, dynamic>> _producerPropertyRef;

  PersonService(this._firestore, this._auth) {
    _personRef = _firestore.collection('person');
    _userRef = _firestore.collection('user');
    _producerRef = _firestore.collection('producer');
    _collectorRef = _firestore.collection('collector');
    _producerPropertyRef = _firestore.collection('producer_property');
  }

  Future<Person> createPerson(
    Person person,
    String password,
    String? cadpro,
    String? propertyId,
  ) async {
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

    if (person.role == 'producer' &&
        (propertyId == null || propertyId.isEmpty)) {
      throw Exception('Role = "producer", mas o "propertyId" está ausente');
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
        'password': hashedPassword, //Salva a HASH
      };

      await _firestore.runTransaction((transaction) async {
        //Cria o Person
        transaction.set(newPersonRef, personData);
        //Cria o User
        transaction.set(newUserRef, userData);
        //Cria o Producer
        if (person.role == 'producer' && cadpro != null) {
          print('>>> DEBUG: Bloco Producer está executando.');
          final newProducerRef = _producerRef.doc(newPersonId);

          final producerData = {
            'person_id': newPersonId,
            'cadpro': cadpro,
            'created_at': now,
            'updated_at': now,
          };
          transaction.set(newProducerRef, producerData);
        }

        //Vinculo de Producer e Property = producer_property

        if (propertyId != null) {
          print('>>> DEBUG: Bloco producer_property está executando.');
          print(
              '>>> DEBUG: Linkando Person $newPersonId com Property $propertyId');
          //Cria ID composto "person_id + property_id = producer_property_id"
          final linkId = '${newPersonId}_$propertyId';
          final newLinkRef = _producerPropertyRef.doc(linkId);

          final linkData = {
            'person_id': newPersonId,
            'property_id': propertyId,
            'created_at': now,
            'updated_at': now,
          };
          transaction.set(newLinkRef, linkData);
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

  //Future<Person> getAll(String uid, Person person) async {}

  //Future<Person> searchByNameOrCpfCnpj(String uid, Person person) async {}

  //Future<Person> searchByPropertyName(String uid, Person person) async {}

  //Future<Person> filterByRole(String uid, Person person) async {}

  //Future<Person> editPerson(String uid, Person person) async {}

  //Future<Person> deletePerson(String uid, Person person) async {}
}
