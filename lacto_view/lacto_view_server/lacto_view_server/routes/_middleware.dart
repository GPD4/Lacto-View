// Utilize o terminal e rode 'dart pub add dart_firebase_admin:^0.4.1' dentro da pasta lacto_view_server
// https://lactoview-13e4c-default-rtdb.firebaseio.com/

import 'package:dart_frog/dart_frog.dart';
import 'dart:io';

import 'package:dart_firebase_admin/dart_firebase_admin.dart';
import 'package:dart_firebase_admin/auth.dart';
import 'package:dart_firebase_admin/firestore.dart';

// Serviços
import '../model/property_model.dart';
import '../service/person_service.dart';
import '../service/collection_service.dart';
import '../service/producer_service.dart';
import '../service/property_service.dart';
import '../service/user_service.dart';

FirebaseAdminApp? _firebaseApp;

Future<FirebaseAdminApp> _initializeFirebase() async {
  if (_firebaseApp != null) return _firebaseApp!;

  const String serviceAccountPath =
      //Caminho do arquivo de serviço Firebase >>>>
      r'C:\Users\User\Desktop\lacto-view-private\LactoView_Mobile\lacto_view_server\lacto_view_server\lactoview4-firebase-adminsdk-fbsvc-182881e85c.json';

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

    final diHandler = handler
        .use(provider<Auth>((_) => auth))
        .use(provider<Firestore>((_) => firestore))
        .use(provider<PersonService>(
          (_) => PersonService(firestore, auth),
        ))
        .use(provider<PropertyService>(
          (_) => PropertyService(firestore, auth),
        ))
        .use(provider<CollectionService>(
          (_) => CollectionService(firestore),
        ))
        .use(provider<UserService>(
          (_) => UserService(firestore, auth),
        ));

    // 👉 TRATAMENTO DE REQUISIÇÕES OPTIONS (CORS PREFLIGHT)
    if (context.request.method == HttpMethod.options) {
      return Response(
        statusCode: 200,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS, PUT, DELETE',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
        },
      );
    }

    // 👉 Continua o fluxo normal
    final response = await diHandler(context);

    // 👉 Garante CORS em todas as respostas
    return response.copyWith(
      headers: {
        ...response.headers,
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS, PUT, DELETE',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
      },
    );
  };
}
