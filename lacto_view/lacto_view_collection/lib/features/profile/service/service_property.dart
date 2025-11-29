import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import '../model/property_model.dart';

class PropertyService {
  final String _baseUrl = 'http://localhost:8080';

  Future<bool> createProperty({required Property property}) async {
    try {
      print("Chamando back para salvar novo 'property'");

      print(property.toJson());

      final Map<String, dynamic> requestBody = property.toMap();

      final user = FirebaseAuth.instance.currentUser;

      String? token;

      try {
        token = await FirebaseAuth.instance.currentUser?.getIdToken();
      } catch (e) {
        print("Aviso: Não foi possível obter token do usuário logado: $e");
      }

      if (token == null) {
        print("Usuário não está logado no Firebase Auth do App.");
        return false;
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/property_route'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Backend response: SUCESS (create)");
        print("Data: ${response.body}");
        return true;
      } else {
        print("Back-end error: ${response.statusCode}");
        print("Message: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Conection error or local exception: $e");
      return false;
    }
  }

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
