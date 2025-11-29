import 'package:flutter/material.dart';
import '../service/service_property_search.dart';
import '../model/property_model.dart';

class SearchPropertyViewModel extends ChangeNotifier {
  final ServicePropertySearch _servicePropertySearch;
  SearchPropertyViewModel(this._servicePropertySearch);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  //No futuro aqui será a lista de propriedades (List<Property>)
  List<Property> _results = [];
  List<Property> get results => _results;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  //A view chama a função
  Future<void> search(String query, {int? limit}) async {
    if (query.isEmpty) {
      _results = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    //Chamada ao Back-End(frog)
    try {
      print('ViewModel: Buscando no back-end: "$query" com limite: $limit');
      final searchResults = await _servicePropertySearch.searchProperties(
        query,
        limit: limit,
      );

      _results = searchResults;
      _errorMessage = '';
    } catch (e) {
      print('ViewModel: Erro ao buscar: $e');
      _errorMessage = e.toString();
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
