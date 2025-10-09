// lib/views/main_screens.dart

import 'package:flutter/material.dart';

// Tela de Início (Home)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Início')),
      body: const Center(
        child: Text('Conteúdo da Home', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

// Tela para Adicionar Coleta (aqui você pode chamar a MilkCollectionFormView)
class AddCollectionScreen extends StatelessWidget {
  const AddCollectionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // Exemplo: Você pode navegar para seu formulário a partir daqui
    // ou incorporá-lo diretamente se fizer sentido.
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Coleta')),
      body: const Center(
        child: Text('Conteúdo de Adicionar', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

// Tela de Busca
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar')),
      body: const Center(
        child: Text('Conteúdo da Busca', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

// Tela de Perfil
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: const Center(
        child: Text('Conteúdo do Perfil', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
