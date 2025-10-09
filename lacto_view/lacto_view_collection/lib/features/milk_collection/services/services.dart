import '../models/model.dart';

class Producer {
  final int id;
  final String name;
  final String propertyName;
  Producer({required this.id, required this.name, required this.propertyName});
}

class MilkCollectionService {
  Future<void> createCollection(MilkCollection collection) async {
    print('SALVANDO NOVA COLETA NO BACKEND...');
    print('Dados: ${collection.toJson()}');
    await Future.delayed(const Duration(seconds: 1));
    print('Coleta Salva com SUCESSO!');
  }

  Future<List<MilkCollection>> getMilkCollections() async {
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  Future<void> deleteCollection(int id) async {
    // Simula uma chamada de rede para deletar os dados
    print('DELETANDO COLETA COM ID: $id NO BACKEND...');
    await Future.delayed(const Duration(seconds: 1));
    print('COLETA DELETADA COM SUCESSO!');
    //await _dio.delete('http://seu-backend.com/api/collections/$id');
  }

  Future<List<Producer>> searchProducers(String query) async {
    // ... seu código de busca aqui (já está correto) ...
    print('SERVICE: Buscando produtores com a query: "$query"');
    await Future.delayed(const Duration(milliseconds: 300));

    final allProducers = [
      Producer(
        id: 101,
        name: 'Zakk Wylde',
        propertyName: 'Black Label Society',
      ),
      Producer(id: 132, name: 'Dimebag Darrell', propertyName: 'Pantera'),
      Producer(id: 153, name: 'Ozzy Osbourne', propertyName: 'Black Sabbath'),
      Producer(id: 164, name: 'James HetField', propertyName: 'Metallica'),
      Producer(id: 135, name: 'Layne Staley', propertyName: 'Alice in Chains'),
    ];

    if (query.isEmpty) {
      return [];
    }

    final lowerCaseQuery = query.toLowerCase();

    final results = allProducers.where((producer) {
      final lowerCaseName = producer.name.toLowerCase();

      //Logica do Filtro
      //1 - Verifica se o nome completo começa com a busca
      final nameStartsWith = lowerCaseName.startsWith(lowerCaseQuery);
      //2 - Quebra o nome em partes e verifica se alguma parte começa com a busca
      final anyPartStartsWith = lowerCaseName
          .split(' ')
          .any((part) => part.startsWith(lowerCaseQuery));
      //3 - Verifica se o ID contém a busca
      final idContains = producer.id.toString().contains(lowerCaseQuery);

      return nameStartsWith || anyPartStartsWith || idContains;
    }).toList();

    return results.take(5).toList();
  }
}
