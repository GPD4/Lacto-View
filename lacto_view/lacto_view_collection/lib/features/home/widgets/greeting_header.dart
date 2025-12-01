import 'package:flutter/material.dart';
import '../../auth/model/user_model.dart';

/// Header com saudação e informações do usuário
class GreetingHeader extends StatelessWidget {
  final String greeting;
  final String subtitle;
  final UserRole role;
  final String? profileImg;
  final VoidCallback? onProfileTap;

  const GreetingHeader({
    super.key,
    required this.greeting,
    required this.subtitle,
    required this.role,
    this.profileImg,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getRoleColor(role),
            _getRoleColor(role).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getRoleColor(role).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Informações
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge do tipo de usuário
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getRoleIcon(role),
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getRoleName(role),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Saudação
                Text(
                  greeting,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                // Subtítulo
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Avatar
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: profileImg != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        profileImg!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                      ),
                    )
                  : _buildDefaultAvatar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Icon(
      _getRoleIcon(role),
      size: 30,
      color: Colors.white,
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.producer:
        return const Color(0xFF2E7D32); // Verde
      case UserRole.collector:
        return const Color(0xFF1565C0); // Azul
      case UserRole.admin:
        return const Color(0xFF6A1B9A); // Roxo
      default:
        return Colors.grey[700]!;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.producer:
        return Icons.agriculture_rounded;
      case UserRole.collector:
        return Icons.local_shipping_rounded;
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.producer:
        return 'Produtor';
      case UserRole.collector:
        return 'Coletor';
      case UserRole.admin:
        return 'Administrador';
      default:
        return 'Usuário';
    }
  }
}

