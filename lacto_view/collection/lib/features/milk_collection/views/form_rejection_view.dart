// lib/views/form_rejection_view.dart
import '../views/form_collection_view.dart';
import 'package:flutter/material.dart';

class RejectionDataForm extends StatelessWidget {
  // Controladores para campos condicionais
  final TextEditingController volumeController;
  final TextEditingController temperatureController;
  final TextEditingController phController;

  final String? selectedRejectionReason;
  final List<String> rejectionReasons;
  final ValueChanged<String?> onReasonChanged;

  final VoidCallback onSave;
  final VoidCallback onGoBack;

  const RejectionDataForm({
    super.key,
    required this.volumeController,
    required this.temperatureController,
    required this.phController,
    required this.selectedRejectionReason,
    required this.rejectionReasons,
    required this.onReasonChanged,
    required this.onSave,
    required this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ButtonStyle(
      padding: MaterialStateProperty.all<EdgeInsets>(
        const EdgeInsets.symmetric(vertical: 12),
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
    );

    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: selectedRejectionReason,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          decoration: buildInputDecoration(
            context,
            labelText: 'Motivo da Rejeição',
            prefixIcon: Icons.warning_amber_rounded,
          ),
          items: rejectionReasons.map((String reason) {
            return DropdownMenuItem<String>(
              value: reason,
              child: Text(reason, overflow: TextOverflow.ellipsis, maxLines: 1),
            );
          }).toList(),
          onChanged: onReasonChanged,
          validator: (value) => value == null ? 'Campo obrigatório' : null,
        ),
        const SizedBox(height: 16),

        if (selectedRejectionReason == rejectionReasons[0])
          ..._buildMilkDataFieldsForRejection(context),

        const SizedBox(height: 32),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('Voltar'),
                onPressed: onGoBack,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey[300]!),
                ).merge(buttonStyle),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save_alt_rounded),
                label: const Text('Salvar Rejeição'),
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                ).merge(buttonStyle),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildMilkDataFieldsForRejection(BuildContext context) {
    return [
      const Text(
        "Informe os dados para registro:",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: volumeController,
              decoration: buildInputDecoration(
                context,
                labelText: 'Volume (L)',
                prefixIcon: Icons.local_drink_outlined,
              ),
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: temperatureController,
              decoration: buildInputDecoration(
                context,
                labelText: 'Temperatura (°C)',
                prefixIcon: Icons.thermostat_outlined,
              ),
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: phController,
        decoration: buildInputDecoration(
          context,
          labelText: 'Alizarol (GL)',
          prefixIcon: Icons.science_outlined,
        ),
        keyboardType: TextInputType.number,
        validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
      ),
    ];
  }
}
