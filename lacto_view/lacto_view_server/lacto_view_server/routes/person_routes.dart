import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_firebase_admin/auth.dart';
import '../model/person_model.dart';
import '../service/person_service.dart';

Future<Response> onRequest(RequestContext context) async {
  final personService = context.read<PersonService>();
  final auth = context.read<Auth>();

  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

// <<< Logica de autenticação de usuários >>>

  String? uid;

  try {
    //Pega o Token do header 'Authorization: Bearer <token>'
    final header = context.request.headers['Authorization'];
    if (header == null) {
      return Response(statusCode: 401, body: 'Não autorizado: Token ausente');
    }
    // Verifica o token com o Firebase Auth
    final token = header.replaceFirst('Bearer ', '');
    final decodedToken = await auth.verifyIdToken(token);
    // Pega o UID de dentro do token verificado
    uid = decodedToken.uid;
  } catch (e) {
    print('!!!!!!!!!!!!!! ERRO REAL DA VERIFICAÇÃO: $e');
    return Response(statusCode: 401, body: 'Não autorizado: Token inválido');
  }

  try {
    final requestBody = await context.request.json();

    final data = requestBody as Map<String, dynamic>;

    final person = Person.fromMap(data);

    final newPerson = await personService.createPerson(uid, person);

    return Response.json(
      body: newPerson.toMap(),
      statusCode: HttpStatus.created, //Code: 201
    );
  } catch (e) {
    return Response.json(body: {'error': e.toString()}, statusCode: 400);
  }
}
