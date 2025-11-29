import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_firebase_admin/auth.dart';
import '../model/property_model.dart';
import '../service/property_service.dart';

Future<Response> onRequest(RequestContext context) async {
  final propertyService = context.read<PropertyService>();
  final auth = context.read<Auth>();

  if (context.request.method == HttpMethod.options) {
    return Response(statusCode: HttpStatus.noContent);
  }

  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  String uid;

  try {
    final header = context.request.headers['Authorization'];
    if (header == null) {
      return Response(statusCode: 401, body: 'Não autorizado: Token ausente');
    }
    final token = header.replaceFirst('Bearer ', '');
    final decodedToken = await auth.verifyIdToken(token);

    uid = decodedToken.uid;
  } catch (e) {
    print('!!! Erro real da Verificação: $e');
    return Response(statusCode: 401, body: 'Não autorizado: Token inválido');
  }

  try {
    final requestBody = await context.request.json();

    print('--- DEBUG PROPERTY ROUTE: Body recebido: $requestBody');

    final data = requestBody as Map<String, dynamic>;

    final property = Property.fromMap(data);

    final newProperty = await propertyService.createProperty(uid, property);

    print('--- DEBUG PROPERTY ROUTE: Sucesso. ID Criado: ${newProperty.id}');

    return Response.json(
      body: newProperty.toMap(),
      statusCode: HttpStatus.created, //Code: 201
    );
  } catch (e) {
    print('Erro ao criar propriedade: $e');
    return Response.json(body: {'error': e.toString()}, statusCode: 400);
  }
}
