import '../model/person_model.dart';

// service/person_service.dart

class PersonService {
  /// Salva uma nova pessoa no backend.
  /// No futuro, é aqui que você colocará seu código http.post
  /// para se comunicar com seu backend Dart Frog.
  Future<bool> createPerson(Person person) async {
    try {
      // --- INÍCIO: LÓGICA DO BACKEND (EX: Dart Frog) ---
      print("Chamando o backend para salvar:");
      print(person.toJson());

      // Simula um atraso de rede de 2 segundos
      await Future.delayed(Duration(seconds: 2));

      // Simula uma resposta de sucesso do backend
      print("Backend respondeu: SUCESSO");
      // --- FIM: LÓGICA DO BACKEND ---

      return true; // Retorna true em caso de sucesso
    } catch (e) {
      print("Erro ao salvar pessoa: $e");
      return false; // Retorna false em caso de erro
    }
  }

  // Aqui você também teria outros métodos, como:
  // Future<List<Person>> getPersons() async { ... }
  // Future<Person> updatePerson(String id, Person person) async { ... }
  // Future<void> deletePerson(String id) async { ... }
}
