// lib/views/main_screen.dart

import 'package:flutter/material.dart';
import '../widgets/nav_bar.dart';
import 'main_screens.dart';
import 'views_collection.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  //Telas a serem exibidas
  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    MilkCollectionFormView(), //Formulario de coleta/rejeiçao
    SearchScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
