import 'package:flutter/material.dart';

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
