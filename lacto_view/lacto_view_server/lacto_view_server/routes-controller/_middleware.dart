import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:firebase_admin/firebase_admin.dart';

App? _firebaseApp;

Handler middleware(Handler handler) {
  if (_firebaseApp == null) {
    print('Inicializando Firebase Admin SDK...');
    try {
      // Pega o caminho do arquivo de credenciais da variável de ambiente.
      final certPath = Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];
      if (certPath == null) {
        throw Exception(
          'A variável de ambiente GOOGLE_APPLICATION_CREDENTIALS não foi definida.',
        );
      }

      final credential = FirebaseAdmin.instance.certFromPath(certPath);

      // Inicializa o app e armazena a instância.
      _firebaseApp = FirebaseAdmin.instance.initializeApp(
        AppOptions(credential: credential),
      );
      print('Firebase Admin SDK inicializado com sucesso!');
    } catch (e) {
      print('### ERRO FUDIDO ao inicializar o Firebase: $e');
      // Em caso de falha, você pode querer que o servidor pare.
      // Neste caso, vamos relançar o erro.
      rethrow;
    }
  }

  // Use o provider para injetar as instâncias de Auth e Firestore
  // para que todas as rotas filhas possam acessá-las facilmente.
  return handler.use(
    provider<Auth>((_) => _firebaseApp!.auth()),
  );
}
