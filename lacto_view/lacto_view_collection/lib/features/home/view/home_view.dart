import 'package:flutter/material.dart';
import '../../profile/view/form_person_view.dart';

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
