import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../service/property_service.dart';

Future<Response> onRequest(RequestContext context) async {
  // 1. Este endpoint só aceita o método GET
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  // 2 Pega o parametro 'q' da URL (ex: /search?q=teste)
  final params = context.request.uri.queryParameters;
  final searchQuery = params['q'];

  // 3 Se 'q' nao foi enviado, retorna uma lista vazia
  if (searchQuery == null || searchQuery.isEmpty) {
    return Response.json(body: []);
  }

  // 4 Pega o serviço
  final propertyService = context.read<PropertyService>();

  try {
    // 5 Chama o metodo de busca do seu serviço
    final results = await propertyService.searchByNameOrCity(searchQuery);

    final limitedResults = results.take(5).toList();

    // 6 Converte a lista de Objetos Property em uma lista de Mapas (JSON)
    final resultsAsJson = limitedResults.map((prop) => prop.toMap()).toList();

    // 7 Retorna a lista como JSON
    return Response.json(body: resultsAsJson);
  } catch (e) {
    return Response.json(
      body: {'error': 'Erro no servidor: ${e.toString()}'},
      statusCode: 500,
    );
  }
}
