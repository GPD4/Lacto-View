import 'dart:async';
import 'package:flutter/material.dart';
import '../model/model_collection.dart';
import '../model/producer_property_model.dart';
import '../service/service_collection.dart';

enum ViewState { idle, loading, success, error }

class MilkCollectionViewModel extends ChangeNotifier {
  final _service = MilkCollectionService();

  // Estado da lista principal
  List<MilkCollection> _collections = [];
  List<MilkCollection> get collections => _collections;

  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Modo de busca atual
  SearchMode _searchMode = SearchMode.property;
  SearchMode get searchMode => _searchMode;

  // Estado da busca
  List<ProducerProperty> _searchResults = [];
  List<ProducerProperty> get searchResults => _searchResults;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  String _searchError = '';
  String get searchError => _searchError;

  Timer? _debounce;

  /// Altera o modo de busca (produtor ou propriedade)
  void setSearchMode(SearchMode mode) {
    if (_searchMode != mode) {
      _searchMode = mode;
      _searchResults = [];
      _searchError = '';
      notifyListeners();
    }
  }

  /// Busca baseada no modo atual (produtor ou propriedade)
  Future<void> search(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (query.isEmpty || query.length < 2) {
        _searchResults = [];
        _isSearching = false;
        notifyListeners();
        return;
      }

      _isSearching = true;
      _searchError = '';
      notifyListeners();

      try {
        if (_searchMode == SearchMode.producer) {
          _searchResults = await _service.searchProducers(query);
        } else {
          _searchResults = await _service.searchProperties(query);
        }
      } catch (e) {
        _searchError = e.toString();
        _searchResults = [];
      } finally {
        _isSearching = false;
        notifyListeners();
      }
    });
  }

  /// Limpa os resultados da busca
  void clearSearchResults() {
    _searchResults = [];
    _searchError = '';
    notifyListeners();
  }

  void _setState(ViewState state) {
    _state = state;
    notifyListeners();
  }

  /// Busca coletas do backend
  Future<void> fetchCollections(String token) async {
    _setState(ViewState.loading);
    try {
      _collections = await _service.getMilkCollections(token);
      _setState(ViewState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ViewState.error);
    }
  }

  /// Adiciona uma nova coleta ao backend
  Future<bool> addCollection(String token, MilkCollection newCollection) async {
    _setState(ViewState.loading);
    try {
      await _service.createCollection(token, newCollection);
      await fetchCollections(token);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ViewState.error);
      return false;
    }
  }

  /// Deleta uma coleta do backend
  Future<bool> deleteCollection(String token, String id) async {
    _setState(ViewState.loading);
    try {
      await _service.deleteCollection(token, id);
      await fetchCollections(token);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ViewState.error);
      return false;
    }
  }

  /// Limpa mensagem de erro
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
