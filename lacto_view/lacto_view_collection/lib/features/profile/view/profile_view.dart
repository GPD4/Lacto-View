import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// 1. IMPORT O SEU FORMULÁRIO REAL
import '../../profile/view/form_person_view.dart';
import '../../profile/view/form_property_view.dart';
import '../../profile/view/property_search_view.dart';

// 2. IMPORTE SEU NOVO WIDGET DE BOTÃO
import '../../profile/view_model/menu_profile_button.dart'; // <-- Ajuste o caminho se necessário

// 3. IMPORTE O AUTH VIEW MODEL E USER MODEL
import '../../auth/view_model/auth_view_model.dart';
import '../../auth/model/user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, _) {
        final userRole = authViewModel.currentUser?.role ?? UserRole.user;
        final userName = authViewModel.currentUser?.name ?? 'Usuário';
        
        // Verifica se o usuário é admin para mostrar módulos de gerenciamento
        final bool isAdmin = userRole == UserRole.admin;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Perfil',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green[800],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header com informações do usuário
                Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.green[800],
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getRoleColor(userRole),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getRoleLabel(userRole),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Módulos de gerenciamento (apenas para Admin)
                if (isAdmin) ...[
                  ArrowMenuButton(
                    text: 'Gerenciar Usuários',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => FormPersonView()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  ArrowMenuButton(
                    text: 'Gerenciar Propriedades',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => FormPropertyView()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  ArrowMenuButton(
                    text: 'Consultar Propriedades',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => PropertySearchView()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],

                // Módulos disponíveis para todos os usuários
                ArrowMenuButton(
                  text: 'Configurações',
                  onPressed: () {
                    // TODO: Implementar tela de configurações
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Configurações em desenvolvimento'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                ArrowMenuButton(
                  text: 'Notificações',
                  onPressed: () {
                    // TODO: Implementar tela de notificações
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notificações em desenvolvimento'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                ArrowMenuButton(
                  text: 'Sair - Logoff',
                  onPressed: () {
                    _showLogoutConfirmation(context, authViewModel);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Retorna a cor do badge baseado na role
  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red[700]!;
      case UserRole.producer:
        return Colors.blue[700]!;
      case UserRole.collector:
        return Colors.orange[700]!;
      default:
        return Colors.grey[600]!;
    }
  }

  /// Retorna o label da role em português
  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.producer:
        return 'Produtor';
      case UserRole.collector:
        return 'Coletor';
      default:
        return 'Usuário';
    }
  }

  /// Exibe diálogo de confirmação de logout
  void _showLogoutConfirmation(BuildContext context, AuthViewModel authViewModel) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Logout'),
          content: const Text('Deseja realmente sair da aplicação?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Fecha o diálogo
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Fecha o diálogo
                authViewModel.logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );
  }
}
