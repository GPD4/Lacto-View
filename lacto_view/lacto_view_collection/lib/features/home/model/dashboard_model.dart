/// Modelo para estatísticas do Dashboard
class DashboardStats {
  final int totalCollections;
  final double totalVolume;
  final int pendingCollections;
  final int rejectedCollections;
  final double averageTemperature;
  final double averagePh;
  final int samplesCollected;
  final List<CollectionByDay> collectionsByDay;
  final List<CollectionByProducer> topProducers;

  DashboardStats({
    required this.totalCollections,
    required this.totalVolume,
    required this.pendingCollections,
    required this.rejectedCollections,
    required this.averageTemperature,
    required this.averagePh,
    required this.samplesCollected,
    required this.collectionsByDay,
    required this.topProducers,
  });

  factory DashboardStats.empty() {
    return DashboardStats(
      totalCollections: 0,
      totalVolume: 0,
      pendingCollections: 0,
      rejectedCollections: 0,
      averageTemperature: 0,
      averagePh: 0,
      samplesCollected: 0,
      collectionsByDay: [],
      topProducers: [],
    );
  }
}

/// Coletas agrupadas por dia para o gráfico
class CollectionByDay {
  final DateTime date;
  final int count;
  final double volume;

  CollectionByDay({
    required this.date,
    required this.count,
    required this.volume,
  });
}

/// Top produtores por volume
class CollectionByProducer {
  final String producerId;
  final String producerName;
  final double totalVolume;
  final int collectionCount;

  CollectionByProducer({
    required this.producerId,
    required this.producerName,
    required this.totalVolume,
    required this.collectionCount,
  });
}

/// Informações resumidas para o card do usuário
class UserSummary {
  final String greeting;
  final String subtitle;
  final int todayCollections;
  final double todayVolume;

  UserSummary({
    required this.greeting,
    required this.subtitle,
    required this.todayCollections,
    required this.todayVolume,
  });
}

