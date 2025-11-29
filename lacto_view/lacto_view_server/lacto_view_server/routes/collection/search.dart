import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_firebase_admin/auth.dart';
import '../../service/collection_service.dart';

/// Rota GET /collection/search
/// 
/// Query parameters:
/// - type: 'producer' | 'collector' | 'property' | 'id'
/// - search: termo de busca
/// - start_date: data inicial (ISO8601)
/// - end_date: data final (ISO8601)
/// - producer_id: ID do produtor (para filtrar coletas de um produtor específico)
/// - limit: número máximo de resultados (default: 20)
Future<Response> onRequest(RequestContext context) async {
  final collectionService = context.read<CollectionService>();
  final auth = context.read<Auth>();

  // Apenas GET é permitido
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  // Verifica autenticação
  String uid;
  try {
    final header = context.request.headers['Authorization'];
    if (header == null) {
      return Response.json(
        body: {'error': 'Não autorizado: Token ausente'},
        statusCode: 401,
      );
    }
    final token = header.replaceFirst('Bearer ', '');
    final decodedToken = await auth.verifyIdToken(token);
    uid = decodedToken.uid;
  } catch (e) {
    print('!!! Erro na verificação do token: $e');
    return Response.json(
      body: {'error': 'Não autorizado: Token inválido'},
      statusCode: 401,
    );
  }

  try {
    // Extrai parâmetros da query
    final queryParams = context.request.uri.queryParameters;
    
    final searchType = queryParams['type'] ?? 'producer';
    final searchTerm = queryParams['search'] ?? '';
    final startDateStr = queryParams['start_date'];
    final endDateStr = queryParams['end_date'];
    final producerId = queryParams['producer_id'];
    final limitStr = queryParams['limit'] ?? '20';
    final limit = int.tryParse(limitStr) ?? 20;

    DateTime? startDate;
    DateTime? endDate;

    if (startDateStr != null && startDateStr.isNotEmpty) {
      startDate = DateTime.tryParse(startDateStr);
    }
    if (endDateStr != null && endDateStr.isNotEmpty) {
      endDate = DateTime.tryParse(endDateStr);
    }

    print('--- DEBUG: Busca de coletas ---');
    print('--- Tipo: $searchType');
    print('--- Termo: $searchTerm');
    print('--- Data inicial: $startDate');
    print('--- Data final: $endDate');
    print('--- Producer ID: $producerId');
    print('--- Limit: $limit');

    // Realiza a busca baseada no tipo
    final collections = await collectionService.searchCollections(
      type: searchType,
      searchTerm: searchTerm,
      startDate: startDate,
      endDate: endDate,
      producerId: producerId,
      limit: limit,
    );

    // Converte para JSON
    final result = collections.map((c) => c.toMap()).toList();

    return Response.json(
      body: result,
      statusCode: HttpStatus.ok,
    );
  } catch (e) {
    print('!!! Erro na busca de coletas: $e');
    return Response.json(
      body: {'error': 'Erro ao buscar coletas: ${e.toString()}'},
      statusCode: 500,
    );
  }
}

