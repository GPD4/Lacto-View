import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../service/producer_service.dart';

/// Rota GET /producer/search
/// 
/// Query parameters:
/// - q: termo de busca (nome do produtor)
/// - limit: número máximo de resultados (default: 5)
Future<Response> onRequest(RequestContext context) async {
  // Apenas GET é permitido
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  // Pega os parâmetros da URL
  final params = context.request.uri.queryParameters;
  final searchQuery = params['q'];
  final limitStr = params['limit'] ?? '5';
  final limit = int.tryParse(limitStr) ?? 5;

  // Se 'q' não foi enviado, retorna lista vazia
  if (searchQuery == null || searchQuery.isEmpty) {
    return Response.json(body: []);
  }

  // Pega o serviço
  final producerService = context.read<ProducerService>();

  try {
    // Chama o método de busca
    final results = await producerService.searchByName(searchQuery, limit: limit);

    // Converte para JSON
    final resultsAsJson = results.map((p) => p.toMap()).toList();

    return Response.json(body: resultsAsJson);
  } catch (e) {
    print('!!! Erro na busca de produtores: $e');
    return Response.json(
      body: {'error': 'Erro no servidor: ${e.toString()}'},
      statusCode: 500,
    );
  }
}

