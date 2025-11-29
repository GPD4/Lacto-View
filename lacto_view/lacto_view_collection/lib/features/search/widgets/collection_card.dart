import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../milk_collection/model/model_collection.dart';

/// Card para exibir uma coleta na lista de resultados
class CollectionCard extends StatelessWidget {
  final MilkCollection collection;
  final VoidCallback? onTap;

  const CollectionCard({
    super.key,
    required this.collection,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: collection.rejection 
              ? Colors.red.withOpacity(0.3) 
              : Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com status e data
              Row(
                children: [
                  // Badge de status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: collection.rejection 
                          ? Colors.red[50] 
                          : Colors.green[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: collection.rejection 
                            ? Colors.red[200]! 
                            : Colors.green[200]!,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          collection.rejection 
                              ? Icons.cancel 
                              : Icons.check_circle,
                          size: 14,
                          color: collection.rejection 
                              ? Colors.red[700] 
                              : Colors.green[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          collection.rejection ? 'Rejeitada' : 'Aprovada',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: collection.rejection 
                                ? Colors.red[700] 
                                : Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Data e hora
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        dateFormat.format(collection.createdAt),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        timeFormat.format(collection.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Produtor
              Row(
                children: [
                  Icon(Icons.person, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      collection.producerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Propriedade
              Row(
                children: [
                  Icon(Icons.home, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      collection.propertyName,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Divider
              Divider(color: Colors.grey[200], height: 1),
              const SizedBox(height: 12),

              // Dados da coleta
              Row(
                children: [
                  // Volume
                  _buildDataChip(
                    icon: Icons.water_drop,
                    label: '${collection.volumeLt}L',
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  // Temperatura
                  _buildDataChip(
                    icon: Icons.thermostat,
                    label: '${collection.temperature}°C',
                    color: _getTemperatureColor(collection.temperature),
                  ),
                  const SizedBox(width: 8),
                  // pH
                  _buildDataChip(
                    icon: Icons.science,
                    label: 'pH ${collection.ph}',
                    color: Colors.purple,
                  ),
                  const Spacer(),
                  // Coletor
                  Row(
                    children: [
                      Icon(
                        Icons.local_shipping,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getShortName(collection.collectorName),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Motivo da rejeição (se houver)
              if (collection.rejection && collection.rejectionReason.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, size: 16, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          collection.rejectionReason,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTemperatureColor(double temp) {
    if (temp < 4) return Colors.blue;
    if (temp <= 7) return Colors.green;
    if (temp <= 10) return Colors.orange;
    return Colors.red;
  }

  String _getShortName(String fullName) {
    final parts = fullName.split(' ');
    if (parts.length > 1) {
      return '${parts.first} ${parts.last[0]}.';
    }
    return fullName;
  }
}

