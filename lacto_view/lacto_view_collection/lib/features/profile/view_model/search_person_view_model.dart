import 'package:flutter/material.dart';
import '../service/service_person_search.dart';
import '../model/person_model.dart';

class SearchPersonViewModel extends ChangeNotifier {
  final ServicePersonSearch _servicePersonSearch;
  SearchPersonViewModel(this._servicePersonSearch);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Person> _results = [];
  List<Person> get results => _results;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  /// Busca pessoas no backend
  Future<void> search(String query, {int? limit}) async {
    if (query.isEmpty) {
      _results = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      print('ViewModel: Buscando no back-end: "$query" com limite: $limit');

      final searchResults = await _servicePersonSearch.searchPersons(
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
