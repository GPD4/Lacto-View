import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../model/collection_model.dart';
import '../service/collection_service.dart';

Future<Response> onRequest(RequestContext context) async {
  final collectionService = context.read<CollectionService>();

  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }
  try {
    final requestBody = await context.request.json();
    final data = requestBody as Map<String, dynamic>;

    final collection = MilkCollection.fromMap(data);

    final newCollection = await collectionService.addCollection(collection);

    return Response.json(
      body: newCollection.toMap(),
      statusCode: HttpStatus.created, // 201
    );
  } catch (e) {
    return Response.json(body: {'error': e.toString()}, statusCode: 400);
  }
}
