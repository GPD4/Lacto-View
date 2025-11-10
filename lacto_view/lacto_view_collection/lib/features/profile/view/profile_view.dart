import 'package:flutter/material.dart';
import '../../profile/view/form_person_view.dart';

// Tela de Perfil
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Usuário')),

      // 2. SUBSTITUA O BODY PELO SEU WIDGET DE FORMULÁRIO
      body: FormPersonView(),
    );
  }
}
