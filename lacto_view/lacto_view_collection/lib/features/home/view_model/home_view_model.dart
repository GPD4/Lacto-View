import 'package:flutter/material.dart';
import '../model/dashboard_model.dart';
import '../service/home_service.dart';
import '../../auth/model/user_model.dart';

/// ViewModel para a tela Home
class HomeViewModel extends ChangeNotifier {
  final HomeService _homeService;

  HomeViewModel(this._homeService);

  // Estado
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  DashboardStats? _stats;
  UserSummary? _summary;
  DateTime _selectedPeriodStart = DateTime.now().subtract(const Duration(days: 30));
  DateTime _selectedPeriodEnd = DateTime.now();

  // Getters
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  DashboardStats? get stats => _stats;
  UserSummary? get summary => _summary;
  DateTime get selectedPeriodStart => _selectedPeriodStart;
  DateTime get selectedPeriodEnd => _selectedPeriodEnd;

  /// Carrega todos os dados do dashboard
  Future<void> loadDashboard({
    required UserAuth user,
  }) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      // Determina os filtros baseados na role do usuário
      String? producerId;
      String? collectorId;

      switch (user.role) {
        case UserRole.producer:
          producerId = user.id;
          break;
        case UserRole.collector:
          collectorId = user.id;
          break;
        case UserRole.admin:
          // Admin vê todos os dados
          break;
        default:
          break;
      }

      // Carrega os dados em paralelo
      final results = await Future.wait([
        _homeService.getDashboardStats(
          token: user.token,
          producerId: producerId,
          collectorId: collectorId,
          startDate: _selectedPeriodStart,
          endDate: _selectedPeriodEnd,
        ),
        _homeService.getTodaySummary(
          token: user.token,
          userName: user.name,
          producerId: producerId,
          collectorId: collectorId,
        ),
      ]);

      _stats = results[0] as DashboardStats;
      _summary = results[1] as UserSummary;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Atualiza o período selecionado e recarrega os dados
  Future<void> changePeriod({
    required DateTime start,
    required DateTime end,
    required UserAuth user,
  }) async {
    _selectedPeriodStart = start;
    _selectedPeriodEnd = end;
    await loadDashboard(user: user);
  }

  /// Limpa os dados
  void clear() {
    _stats = null;
    _summary = null;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
  }
}

