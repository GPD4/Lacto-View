import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_firebase_admin/firestore.dart';
import '../model/property_model.dart';

class PropertyService {
  final Auth _auth;
  final Firestore _firestore;
  late final CollectionReference _propertyRef;

  PropertyService(this._firestore, this._auth) {
    _propertyRef = _firestore.collection('property');
  }

  Future<Property> createProperty(String uid, Property property) async {
    final data = property.toMap();
    final serverTime = DateTime.now();

    data['created_at'] = serverTime.toIso8601String();
    data['updated_at'] = serverTime.toIso8601String();

    data.remove('id');

    try {
      await _propertyRef.doc(uid).set(data);

      return property.copyWith(
        id: uid,
        createdAt: serverTime,
        updatedAt: serverTime,
      );
    } catch (e) {
      print("Erro ao adicionar Property no DB(Firestore):");
      rethrow;
    }
  }

  Future<List<Property>> searchByNameOrCity(String search) async {
    final propertyCollection = _firestore.collection('property');

    final String key = search.toUpperCase();

//  Busca por nome da propriedade
    final nameQuery = await propertyCollection
        .where('name_uppercase', WhereFilter.greaterThanOrEqual, key)
        .where('name_uppercase', WhereFilter.lessThan, key + 'Z')
        .get();

//  Busca por Cidade da propriedade

    final cityQuery = await propertyCollection
        .where('city_uppercase', WhereFilter.greaterThanOrEqual, key)
        .where('city_uppercase', WhereFilter.lessThan, key + 'Z')
        .get();

    final map = <String, Property>{};

    for (final doc in nameQuery.docs) {
      map[doc.id] = Property.fromJson(doc.id, doc.data());
    }

    for (final doc in cityQuery.docs) {
      map[doc.id] = Property.fromJson(doc.id, doc.data());
    }

    return map.values.toList();
  }
}
