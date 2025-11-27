import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import '../model/person_model.dart';

class PersonService {
  final String _baseUrl = 'http://localhost:8080';

  Future<bool> createPerson({
    required Person person,
    required String password,
    String? cadpro,
    String? propertyId,
  }) async {
    try {
      // --- INÍCIO: LÓGICA DO BACKEND (EX: Dart Frog) ---
      print("Chamando o backend para salvar novo 'person':");

      print(person.toJson());

      final Map<String, dynamic> requestBody = person.toMap();

      requestBody['password'] = password;

      if (cadpro != null && cadpro != cadpro.isNotEmpty) {
        requestBody['cadpro'] = cadpro;
      }

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
        Uri.parse('$_baseUrl/person_routes'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Backend respondeu: SUCESSO (Criado)");
        print("Dados: ${response.body}");
        return true;
      } else {
        print("Erro do Backend: ${response.statusCode}");
        print("Mensagem: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Erro de conexão ou exceção local: $e");
      return false;
    }

    // Future<List<Person>> getPersons() async { ... }
    // Future<Person> updatePerson(String id, Person person) async { ... }
    // Future<void> deletePerson(String id) async { ... }
  }
}
