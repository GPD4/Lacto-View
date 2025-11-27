import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_firebase_admin/auth.dart';
import '../service/user_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.get) {
    return _getUserProfile(context);
  }

  return Future.value(Response(statusCode: HttpStatus.methodNotAllowed));
}

Future<Response> _getUserProfile(RequestContext context) async {
  try {
    final userService = context.read<UserService>();
    final authHeader = context.request.headers['authorization'];

    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {'error': 'Token não fornecido'},
      );
    }
    final token = authHeader.substring(7);

    //Validar token com o Firebase
    final auth = context.read<Auth>();
    final decoded = await auth.verifyIdToken(token);

    if (decoded == null) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {'erro': 'Token inválido'},
      );
    }

    final authUid = decoded.uid;

    //Buscar 'person' por UID
    final user = await userService.getPersonByUid(authUid);

    return Response.json(
      statusCode: HttpStatus.ok,
      body: user.toJson(),
    );
  } catch (e) {
    print('Erro no GET /user: $e\n$e');
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': e.toString()},
    );
  }
}
