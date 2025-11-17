import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/user_model.dart';
import 'i_auth_service.dart';

class AuthService implements IAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthService() {
    // Desabilita a verificação de App para permitir login em emuladores
    _firebaseAuth.setSettings(appVerificationDisabledForTesting: true);
  }

  /// Realiza login com email e senha usando Firebase Authentication
  Future<UserAuth?> login(String email, String password) async {
    try {
      // Autentica com Firebase
      final UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Falha ao obter usuário do Firebase');
      }

      // Obtém o token de autenticação
      final String? token = await firebaseUser.getIdToken();
      if (token == null) {
        throw Exception('Falha ao obter token');
      }

      // Aqui você poderia fazer uma chamada ao backend Dart Frog
      // para buscar informações adicionais do usuário (name, role, etc.)
      // Por enquanto, vamos usar dados básicos do Firebase
      
      final userAuth = UserAuth(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'Usuário',
        email: firebaseUser.email ?? email,
        role: 'user', // Você pode buscar isso do Firestore ou backend
        profileImg: firebaseUser.photoURL,
        token: token,
      );

      // Salva os dados do usuário localmente
      await _saveUserLocally(userAuth);

      return userAuth;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  /// Realiza logout
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      await _clearUserLocally();
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }

  /// Verifica se existe um usuário logado
  Future<UserAuth?> getCurrentUser() async {
    try {
      final User? firebaseUser = _firebaseAuth.currentUser;
      
      if (firebaseUser != null) {
        // Tenta carregar do cache local primeiro
        final cachedUser = await _getUserLocally();
        if (cachedUser != null) {
          return cachedUser;
        }

        // Se não tem cache, cria do Firebase
        final String? token = await firebaseUser.getIdToken();
        return UserAuth(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'Usuário',
          email: firebaseUser.email ?? '',
          role: 'user',
          profileImg: firebaseUser.photoURL,
          token: token ?? '',
        );
      }

      return null;
    } catch (e) {
      print('Erro ao obter usuário atual: $e');
      return null;
    }
  }

  /// Salva dados do usuário localmente usando SharedPreferences
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

  /// Trata erros do Firebase Auth e retorna mensagens amigáveis
  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-disabled':
        return 'Usuário desabilitado';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde';
      case 'invalid-credential':
        return 'Credenciais inválidas';
      default:
        return 'Erro ao fazer login: ${e.message}';
    }
  }

  /// Recupera senha (envia email de redefinição)
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Erro ao recuperar senha: $e');
    }
  }
}
