import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// 1. IMPORT O SEU FORMULÁRIO REAL
import '../../profile/view/form_person_view.dart';
import '../../profile/view/form_property_view.dart';

// 2. IMPORTE SEU NOVO WIDGET DE BOTÃO
import '../../profile/view_model/menu_profile_button.dart'; // <-- Ajuste o caminho se necessário

// 3. IMPORTE O AUTH VIEW MODEL
import '../../auth/view_model/auth_view_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
              text: 'Configurações',
              onPressed: () {
                /*Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => FormPropertyView()),
                );*/
              },
            ),
            const SizedBox(height: 12),
            ArrowMenuButton(
              text: 'Notificações',
              onPressed: () {
                /*Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => FormPropertyView()),
                );*/
              },
            ),
            const SizedBox(height: 12),
            ArrowMenuButton(
              text: 'Sair - Logoff',
              onPressed: () {
                // Importar o AuthViewModel
                final authViewModel = context.read<AuthViewModel>();
                authViewModel.logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
