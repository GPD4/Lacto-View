// lib/views/main_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/nav_bar.dart';
import '../../home/view/home_view.dart';
import '../../profile/view/profile_view.dart';
import '../../auth/view_model/auth_view_model.dart';
import '../../auth/model/user_model.dart';
import 'search_view.dart';
import 'views_collection.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  /// Retorna as telas disponíveis baseado na role do usuário
  List<Widget> _getScreensForRole(UserRole role) {
    switch (role) {
      case UserRole.producer:
        // Producer: Home, Search, Profile
        return const [
          HomeScreen(),
          SearchScreen(),
          ProfileScreen(),
        ];
      case UserRole.collector:
        // Collector: Home, Coletar, Profile
        return const [
          HomeScreen(),
          MilkCollectionFormView(),
          ProfileScreen(),
        ];
      case UserRole.admin:
        // Admin: Todos os módulos
        return const [
          HomeScreen(),
          MilkCollectionFormView(),
          SearchScreen(),
          ProfileScreen(),
        ];
      default:
        // User padrão: apenas Home e Profile
        return const [
          HomeScreen(),
          ProfileScreen(),
        ];
    }
  }

  /// Retorna os itens de navegação baseado na role do usuário
  List<NavItem> _getNavItemsForRole(UserRole role) {
    switch (role) {
      case UserRole.producer:
        // Producer: Home, Search, Profile
        return const [
          NavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Início',
          ),
          NavItem(
            icon: Icons.search_outlined,
            activeIcon: Icons.search,
            label: 'Buscar',
          ),
          NavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Perfil',
          ),
        ];
      case UserRole.collector:
        // Collector: Home, Coletar, Profile
        return const [
          NavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Início',
          ),
          NavItem(
            icon: Icons.add_circle_outline,
            activeIcon: Icons.add_circle,
            label: 'Coletar',
            iconSize: 30,
          ),
          NavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Perfil',
          ),
        ];
      case UserRole.admin:
        // Admin: Todos os módulos
        return const [
          NavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Início',
          ),
          NavItem(
            icon: Icons.add_circle_outline,
            activeIcon: Icons.add_circle,
            label: 'Coletar',
            iconSize: 30,
          ),
          NavItem(
            icon: Icons.search_outlined,
            activeIcon: Icons.search,
            label: 'Buscar',
          ),
          NavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Perfil',
          ),
        ];
      default:
        // User padrão: apenas Home e Profile
        return const [
          NavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Início',
          ),
          NavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Perfil',
          ),
        ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, _) {
        final userRole = authViewModel.currentUser?.role ?? UserRole.user;
        final screens = _getScreensForRole(userRole);
        final navItems = _getNavItemsForRole(userRole);

        // Garante que o índice selecionado não exceda o número de telas
        if (_selectedIndex >= screens.length) {
          _selectedIndex = 0;
        }

        return Scaffold(
          body: screens[_selectedIndex],
          bottomNavigationBar: AppBottomNavBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: navItems,
          ),
        );
      },
    );
  }
}
