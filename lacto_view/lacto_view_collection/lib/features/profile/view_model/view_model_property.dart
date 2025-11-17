import 'dart:async';
import 'package:flutter/material.dart';
import '../model/property_model.dart';
import '../service/service_property_search.dart';

class PropertyViewModel extends ChangeNotifier {
  final ServicePropertySearch _propertyService;

  PropertyViewModel(this._propertyService);

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- AÇÃO PRINCIPAL ---

  /// Função que a View irá chamar para salvar um novo
  Future<bool> saveProperty({
    required String name,
    required String cep,
    required String street,
    required String city,
    required String state,
    required int tanksQtd,
    required bool isActive,
  }) async {
    // 1. Inicia o estado de carregamento
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notifica a View que o estado mudou

    // 2. Criar o objeto Person (Lógica movida para cá)
    final now = DateTime.now();
    Property newProperty = Property(
      name: name,
      cep: cep,
      street: street,
      city: city,
      state: state,
      tanksQtd: tanksQtd,
      isActive: isActive,
      createdAt: now,
      updatedAt: now,
    );

    // 3. Chamar o Service
    bool success = await _propertyService.createProperty(newProperty);

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
