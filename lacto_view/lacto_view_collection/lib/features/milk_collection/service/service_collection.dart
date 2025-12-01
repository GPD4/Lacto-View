import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/model_collection.dart';
import '../model/producer_property_model.dart';

class MilkCollectionService {
  final String _baseUrl = 'http://localhost:8080';

  /// Cria uma nova coleta no backend
  Future<MilkCollection> createCollection(
    String token,
    MilkCollection collection,
  ) async {
    print('SALVANDO NOVA COLETA NO BACKEND...');
    print('Dados: ${collection.toJson()}');

    try {
      final uri = Uri.parse('$_baseUrl/collection');

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(collection.toJson()),
      );

      print('DEBUG MilkCollectionService: Status ${response.statusCode}');
      print('DEBUG MilkCollectionService: Body ${response.body}');

      if (response.statusCode == 201) {
        print('Coleta Salva com SUCESSO!');
        final data = json.decode(response.body) as Map<String, dynamic>;
        return MilkCollection.fromJson(data);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(
          errorBody['error'] ?? 'Erro ao criar coleta: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Erro no MilkCollectionService.createCollection: $e');
      rethrow;
    }
  }

  /// Busca todas as coletas do backend
  Future<List<MilkCollection>> getMilkCollections(String token) async {
    try {
      final uri = Uri.parse('$_baseUrl/collection');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('DEBUG MilkCollectionService.getMilkCollections: Status ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);

        if (decoded is List) {
          final collections = <MilkCollection>[];
          for (final item in decoded) {
            try {
              collections.add(MilkCollection.fromJson(item as Map<String, dynamic>));
            } catch (e) {
              print('DEBUG: Erro ao parsear coleta: $e');
              print('DEBUG: Item problemático: $item');
            }
          }
          return collections;
        } else {
          print('DEBUG: Resposta não é uma lista: $decoded');
          return [];
        }
      } else {
        throw Exception('Erro ao buscar coletas: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no MilkCollectionService.getMilkCollections: $e');
      rethrow;
    }
  }

  /// Deleta uma coleta do backend
  Future<void> deleteCollection(String token, String id) async {
    print('DELETANDO COLETA COM ID: $id NO BACKEND...');

    try {
      final uri = Uri.parse('$_baseUrl/collection/$id');

      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('COLETA DELETADA COM SUCESSO!');
      } else {
        throw Exception('Erro ao deletar coleta: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no MilkCollectionService.deleteCollection: $e');
      rethrow;
    }
  }

  /// Busca propriedades por nome ou cidade no backend
  Future<List<ProducerProperty>> searchProperties(String query) async {
    if (query.isEmpty) {
      return [];
    }

    print('SERVICE: Buscando propriedades com a query: "$query"');

    try {
      final uri = Uri.parse('$_baseUrl/property/search').replace(
        queryParameters: {'q': query},
      );

      print('DEBUG MilkCollectionService.searchProperties: GET $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('DEBUG MilkCollectionService.searchProperties: Status ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);

        if (decoded is List) {
          final properties = <ProducerProperty>[];
          for (final item in decoded) {
            try {
              properties.add(ProducerProperty.fromPropertyJson(item as Map<String, dynamic>));
            } catch (e) {
              print('DEBUG: Erro ao parsear propriedade: $e');
              print('DEBUG: Item problemático: $item');
            }
          }
          print('SERVICE: Encontradas ${properties.length} propriedades');
          return properties;
        } else {
          print('DEBUG: Resposta não é uma lista: $decoded');
          return [];
        }
      } else {
        print('DEBUG: Erro na resposta: ${response.body}');
        throw Exception('Erro ao buscar propriedades: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no MilkCollectionService.searchProperties: $e');
      rethrow;
    }
  }

  /// Busca produtores por nome no backend
  Future<List<ProducerProperty>> searchProducers(String query) async {
    if (query.isEmpty) {
      return [];
    }

    print('SERVICE: Buscando produtores com a query: "$query"');

    try {
      final uri = Uri.parse('$_baseUrl/producer/search').replace(
        queryParameters: {'q': query},
      );

      print('DEBUG MilkCollectionService.searchProducers: GET $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('DEBUG MilkCollectionService.searchProducers: Status ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);

        if (decoded is List) {
          final producers = <ProducerProperty>[];
          for (final item in decoded) {
            try {
              producers.add(ProducerProperty.fromProducerJson(item as Map<String, dynamic>));
            } catch (e) {
              print('DEBUG: Erro ao parsear produtor: $e');
              print('DEBUG: Item problemático: $item');
            }
          }
          print('SERVICE: Encontrados ${producers.length} produtores');
          return producers;
        } else {
          print('DEBUG: Resposta não é uma lista: $decoded');
          return [];
        }
      } else {
        print('DEBUG: Erro na resposta: ${response.body}');
        throw Exception('Erro ao buscar produtores: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no MilkCollectionService.searchProducers: $e');
      rethrow;
    }
  }
}
