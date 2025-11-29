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

    data['owner_uid'] = uid;

    final name = data['name'];

    if (name is String) {
      data['name_uppercase'] = name.toUpperCase();
    }

    final city = data['city'];

    if (city is String) {
      data['city_uppercase'] = city.toUpperCase();
    }

    data.remove('id');

    try {
      final docRef = await _propertyRef.add(data);

      return property.copyWith(
        id: docRef.id,
        createdAt: serverTime,
        updatedAt: serverTime,
      );
    } catch (e) {
      print("Erro ao adicionar Property no DB(Firestore):");
      rethrow;
    }
  }

  Future<List<Property>> searchByNameOrCity(
    String search, {
    int limit = 5, //Limite de objetos da consulta. ***OTIMIZAÇÃO***
  }) async {
    print('--- DEBUG: Iniciando a busca de Propriedades ---');
    print('--- Termo de busca recebido: "$search"');

    final propertyCollection = _firestore.collection('property');

    final String key = search.toUpperCase();

    print('--- Chave normalizada para busca: "$key"');

//Busca por nome
    final nameQuery = await propertyCollection
        .where('name_uppercase', WhereFilter.greaterThanOrEqual, key)
        .where('name_uppercase', WhereFilter.lessThan, key + 'Z')
        .limit(limit) //Limita o resultado da Query em 5 objetos
        .get();

    print('--- Resultados encontrados (NOME): ${nameQuery.docs.length}');

//Busca por Cidade

    final cityQuery = await propertyCollection
        .where('city_uppercase', WhereFilter.greaterThanOrEqual, key)
        .where('city_uppercase', WhereFilter.lessThan, key + 'Z')
        .limit(limit) //Limita o resultado da Query em 5 objetos
        .get();

    print('--- Resultados encontrados (CIDADE): ${cityQuery.docs.length}');

    final map = <String, Property>{};

    for (final doc in nameQuery.docs) {
      map[doc.id] = Property.fromJson(doc.id, doc.data());
    }

    for (final doc in cityQuery.docs) {
      map[doc.id] = Property.fromJson(doc.id, doc.data());
    }

    final combinedList = map.values.toList();
    final total = map.values.toList().length;

    print('--- Total de resultados únicos combinados: $total');
    print('--- Fim da busca ---');

    return combinedList.take(limit).toList();
  }
}
