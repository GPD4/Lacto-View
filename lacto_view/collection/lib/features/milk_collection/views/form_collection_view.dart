// lib/views/form_collection_view.dart

import 'package:flutter/material.dart';

// A função buildInputDecoration continua aqui, no topo do arquivo...
InputDecoration buildInputDecoration(
  BuildContext context, {
  required String labelText,
  IconData? prefixIcon,
}) {
  // ...código da função inalterado
  return InputDecoration(
    labelText: labelText,
    prefixIcon: prefixIcon != null
        ? Icon(prefixIcon, color: Colors.grey[600])
        : null,
    filled: true,
    fillColor: Colors.grey[100],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
    ),
  );
}

class CollectionDataForm extends StatelessWidget {
  // ... (Seus controladores e propriedades permanecem os mesmos)
  final TextEditingController volumeController;
  final TextEditingController temperatureController;
  final TextEditingController phController;
  final TextEditingController tubeNumberController;
  final TextEditingController observationController;
  final String? selectedNumtanque;
  final ValueChanged<String?> onNumTanqueChanged;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onFazerColeta;
  final VoidCallback onRejeitarColeta;

  const CollectionDataForm({
    super.key,
    required this.volumeController,
    required this.temperatureController,
    required this.phController,
    required this.tubeNumberController,
    required this.observationController,
    required this.selectedNumtanque,
    required this.onNumTanqueChanged,
    required this.onSave,
    required this.onCancel,
    required this.onFazerColeta,
    required this.onRejeitarColeta,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Estilo de botão centralizado para consistência
    final buttonStyle = ButtonStyle(
      padding: MaterialStateProperty.all<EdgeInsets>(
        const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),

        // Campos do Leite
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
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Obrigatório' : null,
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
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Obrigatório';
                  final temp = double.tryParse(value);
                  if (temp == null) return 'Somente números';
                  if (temp < 2.0 || temp > 9.0) return 'T fora do padrão';
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: phController,
                decoration: buildInputDecoration(
                  context,
                  labelText: 'Alizarol (GL)',
                  prefixIcon: Icons.science_outlined,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Obrigatório';
                  final aliz = double.tryParse(value);
                  if (aliz == null) return 'Somente números';
                  if (aliz < 75.0 || aliz > 80.0) return 'GL fora do padrão';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              // 3. Dropdown com estilo corrigido
              child: DropdownButtonFormField<String>(
                value: selectedNumtanque,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                decoration: buildInputDecoration(
                  context,
                  labelText: 'N° do Tanque',
                  prefixIcon: Icons.storage_outlined,
                ),
                items: ['1', '2', '3']
                    .map(
                      (label) =>
                          DropdownMenuItem(value: label, child: Text(label)),
                    )
                    .toList(),
                onChanged: onNumTanqueChanged,
                validator: (v) => (v == null) ? 'Obrigatório' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: tubeNumberController,
          keyboardType: TextInputType.number,
          decoration: buildInputDecoration(
            context,
            labelText: 'N° da Amostra',
            prefixIcon: Icons.opacity_outlined,
          ),
          validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: observationController,
          decoration: buildInputDecoration(
            context,
            labelText: 'Observações (Opcional)',
            prefixIcon: Icons.notes_outlined,
          ),
        ),
        const SizedBox(height: 32),

        // 4. Botões Finais com estilo profissional e consistente
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.close_rounded),
                label: const Text('Cancelar'),
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  fixedSize: const Size.fromHeight(40),
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey[300]!),
                ).merge(buttonStyle),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save_alt_rounded),
                label: const Text('Salvar'),
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size.fromHeight(40),
                  // Usa a cor primária do seu tema para o botão principal
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ).merge(buttonStyle),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
