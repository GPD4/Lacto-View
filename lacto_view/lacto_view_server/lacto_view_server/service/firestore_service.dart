// lib/firestore_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  AuthClient? _client;
  String? _projectId;

  Future<void> initialize() async {
    if (_client != null) return;

    final serviceAccountPath =
        Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];
    if (serviceAccountPath == null) {
      throw Exception(
        'A variável GOOGLE_APPLICATION_CREDENTIALS não foi definida.',
      );
    }

    // 📄 Lê o conteúdo do arquivo JSON manualmente
    final fileContent = File(serviceAccountPath).readAsStringSync();
    final jsonData = jsonDecode(fileContent);

    // ✅ Extrai o project_id do JSON
    _projectId = jsonData['project_id'] as String?;
    if (_projectId == null) {
      throw Exception('Project ID não encontrado na chave de serviço.');
    }

    // Cria as credenciais para autenticação
    final credentials = ServiceAccountCredentials.fromJson(fileContent);
    const scopes = ['https://www.googleapis.com/auth/datastore'];

    _client = await clientViaServiceAccount(credentials, scopes);
    print('✅ FirestoreService inicializado para o projeto: $_projectId');
  }

  Future<List<Map<String, dynamic>>> getPersons() async {
    await initialize();

    final url = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/person',
    );

    final response = await _client!.get(url);

    if (response.statusCode != 200) {
      throw Exception('Erro ao consultar Firestore: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final documents = data['documents'] as List<dynamic>? ?? [];

    return documents.map((doc) {
      final fields = doc['fields'] as Map<String, dynamic>;
      return {
        'name': fields['name']?['stringValue'],
        'role': fields['role']?['stringValue'],
      };
    }).toList();
  }
}
