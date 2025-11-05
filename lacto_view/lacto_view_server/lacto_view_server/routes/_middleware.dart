// Utilize o terminal e rode 'dart pub add dart_firebase_admin:^0.4.1' dentro da pasta lacto_view_server
// https://lactoview-13e4c-default-rtdb.firebaseio.com/

import 'package:dart_frog/dart_frog.dart';
import 'dart:io';

import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_firebase_admin/firestore.dart';

// Serviços
import '../service/person_service.dart';
import '../service/collection_service.dart';
import '../service/producer_service.dart';

FirebaseAdminApp? _firebaseApp;

Future<FirebaseAdminApp> _initializeFirebase() async {
  if (_firebaseApp != null) return _firebaseApp!;

  const String serviceAccountPath =
      //Caminho do arquivo de serviço Firebase >>>>
      r'C:\Users\User\Desktop\GITHUB LACTOVIEW\LactoView_Mobile\lacto_view_server\lacto_view_server\lactoview4-c8c865e3ea92.json';

  try {
    final file = File(serviceAccountPath);
    if (!await file.exists()) {
      throw Exception(
          'Arquivo de chave de serviço não encontrado: $serviceAccountPath');
    }
    final credential = Credential.fromServiceAccount(file);

    const databaseUrl = 'https://lactoview-13e4c-default-rtdb.firebaseio.com';

    _firebaseApp = FirebaseAdminApp.initializeApp(
      'lactoview4',
      credential,
    );
    print('--- Firebase Admin SDK Conectado (Lendo JSON) com Êxito! ---');
    return _firebaseApp!;
  } catch (e) {
    print('!!! Erro ao Inicializar o Firebase (Lendo JSON): $e');
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
