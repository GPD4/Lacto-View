import 'dart:async';
import 'package:flutter/material.dart';
import '../model/person_model.dart';
import '../service/service_person.dart';

class PersonViewModel extends ChangeNotifier {
  // O ViewModel DEPENDE do Service
  final PersonService _personService;

  // Construtor
  PersonViewModel(this._personService);

  // --- GERENCIAMENTO DE ESTADO ---
  bool _isLoading = false;
  String? _errorMessage;

  // Getters públicos para a View poder ler o estado
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- AÇÃO PRINCIPAL ---

  /// Função que a View irá chamar para salvar um novo usuário
  Future<bool> savePerson({
    required String name,
    required String cpfCnpj,
    required String cadpro,
    required String email,
    required String telefone,
    required String password,
    required String role,
    required bool isActive,
  }) async {
    // 1. Inicia o estado de carregamento
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notifica a View que o estado mudou

    // 2. Criar o objeto Person (Lógica movida para cá)
    final now = DateTime.now();
    Person newPerson = Person(
      name: name,
      cpfCnpj: cpfCnpj,
      email: email,
      cadpro: cadpro,
      telefone: telefone,
      password: password,
      role: role,
      isActive: isActive,
      profileImg: "assets/images/default_profile.png", // Valor padrão
      createdAt: now,
      updatedAt: now,
    );

    // 3. Chamar o Service
    bool success = await _personService.createPerson(newPerson);

    // 4. Atualizar o estado final
    _isLoading = false;
    if (success) {
      // Sucesso
    } else {
      _errorMessage = "Falha ao cadastrar. Tente novamente.";
    }

    notifyListeners(); // Notifica a View sobre o fim do carregamento
    return success;
  }
}
