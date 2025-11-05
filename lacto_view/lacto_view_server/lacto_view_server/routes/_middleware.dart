// Utilize o terminal e rode 'dart pub add dart_firebase_admin:^0.4.1' dentro da pasta lacto_view_server

import 'package:dart_frog/dart_frog.dart';

import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/firestore.dart';
import 'package:dart_firebase_admin/auth.dart';

// Serviços
import '../service/person_service.dart';
import '../service/collection_service.dart';
import '../service/producer_service.dart';

FirebaseAdminApp? _firebaseApp;

Future<FirebaseAdminApp> _initializeFirebase() async {
  if (_firebaseApp != null) return _firebaseApp!;

  try {
    _firebaseApp = FirebaseAdminApp.initializeApp(
      'lactoview-13e4c',
      Credential.fromApplicationDefaultCredentials(),
    );
    print('--- Firebase Admin SDK Conectado e Autenticado com Êxito! ---');
    return _firebaseApp!;
  } catch (e) {
    print('!!! Erro ao Inicializar o Firebase: $e');
    print(
        'Verifique se a variável de ambiente GOOGLE_APPLICATION_CREDENTIALS está correta.');
    rethrow;
  }
}

Handler middleware(Handler handler) {
  return (context) async {
    final app = await _initializeFirebase();

    final auth = Auth(app);
    final firestore = Firestore(app);

    return handler
        .use(provider<Auth>((_) => auth))
        .use(provider<Firestore>((_) => firestore))
        .use(provider<PersonService>(
          (_) => PersonService(firestore, auth),
        ))(context);
  };
}
