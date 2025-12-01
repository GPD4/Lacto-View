import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../milk_collection/model/model_collection.dart';
import '../model/dashboard_model.dart';

/// Serviço para buscar dados do Dashboard
class HomeService {
  final String _baseUrl = 'http://localhost:8080';

  /// Busca as coletas e calcula as estatísticas
  Future<DashboardStats> getDashboardStats({
    required String token,
    String? producerId,
    String? collectorId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (producerId != null && producerId.isNotEmpty) {
        queryParams['producer_id'] = producerId;
      }

      if (collectorId != null && collectorId.isNotEmpty) {
        queryParams['collector_id'] = collectorId;
      }

      // Pega os últimos 30 dias por padrão
      final now = DateTime.now();
      final start = startDate ?? now.subtract(const Duration(days: 30));
      final end = endDate ?? now;

      queryParams['start_date'] = start.toIso8601String();
      queryParams['end_date'] = end.toIso8601String();
      queryParams['limit'] = '500'; // Limite maior para estatísticas

      final uri = Uri.parse('$_baseUrl/collection').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);

        if (decoded is List) {
          final collections = <MilkCollection>[];
          for (final item in decoded) {
            try {
              collections
                  .add(MilkCollection.fromJson(item as Map<String, dynamic>));
            } catch (e) {
              print('DEBUG HomeService: Erro ao parsear coleta: $e');
            }
          }

          return _calculateStats(collections);
        }
      }

      return DashboardStats.empty();
    } catch (e) {
      print('Erro no HomeService.getDashboardStats: $e');
      return DashboardStats.empty();
    }
  }

  /// Calcula estatísticas a partir das coletas
  DashboardStats _calculateStats(List<MilkCollection> collections) {
    if (collections.isEmpty) {
      return DashboardStats.empty();
    }

    int totalCollections = collections.length;
    double totalVolume = 0;
    int pendingCollections = 0;
    int rejectedCollections = 0;
    double totalTemperature = 0;
    double totalPh = 0;
    int samplesCollected = 0;
    int validTemperatureCount = 0;
    int validPhCount = 0;

    // Maps para agrupar dados
    final Map<String, CollectionByDay> byDay = {};
    final Map<String, _ProducerAccumulator> byProducer = {};

    for (final c in collections) {
      totalVolume += c.volumeLt;

      if (c.status.toLowerCase() == 'pendente') {
        pendingCollections++;
      }

      if (c.rejection) {
        rejectedCollections++;
      }

      if (c.temperature > 0) {
        totalTemperature += c.temperature;
        validTemperatureCount++;
      }

      if (c.ph > 0) {
        totalPh += c.ph;
        validPhCount++;
      }

      if (c.sample) {
        samplesCollected++;
      }

      // Agrupa por dia
      final dayKey =
          '${c.createdAt.year}-${c.createdAt.month.toString().padLeft(2, '0')}-${c.createdAt.day.toString().padLeft(2, '0')}';
      if (byDay.containsKey(dayKey)) {
        final existing = byDay[dayKey]!;
        byDay[dayKey] = CollectionByDay(
          date: existing.date,
          count: existing.count + 1,
          volume: existing.volume + c.volumeLt,
        );
      } else {
        byDay[dayKey] = CollectionByDay(
          date: DateTime(c.createdAt.year, c.createdAt.month, c.createdAt.day),
          count: 1,
          volume: c.volumeLt,
        );
      }

      // Agrupa por produtor
      if (c.producerId != null && c.producerId!.isNotEmpty) {
        if (byProducer.containsKey(c.producerId)) {
          byProducer[c.producerId]!.totalVolume += c.volumeLt;
          byProducer[c.producerId]!.collectionCount++;
        } else {
          byProducer[c.producerId!] = _ProducerAccumulator(
            producerId: c.producerId!,
            producerName: c.producerName,
            totalVolume: c.volumeLt,
            collectionCount: 1,
          );
        }
      }
    }

    // Converte maps para listas ordenadas
    final collectionsByDay = byDay.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final topProducers = byProducer.values
        .map((acc) => CollectionByProducer(
              producerId: acc.producerId,
              producerName: acc.producerName,
              totalVolume: acc.totalVolume,
              collectionCount: acc.collectionCount,
            ))
        .toList()
      ..sort((a, b) => b.totalVolume.compareTo(a.totalVolume));

    return DashboardStats(
      totalCollections: totalCollections,
      totalVolume: totalVolume,
      pendingCollections: pendingCollections,
      rejectedCollections: rejectedCollections,
      averageTemperature:
          validTemperatureCount > 0 ? totalTemperature / validTemperatureCount : 0,
      averagePh: validPhCount > 0 ? totalPh / validPhCount : 0,
      samplesCollected: samplesCollected,
      collectionsByDay: collectionsByDay,
      topProducers: topProducers.take(5).toList(), // Top 5
    );
  }

  /// Busca coletas de hoje para resumo rápido
  Future<UserSummary> getTodaySummary({
    required String token,
    required String userName,
    String? producerId,
    String? collectorId,
  }) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final queryParams = <String, String>{};

      if (producerId != null && producerId.isNotEmpty) {
        queryParams['producer_id'] = producerId;
      }

      if (collectorId != null && collectorId.isNotEmpty) {
        queryParams['collector_id'] = collectorId;
      }

      queryParams['start_date'] = startOfDay.toIso8601String();
      queryParams['end_date'] = endOfDay.toIso8601String();
      queryParams['limit'] = '100';

      final uri = Uri.parse('$_baseUrl/collection').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      String greeting = _getGreeting();
      String subtitle = '';
      int todayCollections = 0;
      double todayVolume = 0;

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);

        if (decoded is List) {
          for (final item in decoded) {
            try {
              final c =
                  MilkCollection.fromJson(item as Map<String, dynamic>);
              todayCollections++;
              todayVolume += c.volumeLt;
            } catch (e) {
              print('DEBUG: Erro ao parsear coleta: $e');
            }
          }
        }
      }

      if (todayCollections > 0) {
        subtitle = '$todayCollections coleta(s) hoje • ${todayVolume.toStringAsFixed(1)}L';
      } else {
        subtitle = 'Nenhuma coleta registrada hoje';
      }

      return UserSummary(
        greeting: '$greeting, $userName!',
        subtitle: subtitle,
        todayCollections: todayCollections,
        todayVolume: todayVolume,
      );
    } catch (e) {
      print('Erro no HomeService.getTodaySummary: $e');
      return UserSummary(
        greeting: '${_getGreeting()}, $userName!',
        subtitle: 'Não foi possível carregar dados',
        todayCollections: 0,
        todayVolume: 0,
      );
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bom dia';
    } else if (hour < 18) {
      return 'Boa tarde';
    } else {
      return 'Boa noite';
    }
  }
}

/// Classe auxiliar para acumular dados do produtor
class _ProducerAccumulator {
  final String producerId;
  final String producerName;
  double totalVolume;
  int collectionCount;

  _ProducerAccumulator({
    required this.producerId,
    required this.producerName,
    required this.totalVolume,
    required this.collectionCount,
  });
}

