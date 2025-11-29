import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../milk_collection/model/model_collection.dart';

/// Tipo de busca disponível
enum SearchType {
  producer,
  collector,
  collectionNumber,
}

/// Serviço para buscar coletas no backend
class SearchCollectionService {
  final String _baseUrl = 'http://localhost:8080';

  /// Busca coletas com filtros
  Future<List<MilkCollection>> searchCollections({
    required String token,
    required SearchType searchType,
    String? searchTerm,
    DateTime? startDate,
    DateTime? endDate,
    String? producerId,
    int limit = 20,
  }) async {
    try {
      // Monta os parâmetros de query
      final queryParams = <String, String>{};
      
      if (searchTerm != null && searchTerm.isNotEmpty) {
        queryParams['search'] = searchTerm;
        queryParams['type'] = searchType.name;
      }
      
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }
      
      if (producerId != null && producerId.isNotEmpty) {
        queryParams['producer_id'] = producerId;
      }
      
      queryParams['limit'] = limit.toString();

      final uri = Uri.parse('$_baseUrl/collection/search').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      print('DEBUG SearchCollectionService: GET $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('DEBUG SearchCollectionService: Status ${response.statusCode}');

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
        print('DEBUG: Erro na resposta: ${response.body}');
        throw Exception('Erro ao buscar coletas: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no SearchCollectionService.searchCollections: $e');
      rethrow;
    }
  }

  /// Busca todas as coletas (com paginação)
  Future<List<MilkCollection>> getAllCollections({
    required String token,
    String? producerId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
    String? lastDocumentId,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (producerId != null && producerId.isNotEmpty) {
        queryParams['producer_id'] = producerId;
      }
      
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }
      
      queryParams['limit'] = limit.toString();
      
      if (lastDocumentId != null && lastDocumentId.isNotEmpty) {
        queryParams['start_after'] = lastDocumentId;
      }

      final uri = Uri.parse('$_baseUrl/collection').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      print('DEBUG SearchCollectionService: GET $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('DEBUG SearchCollectionService: Status ${response.statusCode}');

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
        print('DEBUG: Erro na resposta: ${response.body}');
        throw Exception('Erro ao buscar coletas: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro no SearchCollectionService.getAllCollections: $e');
      rethrow;
    }
  }
}
