// lib/firebase_service.dart
import 'dart:io';
import 'package:firebase_admin/firebase_admin.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  App? _app;

  Future<void> initialize() async {
    if (_app != null) return;

    try {
      final certPath = Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];
      if (certPath == null) {
        throw Exception(
          'A variável de ambiente GOOGLE_APPLICATION_CREDENTIALS não foi definida.',
        );
      }

      final credential = FirebaseAdmin.instance.certFromPath(certPath);

      _app = FirebaseAdmin.instance.initializeApp(
        AppOptions(credential: credential),
      );

      print('Firebase Admin Inicializado com Sucesso!!!');
    } catch (e) {
      print('Erro ao inicializar Firebase Admin: $e');
      rethrow;
    }
  }

  Auth get auth {
    if (_app == null) {
      throw Exception(
          'Firebase não inicializado. Chame initialize() primeiro.');
    }
    return _app!.auth();
  }
}
