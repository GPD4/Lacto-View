import 'dart:convert';
import '../model/person_model.dart';
import 'package:http/http.dart' as http;

class ServicePersonSearch {
  final String _baseUrl = 'http://localhost:8080';

  /// Busca pessoas por nome ou CPF/CNPJ
  /// TODO: Implementar rota /person/search no backend
  Future<List<Person>> searchPersons(String query, {int? limit}) async {
    final params = <String, String>{'q': query};

    if (limit != null) {
      params['limit'] = limit.toString();
    }

    final uri = Uri.parse(
      '$_baseUrl/person/search',
    ).replace(queryParameters: params);

    print('--- Service: Chamando API em: $uri');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        return jsonList.map((jsonItem) => Person.fromJson(jsonItem)).toList();
      } else {
        print('--- Service: Erro ${response.statusCode}');
        throw Exception('Erro ao buscar pessoas: ${response.statusCode}');
      }
    } catch (e) {
      print('--- Service: Exception: $e');
      throw Exception('Erro de conexão: $e');
    }
  }
}
