import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_firebase_admin/auth.dart';
import '../../model/collection_model.dart';
import '../../service/collection_service.dart';

/// Rota /collection
/// 
/// POST: Criar nova coleta
/// GET: Listar coletas (com filtros opcionais)
Future<Response> onRequest(RequestContext context) async {
  final collectionService = context.read<CollectionService>();
  final auth = context.read<Auth>();

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

  switch (context.request.method) {
    case HttpMethod.post:
      return _handlePost(context, collectionService, uid);
    case HttpMethod.get:
      return _handleGet(context, collectionService);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

/// Cria uma nova coleta
Future<Response> _handlePost(
  RequestContext context,
  CollectionService service,
  String uid,
) async {
  try {
    final requestBody = await context.request.json();
    final data = requestBody as Map<String, dynamic>;
    final collection = MilkCollection.fromMap(data);
    final newCollection = await service.addCollection(uid, collection);

    return Response.json(
      body: newCollection.toMap(),
      statusCode: HttpStatus.created,
    );
  } catch (e) {
    print('!!! Erro ao criar coleta: $e');
    return Response.json(
      body: {'error': 'Erro ao criar coleta: ${e.toString()}'},
      statusCode: 400,
    );
  }
}

/// Lista coletas com filtros opcionais
Future<Response> _handleGet(
  RequestContext context,
  CollectionService service,
) async {
  try {
    final queryParams = context.request.uri.queryParameters;
    
    final producerId = queryParams['producer_id'];
    final startDateStr = queryParams['start_date'];
    final endDateStr = queryParams['end_date'];
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

    final collections = await service.searchCollections(
      type: 'all',
      producerId: producerId,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );

    final result = collections.map((c) => c.toMap()).toList();

    return Response.json(
      body: result,
      statusCode: HttpStatus.ok,
    );
  } catch (e) {
    print('!!! Erro ao listar coletas: $e');
    return Response.json(
      body: {'error': 'Erro ao listar coletas: ${e.toString()}'},
      statusCode: 500,
    );
  }
}

