import 'package:flutter/material.dart';
import '../../auth/model/user_model.dart';

/// Widget de ações rápidas baseadas no perfil
class QuickActions extends StatelessWidget {
  final UserRole role;
  final VoidCallback? onCollect;
  final VoidCallback? onSearch;
  final VoidCallback? onManageUsers;
  final VoidCallback? onManageProperties;

  const QuickActions({
    super.key,
    required this.role,
    this.onCollect,
    this.onSearch,
    this.onManageUsers,
    this.onManageProperties,
  });

  @override
  Widget build(BuildContext context) {
    final actions = _getActionsForRole(role);

    if (actions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Ações Rápidas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: actions.map((action) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _ActionButton(
                  icon: action.icon,
                  label: action.label,
                  color: action.color,
                  onTap: action.onTap,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  List<_ActionData> _getActionsForRole(UserRole role) {
    switch (role) {
      case UserRole.producer:
        return [
          _ActionData(
            icon: Icons.search_rounded,
            label: 'Ver Coletas',
            color: Colors.green[700]!,
            onTap: onSearch,
          ),
          _ActionData(
            icon: Icons.history_rounded,
            label: 'Histórico',
            color: Colors.blue[700]!,
            onTap: onSearch,
          ),
        ];
      case UserRole.collector:
        return [
          _ActionData(
            icon: Icons.add_circle_rounded,
            label: 'Nova Coleta',
            color: Colors.green[700]!,
            onTap: onCollect,
          ),
          _ActionData(
            icon: Icons.route_rounded,
            label: 'Rota do Dia',
            color: Colors.orange[700]!,
            onTap: null, // Feature futura
          ),
        ];
      case UserRole.admin:
        return [
          _ActionData(
            icon: Icons.add_circle_rounded,
            label: 'Nova Coleta',
            color: Colors.green[700]!,
            onTap: onCollect,
          ),
          _ActionData(
            icon: Icons.search_rounded,
            label: 'Buscar',
            color: Colors.blue[700]!,
            onTap: onSearch,
          ),
          _ActionData(
            icon: Icons.people_rounded,
            label: 'Usuários',
            color: Colors.purple[700]!,
            onTap: onManageUsers,
          ),
          _ActionData(
            icon: Icons.home_work_rounded,
            label: 'Propriedades',
            color: Colors.teal[700]!,
            onTap: onManageProperties,
          ),
        ];
      default:
        return [];
    }
  }
}

class _ActionData {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  _ActionData({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey[100] : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDisabled ? Colors.grey[300]! : color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDisabled ? Colors.grey[300] : color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDisabled ? Colors.grey[500] : color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isDisabled ? Colors.grey[500] : color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

