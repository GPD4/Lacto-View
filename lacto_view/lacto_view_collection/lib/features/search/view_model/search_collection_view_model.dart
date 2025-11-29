import 'package:flutter/material.dart';
import '../../milk_collection/model/model_collection.dart';
import '../service/search_collection_service.dart';

/// ViewModel para gerenciar o estado da busca de coletas
class SearchCollectionViewModel extends ChangeNotifier {
  final SearchCollectionService _service;

  SearchCollectionViewModel(this._service);

  // Estado
  List<MilkCollection> _collections = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filtros
  SearchType _searchType = SearchType.producer;
  String _searchTerm = '';
  DateTime? _startDate;
  DateTime? _endDate;

  // Getters
  List<MilkCollection> get collections => _collections;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SearchType get searchType => _searchType;
  String get searchTerm => _searchTerm;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  
  bool get hasFilters => 
    _searchTerm.isNotEmpty || 
    _startDate != null || 
    _endDate != null;

  /// Define o tipo de busca
  void setSearchType(SearchType type) {
    _searchType = type;
    notifyListeners();
  }

  /// Define o termo de busca
  void setSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  /// Define a data inicial
  void setStartDate(DateTime? date) {
    _startDate = date;
    notifyListeners();
  }

  /// Define a data final
  void setEndDate(DateTime? date) {
    _endDate = date;
    notifyListeners();
  }

  /// Limpa todos os filtros
  void clearFilters() {
    _searchTerm = '';
    _startDate = null;
    _endDate = null;
    _searchType = SearchType.producer;
    _collections = [];
    _errorMessage = null;
    notifyListeners();
  }

  /// Realiza a busca de coletas
  Future<void> search({
    required String token,
    String? producerId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_searchTerm.isNotEmpty) {
        // Busca com termo
        _collections = await _service.searchCollections(
          token: token,
          searchType: _searchType,
          searchTerm: _searchTerm,
          startDate: _startDate,
          endDate: _endDate,
          producerId: producerId,
        );
      } else {
        // Busca todas (com filtro de data se houver)
        _collections = await _service.getAllCollections(
          token: token,
          producerId: producerId,
          startDate: _startDate,
          endDate: _endDate,
        );
      }
    } catch (e) {
      _errorMessage = 'Erro ao buscar coletas: ${e.toString()}';
      _collections = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Carrega coletas iniciais (histórico recente)
  Future<void> loadInitialCollections({
    required String token,
    String? producerId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _collections = await _service.getAllCollections(
        token: token,
        producerId: producerId,
        limit: 20,
      );
    } catch (e) {
      _errorMessage = 'Erro ao carregar coletas: ${e.toString()}';
      _collections = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}

