import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/view_model/auth_view_model.dart';
import '../../auth/model/user_model.dart';
import '../../milk_collection/view_models/navigation_controller.dart';
import '../../profile/view/form_person_view.dart';
import '../../profile/view/form_property_view.dart';
import '../model/dashboard_model.dart';
import '../service/home_service.dart';
import '../view_model/home_view_model.dart';
import '../widgets/greeting_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/volume_chart.dart';
import '../widgets/producer_ranking.dart';
import '../widgets/quick_actions.dart';

/// Tela de Início (Home) com Dashboard
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeViewModel? _viewModel;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel == null) {
      _viewModel = HomeViewModel(context.read<HomeService>());
    }
    if (!_initialized) {
      _loadData();
      _initialized = true;
    }
  }

  Future<void> _loadData() async {
    final authViewModel = context.read<AuthViewModel>();
    if (authViewModel.currentUser != null && _viewModel != null) {
      await _viewModel!.loadDashboard(user: authViewModel.currentUser!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return ChangeNotifierProvider.value(
      value: _viewModel!,
      child: Consumer2<AuthViewModel, HomeViewModel>(
        builder: (context, authViewModel, homeViewModel, _) {
          final user = authViewModel.currentUser;

          if (user == null) {
            return const Scaffold(
              body: Center(child: Text('Usuário não autenticado')),
            );
          }

    return Scaffold(
            backgroundColor: const Color(0xFFF5F7FA),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadData,
                color: _getRoleColor(user.role),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Header com saudação
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: GreetingHeader(
                          greeting: homeViewModel.summary?.greeting ??
                              'Olá, ${user.name}!',
                          subtitle: homeViewModel.summary?.subtitle ??
                              'Carregando...',
                          role: user.role,
                          profileImg: user.profileImg,
                        ),
                      ),
                    ),

                    // Ações rápidas
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: QuickActions(
                          role: user.role,
                          onCollect: () => _navigateToCollect(context, user.role),
                          onSearch: () => _navigateToSearch(context, user.role),
                          onManageUsers: () => _navigateToUsersManager(context),
                          onManageProperties: () => _navigateToPropertiesManager(context),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: 24),
                    ),

                    // Loading ou erro
                    if (homeViewModel.isLoading)
                      const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      )
                    else if (homeViewModel.hasError)
                      SliverToBoxAdapter(
                        child: _buildErrorWidget(homeViewModel),
                      )
                    else
                      // Dashboard baseado no perfil
                      ..._buildDashboardForRole(
                        user.role,
                        homeViewModel.stats ?? DashboardStats.empty(),
                      ),

                    // Espaçamento final
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildDashboardForRole(UserRole role, DashboardStats stats) {
    switch (role) {
      case UserRole.producer:
        return _buildProducerDashboard(stats);
      case UserRole.collector:
        return _buildCollectorDashboard(stats);
      case UserRole.admin:
        return _buildAdminDashboard(stats);
      default:
        return _buildDefaultDashboard(stats);
    }
  }

  /// Dashboard para PRODUTOR
  List<Widget> _buildProducerDashboard(DashboardStats stats) {
    return [
      // Título da seção
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.dashboard_rounded, color: Colors.green[700], size: 22),
              const SizedBox(width: 8),
              Text(
                'Minhas Estatísticas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),

      // Cards de estatísticas principais
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          delegate: SliverChildListDelegate([
            StatCard(
              title: 'Total Coletas',
              value: '${stats.totalCollections}',
              icon: Icons.inventory_2_rounded,
              color: Colors.green[700]!,
            ),
            StatCard(
              title: 'Volume Total',
              value: '${stats.totalVolume.toStringAsFixed(1)}L',
              icon: Icons.water_drop_rounded,
              color: Colors.blue[700]!,
            ),
            StatCard(
              title: 'Média Temp.',
              value: '${stats.averageTemperature.toStringAsFixed(1)}°C',
              icon: Icons.thermostat_rounded,
              color: Colors.orange[700]!,
            ),
            StatCard(
              title: 'Amostras',
              value: '${stats.samplesCollected}',
              subtitle: 'coletadas',
              icon: Icons.science_rounded,
              color: Colors.purple[700]!,
            ),
          ]),
        ),
      ),

      // Gráfico de volume
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: VolumeChart(
            data: stats.collectionsByDay,
            title: 'Volume dos Últimos 7 Dias',
          ),
        ),
      ),

      // Informações adicionais
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              CompactStatCard(
                label: 'Rejeitadas',
                value: '${stats.rejectedCollections}',
                icon: Icons.cancel_rounded,
                color: Colors.red[600]!,
              ),
              const SizedBox(height: 12),
              CompactStatCard(
                label: 'pH Médio',
                value: stats.averagePh.toStringAsFixed(2),
                icon: Icons.science_outlined,
                color: Colors.teal[600]!,
              ),
            ],
          ),
        ),
      ),
    ];
  }

  /// Dashboard para COLETOR
  List<Widget> _buildCollectorDashboard(DashboardStats stats) {
    return [
      // Título da seção
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.dashboard_rounded, color: Colors.blue[700], size: 22),
              const SizedBox(width: 8),
              Text(
                'Minhas Coletas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),

      // Cards de estatísticas principais
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          delegate: SliverChildListDelegate([
            StatCard(
              title: 'Coletas Realizadas',
              value: '${stats.totalCollections}',
              icon: Icons.check_circle_rounded,
              color: Colors.green[700]!,
            ),
            StatCard(
              title: 'Volume Coletado',
              value: '${stats.totalVolume.toStringAsFixed(1)}L',
              icon: Icons.water_drop_rounded,
              color: Colors.blue[700]!,
            ),
            StatCard(
              title: 'Pendentes',
              value: '${stats.pendingCollections}',
              icon: Icons.pending_rounded,
              color: Colors.orange[700]!,
            ),
            StatCard(
              title: 'Rejeitadas',
              value: '${stats.rejectedCollections}',
              icon: Icons.cancel_rounded,
              color: Colors.red[600]!,
            ),
          ]),
        ),
      ),

      // Gráfico de volume
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: VolumeChart(
            data: stats.collectionsByDay,
            title: 'Coletas dos Últimos 7 Dias',
          ),
        ),
      ),

      // Top produtores visitados
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ProducerRanking(
            producers: stats.topProducers,
            title: 'Produtores Mais Visitados',
          ),
        ),
      ),

      // Estatísticas técnicas
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CompactStatCard(
                label: 'Temperatura Média',
                value: '${stats.averageTemperature.toStringAsFixed(1)}°C',
                icon: Icons.thermostat_rounded,
                color: Colors.orange[600]!,
              ),
              const SizedBox(height: 12),
              CompactStatCard(
                label: 'Amostras Coletadas',
                value: '${stats.samplesCollected}',
                icon: Icons.science_rounded,
                color: Colors.purple[600]!,
              ),
            ],
          ),
        ),
      ),
    ];
  }

  /// Dashboard para ADMINISTRADOR
  List<Widget> _buildAdminDashboard(DashboardStats stats) {
    return [
      // Título da seção
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.dashboard_rounded, color: Colors.purple[700], size: 22),
              const SizedBox(width: 8),
              Text(
                'Visão Geral',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),

      // Cards de estatísticas principais
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          delegate: SliverChildListDelegate([
            StatCard(
              title: 'Total de Coletas',
              value: '${stats.totalCollections}',
              icon: Icons.inventory_2_rounded,
              color: Colors.purple[700]!,
            ),
            StatCard(
              title: 'Volume Total',
              value: '${stats.totalVolume.toStringAsFixed(1)}L',
              icon: Icons.water_drop_rounded,
              color: Colors.blue[700]!,
            ),
            StatCard(
              title: 'Pendentes',
              value: '${stats.pendingCollections}',
              icon: Icons.pending_rounded,
              color: Colors.orange[700]!,
            ),
            StatCard(
              title: 'Rejeitadas',
              value: '${stats.rejectedCollections}',
              icon: Icons.cancel_rounded,
              color: Colors.red[600]!,
            ),
          ]),
        ),
      ),

      // Gráfico de volume
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: VolumeChart(
            data: stats.collectionsByDay,
            title: 'Volume por Dia (Últimos 7 dias)',
          ),
        ),
      ),

      // Ranking de produtores
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ProducerRanking(
            producers: stats.topProducers,
            title: 'Top 5 Produtores',
          ),
        ),
      ),

      // Estatísticas técnicas
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.analytics_rounded,
                        color: Colors.teal,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Métricas Técnicas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _MetricItem(
                        label: 'Temp. Média',
                        value: '${stats.averageTemperature.toStringAsFixed(1)}°C',
                        icon: Icons.thermostat,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _MetricItem(
                        label: 'pH Médio',
                        value: stats.averagePh.toStringAsFixed(2),
                        icon: Icons.science,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _MetricItem(
                        label: 'Amostras',
                        value: '${stats.samplesCollected}',
                        icon: Icons.biotech,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _MetricItem(
                        label: 'Taxa Rejeição',
                        value: stats.totalCollections > 0
                            ? '${((stats.rejectedCollections / stats.totalCollections) * 100).toStringAsFixed(1)}%'
                            : '0%',
                        icon: Icons.trending_down,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  /// Dashboard padrão
  List<Widget> _buildDefaultDashboard(DashboardStats stats) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              StatCard(
                title: 'Total de Coletas',
                value: '${stats.totalCollections}',
                icon: Icons.inventory_2_rounded,
                color: Colors.grey[700]!,
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildErrorWidget(HomeViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar dados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage ?? 'Tente novamente',
              style: TextStyle(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.producer:
        return Colors.green[700]!;
      case UserRole.collector:
        return Colors.blue[700]!;
      case UserRole.admin:
        return Colors.purple[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  /// Navega para a tela de Nova Coleta
  void _navigateToCollect(BuildContext context, UserRole role) {
    final navigationController = context.read<NavigationController>();
    // Collector e Admin: índice 1 é Coletar
    if (role == UserRole.collector || role == UserRole.admin) {
      navigationController.navigateTo(1);
    }
  }

  /// Navega para a tela de Busca
  void _navigateToSearch(BuildContext context, UserRole role) {
    final navigationController = context.read<NavigationController>();
    switch (role) {
      case UserRole.producer:
        // Producer: índice 1 é Buscar
        navigationController.navigateTo(1);
        break;
      case UserRole.admin:
        // Admin: índice 2 é Buscar
        navigationController.navigateTo(2);
        break;
      default:
        break;
    }
  }

  /// Navega para a tela de Gerenciamento de Usuários
  void _navigateToUsersManager(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormPersonView(),
      ),
    );
  }

  /// Navega para a tela de Gerenciamento de Propriedades
  void _navigateToPropertiesManager(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormPropertyView(),
      ),
    );
  }
}

/// Widget auxiliar para métricas técnicas
class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
