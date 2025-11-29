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

    //Lê o conteúdo do arquivo JSON manualmente
    final fileContent = File(serviceAccountPath).readAsStringSync();
    final jsonData = jsonDecode(fileContent);

    // Extrai o project_id do JSON
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

// metodo GetPersons
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

  Future<String> addDocument(
      String collectionName, Map<String, dynamic> data) async {
    await initialize(); //gatantir que esteja autenticado

// Url para criar um documento sem ID
    final url = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/$collectionName',
    );

    final firestoreBody = {
      'fields': _mapToFirestoreFields(data),
    };

// requisição POST com o body formatado
    final response = await _client!.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(firestoreBody),
    );

// se API retornar 200 informa o erro:
    if (response.statusCode != 200) {
      throw Exception(
          'Falha ao criar documento no Firestore: ${response.body}');
    }

    final responseData = jsonDecode(response.body);
    final documentName = responseData['name'] as String;
    final documentId = documentName.split('/').last;

    return documentId;
  }

  // Conversor
  // Converte um Map Dart (ex: {'name': 'Gui'})
  // para o formato da API REST (ex: {'name': {'stringValue': 'Gui'}})

  Map<String, dynamic> _mapToFirestoreFields(Map<String, dynamic> map) {
    final fields = <String, dynamic>{};

    map.forEach((key, value) {
      if (value is String) {
        fields[key] = {'stringValue': value};
      } else if (value is bool) {
        fields[key] = {'booleanValue': value};
      } else if (value is int) {
        fields[key] = {'integerValue': value.toString()};
      } else if (value is double) {
        fields[key] = {'integerValue': value.toString()};
      } else if (value is DateTime) {
        fields[key] = {'timestampValue': value.toIso8601String()};
      } else if (value == null) {
        fields[key] = {'nullValue': null};
      }
    });

    return fields;
  }
}
