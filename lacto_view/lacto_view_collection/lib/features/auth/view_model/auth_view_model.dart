import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../service/i_auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final IAuthService _authService;

  AuthViewModel(this._authService);

  // --- ESTADO ---
  bool _isLoading = false;
  String? _errorMessage;
  UserAuth? _currentUser;

  // --- GETTERS ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserAuth? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  /// Inicializa verificando se existe usuário logado
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getCurrentUser();
      // Se estamos em desenvolvimento, você pode comentar a linha acima e 
      // descomentar a linha abaixo para sempre começar no login:
      // _currentUser = null;
    } catch (e) {
      print('Erro ao inicializar auth: $e');
      _currentUser = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Realiza login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.login(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      _currentUser = null;
      notifyListeners();
      return false;
    }
  }

  /// Realiza logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Recupera senha
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Limpa mensagem de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
