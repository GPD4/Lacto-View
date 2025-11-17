import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/user_model.dart';
import 'i_auth_service.dart';

/// Serviço de autenticação MOCK para testes e desenvolvimento
/// Use este serviço quando não tiver acesso ao Firebase
class AuthServiceMock implements IAuthService {
  // Usuários mockados para teste
  final List<Map<String, String>> _mockUsers = [
    {
      'email': 'admin@lactoview.com',
      'password': '123456',
      'name': 'Administrador',
      'role': 'admin',
    },
    {
      'email': 'coletor@lactoview.com',
      'password': '123456',
      'name': 'José Silva',
      'role': 'coletor',
    },
    {
      'email': 'produtor@lactoview.com',
      'password': '123456',
      'name': 'Maria Santos',
      'role': 'produtor',
    },
  ];

  /// Realiza login mock
  Future<UserAuth?> login(String email, String password) async {
    try {
      // Simula delay de rede
      await Future.delayed(const Duration(seconds: 1));

      // Busca usuário mockado
      final mockUser = _mockUsers.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
        orElse: () => {},
      );

      if (mockUser.isEmpty) {
        throw Exception('Email ou senha incorretos');
      }

      // Cria token mock
      final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';

      final userAuth = UserAuth(
        id: 'mock_id_${mockUser['email']}',
        name: mockUser['name']!,
        email: mockUser['email']!,
        role: mockUser['role']!,
        profileImg: null,
        token: token,
      );

      // Salva localmente
      await _saveUserLocally(userAuth);

      return userAuth;
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  /// Realiza logout
  Future<void> logout() async {
    try {
      await _clearUserLocally();
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }

  /// Verifica se existe um usuário logado
  Future<UserAuth?> getCurrentUser() async {
    try {
      // Em modo mock, não mantém sessão - sempre precisa fazer login
      // Para manter sessão, descomente a linha abaixo e comente o return null
      // return await _getUserLocally();
      return null;
    } catch (e) {
      print('Erro ao obter usuário atual: $e');
      return null;
    }
  }

  /// Salva dados do usuário localmente
  Future<void> _saveUserLocally(UserAuth user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String userJson = jsonEncode(user.toJson());
      await prefs.setString('current_user', userJson);
    } catch (e) {
      print('Erro ao salvar usuário localmente: $e');
    }
  }

  /// Recupera dados do usuário do cache local
  Future<UserAuth?> _getUserLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userJson = prefs.getString('current_user');
      if (userJson != null) {
        final Map<String, dynamic> userMap = jsonDecode(userJson);
        return UserAuth.fromJson(userMap);
      }
      return null;
    } catch (e) {
      print('Erro ao recuperar usuário do cache: $e');
      return null;
    }
  }

  /// Remove dados do usuário do cache local
  Future<void> _clearUserLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');
    } catch (e) {
      print('Erro ao limpar cache do usuário: $e');
    }
  }

  /// Simula recuperação de senha
  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final userExists = _mockUsers.any((user) => user['email'] == email);
    
    if (!userExists) {
      throw Exception('Email não encontrado');
    }
    
    // Simula envio de email
    print('Email de recuperação enviado para: $email');
  }
}
