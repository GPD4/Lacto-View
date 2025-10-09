// lib/widgets/nav_bar.dart

import 'package:flutter/material.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Precisamos saber o tamanho da tela para calcular a posição da linha
    final screenWidth = MediaQuery.of(context).size.width;
    const double numItems = 4;
    final double itemWidth = screenWidth / numItems;
    final double indicatorWidth =
        itemWidth * 0.5; // A linha terá 50% da largura do item

    final indicatorColor = Colors.green[900]; // Cor do indicador

    return Stack(
      children: [
        // O BottomNavigationBar original fica no fundo da Stack
        BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: indicatorColor,
          unselectedItemColor: Colors.grey[600],
          selectedFontSize: 14.0,
          unselectedFontSize: 12.0,
          // Remove a borda superior padrão para um visual mais limpo
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline, size: 30),
              activeIcon: Icon(Icons.add_circle, size: 30),
              label: 'Coletar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Buscar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),

        // 2. A linha indicadora animada que fica sobre a barra de navegação
        AnimatedPositioned(
          duration: const Duration(milliseconds: 180), // Duração da animação
          curve: Curves.easeInOut, // Tipo de animação
          top: 0, // Posiciona a linha no topo da Stack
          // Calcula a posição 'left' para centralizar a linha sobre o item ativo
          left: (itemWidth * currentIndex) + (itemWidth - indicatorWidth) / 2,
          child: Container(
            width: indicatorWidth,
            height: 3.0, // Espessura da linha
            decoration: BoxDecoration(
              color: indicatorColor,
              borderRadius: const BorderRadius.all(Radius.circular(2)),
            ),
          ),
        ),
      ],
    );
  }
}
