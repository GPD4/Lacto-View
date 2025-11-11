import 'package:flutter/material.dart';

class SearchPropertyViewModel extends ChangeNotifier {
  //Injetar o property_service AQUI!!!

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  //No futuro aqui será a lista de propriedades (List<Property>)
  List<String> _results = [];
  List<String> get results => _results;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  //A view chama a função
  Future<void> search(String query) async {
    if (query.isEmpty) {
      _results = [];
      notifyListeners();
      return;
    }

    //1 . Estado de carregamento
    _is
  }
}
