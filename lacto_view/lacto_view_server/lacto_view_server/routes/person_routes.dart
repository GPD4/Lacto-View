import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_firebase_admin/auth.dart';
import '../model/person_model.dart';
import '../service/person_service.dart';
import '../model/producer_model.dart';

Future<Response> onRequest(RequestContext context) async {
  final personService = context.read<PersonService>();
  final auth = context.read<Auth>();

  if (context.request.method == HttpMethod.options) {
    return Response(statusCode: HttpStatus.noContent);
  }

  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

// <<< Logica de autenticação de usuários >>>

  String? uid;

  try {
    final header = context.request.headers['Authorization'];
    if (header == null) {
      return Response(statusCode: 401, body: 'Não autorizado: Token ausente');
    }
    final token = header.replaceFirst('Bearer ', '');
    final decodedToken = await auth.verifyIdToken(token);

    uid = decodedToken.uid;
  } catch (e) {
    print('!!!!!!!!!!!!!! ERRO REAL DA VERIFICAÇÃO: $e');
    return Response(statusCode: 401, body: 'Não autorizado: Token inválido');
  }

  try {
    final requestBody = await context.request.json();
    final data = requestBody as Map<String, dynamic>;

    final password = data.remove('password') as String?;

    final cadpro = data.remove('cadpro') as String?;

    final propertyId = data.remove('property_id') as String?;

    if (password == null || password.isEmpty) {
      return Response.json(
        body: {'error': 'O campo "password" é obrigatório.'},
        statusCode: 400,
      );
    }

    final person = Person.fromMap(data);

    //Criará 'Person' e 'User' na transação
    final newPerson = await personService.createPerson(
      person,
      password,
      cadpro,
      propertyId,
    );

    //Retorna o usuário recém-criado
    return Response.json(
      body: newPerson.toMap(),
      statusCode: HttpStatus.created, //Code: 201
    );
  } catch (e) {
    // Captura erros (ex: "CPF já existe" do serviço)
    return Response.json(
      body: {'error': e.toString()},
      statusCode: 400, // 400 Bad Request ou 409 Conflict
    );
  }
}
