import 'dart:convert';
import '../model/property_model.dart';
import 'package:http/http.dart' as http;

class ServicePropertySearch {
  /// Salva uma nova property no backend.
  /// No futuro, é aqui que você colocará seu código http.post
  /// para se comunicar com seu backend Dart Frog.
  final String _baseUrl = 'http://localhost:8080';

  Future<List<Property>> searchProperties(String query, {int? limit}) async {
    final params = <String, String>{'q': query};

    if (limit != null) {
      params['limit'] = limit.toString();
    }

    final uri = Uri.parse(
      '$_baseUrl/property/search',
    ).replace(queryParameters: params);

    print('--- Service: Chamando API em: $uri');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        return jsonList.map((jsonItem) => Property.fromJson(jsonItem)).toList();
      } else {
        throw Exception(
          'Falha ao carregar propriedades. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Erro de conexão no Service: $e');
      throw Exception('Erro de conexão $e');
    }
  }
}
