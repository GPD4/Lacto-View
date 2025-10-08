import 'dart:async';
import 'package:flutter/material.dart';
import '../models/model.dart';
import '../services/services.dart';

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

  // Estado da busca
  List<Producer> _searchResults = [];
  List<Producer> get searchResults => _searchResults;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  String _searchError = '';
  String get searchError => _searchError;

  Timer? _debounce;

  Future<void> searchProducers(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        _searchResults = [];
        _isSearching = false;
        notifyListeners();
        return;
      }

      _isSearching = true;
      _searchError = '';
      notifyListeners();

      try {
        // ==========================================================
        // CORREÇÃO APLICADA AQUI
        // Removemos a lista fixa e chamamos o serviço de verdade.
        // ==========================================================
        _searchResults = await _service.searchProducers(query);
      } catch (e) {
        _searchError = e.toString();
      } finally {
        _isSearching = false;
        notifyListeners();
      }
    });
  }

  void _setState(ViewState state) {
    _state = state;
    notifyListeners();
  }

  Future<void> fetchCollections() async {
    _setState(ViewState.loading);
    try {
      _collections = await _service.getMilkCollections();
      _setState(ViewState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ViewState.error);
    }
  }

  Future<void> addCollection(MilkCollection newCollection) async {
    _setState(ViewState.loading);
    try {
      await _service.createCollection(newCollection);
      await fetchCollections();
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ViewState.error);
    }
  }
}
