import 'dart:async';
import 'package:flutter/material.dart';
import '../model/property_model.dart';
import '../service/service_property.dart';

class PropertyViewModel extends ChangeNotifier {
  final PropertyService _service;
  PropertyViewModel(this._service);

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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

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
    final success = await _service.createProperty(property: newProperty);

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

  Future<List<Property>> search(String query) async {
    _setLoading(true);
    try {
      final results = await _service.searchProperties(query);
      _setLoading(false);
      return results;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return [];
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners(); // Notifica a View para atualizar a tela (loading spinner)
  }
}
