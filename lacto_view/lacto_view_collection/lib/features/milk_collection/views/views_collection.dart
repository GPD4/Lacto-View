import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';

import '../model/model_collection.dart';
import '../service/service_collection.dart';
import '../view_models/view_models_collection.dart';
import '../views/form_rejection_view.dart';
import '../views/form_collection_view.dart';

//------------------- Tela Principal do Formulário --------------------//

class MilkCollectionFormView extends StatefulWidget {
  const MilkCollectionFormView({super.key});

  @override
  State<MilkCollectionFormView> createState() => _MilkCollectionFormViewState();
}

class _MilkCollectionFormViewState extends State<MilkCollectionFormView> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _volumeController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _phController = TextEditingController();
  final _observationController = TextEditingController();
  final _tubeNumberController = TextEditingController();

  Producer? _selectedProducer;
  String? _selectedNumtanque;
  String? _selectedRejectionReason;
  bool _producerPresent = false;
  bool _sampleCollected = false;
  bool _isRejectionMode = false;

  final List<String> _rejectionReasons = [
    "Requisitos para coleta não atendem o exigido (Temperatura e/ou Alizarol)",
    "Propriedade não acessível ou fechada",
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _volumeController.dispose();
    _temperatureController.dispose();
    _phController.dispose();
    _observationController.dispose();
    _tubeNumberController.dispose();
    super.dispose();
  }

  void _onProducerSelected(Producer producer) {
    setState(() {
      _selectedProducer = producer;
      _searchController.clear();
      context.read<MilkCollectionViewModel>().searchProducers('');
    });
  }

  void _cancelSelection() {
    setState(() {
      _selectedProducer = null;
      _searchController.clear();
      _volumeController.clear();
      _temperatureController.clear();
      _phController.clear();
      _observationController.clear();
      _tubeNumberController.clear();
      _selectedNumtanque = null;
      _producerPresent = true;
      _sampleCollected = false;
    });
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newCollection = MilkCollection(
        id: DateTime.now().millisecondsSinceEpoch,
        producerId: _selectedProducer!.id,
        producerName: _selectedProducer!.name.split(' ').sublist(1).join(' '),
        producerPropertyId: 404,
        propertyName: _selectedProducer!.propertyName,
        rejection: _isRejectionMode,
        rejectionReason: _selectedRejectionReason ?? '1',
        temperature: double.tryParse(_temperatureController.text) ?? 0.0,
        volumeLt: double.tryParse(_volumeController.text) ?? 0.0,
        producerPresent: _producerPresent,
        ph: double.tryParse(_phController.text) ?? 0.0,
        numtanque: _selectedNumtanque ?? '1',
        sample: _sampleCollected,
        tubeNumber: _sampleCollected ? _tubeNumberController.text : '',
        observation: _observationController.text,
        status: "PENDING_ANALYSIS",
        collectorId: 55,
        analysisId: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<MilkCollectionViewModel>().addCollection(newCollection);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MilkCollectionViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              _isRejectionMode ? 'Rejeitar Coleta' : 'Nova Coleta',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: _isRejectionMode
                ? Colors.red[800]
                : Colors.green[800],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_selectedProducer == null)
                    _buildProducerSearch(viewModel)
                  else
                    _buildFormBody(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProducerSearch(MilkCollectionViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _searchController,
          onChanged: (query) => viewModel.searchProducers(query),
          decoration: InputDecoration(
            labelText: 'Buscar Produtor',
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      viewModel.searchProducers('');
                    },
                  )
                : const Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 10),
        if (viewModel.isSearching)
          const Center(child: CircularProgressIndicator())
        else if (viewModel.searchResults.isNotEmpty)
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: viewModel.searchResults.length,
              itemBuilder: (context, index) {
                final producer = viewModel.searchResults[index];
                return ListTile(
                  title: Text(producer.name),
                  subtitle: Text(producer.propertyName),
                  onTap: () => _onProducerSelected(producer),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFormBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'Produtor: ${_selectedProducer!.name}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text('Propriedade: ${_selectedProducer!.propertyName}'),
          trailing: IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            tooltip: 'Limpar seleção',
            onPressed: _cancelSelection,
          ),
        ),
        CheckboxListTile(
          title: const Text('Produtor Presente?'),
          value: _producerPresent,
          onChanged: (val) => setState(() => _producerPresent = val!),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),

        //Botoes para alternar entre "Fazer Coleta" e "Rejeitar Coleta".
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[300], // Cor de fundo do container quando inativo
            borderRadius: BorderRadius.circular(25.0),
            border: Border.all(color: Colors.grey),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25.0),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Fazer Coleta'),
                      onPressed: () => setState(() => _isRejectionMode = false),
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size.fromHeight(50),
                        // Se o modo de rejeição NÃO estiver ativo, a cor é Verde. Se não, é cinza.
                        backgroundColor: !_isRejectionMode
                            ? Colors.green
                            : Colors.grey[300],

                        // Se o modo de rejeição NÃO estiver ativo, o texto é Branco. Senão, é cinza escuro.
                        foregroundColor: !_isRejectionMode
                            ? Colors.white
                            : Colors.grey[700],

                        // Adiciona sombra apenas quando o botão está selecionado.
                        elevation: !_isRejectionMode ? 2.0 : 0.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // BOTÃO REJEITAR COLETA
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Rejeitar Coleta'),
                      onPressed: () => setState(() => _isRejectionMode = true),
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size.fromHeight(50),
                        // Se o modo de rejeição ESTIVER ativo, a cor é Vermelha. Senão, é Cinza.
                        backgroundColor: _isRejectionMode
                            ? Colors.red
                            : Colors.grey[300],

                        // Se o modo de rejeição ESTIVER ativo, o texto é Branco. Senão, é Cinza escuro.
                        foregroundColor: _isRejectionMode
                            ? Colors.white
                            : Colors.grey[700],

                        // Adiciona sombra apenas quando o botão está selecionado.
                        elevation: _isRejectionMode ? 2.0 : 0.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        if (!_isRejectionMode) ...[
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Requisitos permitidos para Coleta',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Temperatura: 2 C° a 9 C° | Alizarol: 75GL a 80GL',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        Form(
          key: _formKey,
          child: _isRejectionMode
              ? RejectionDataForm(
                  volumeController: _volumeController,
                  temperatureController: _temperatureController,
                  phController: _phController,
                  selectedRejectionReason: _selectedRejectionReason,
                  rejectionReasons: _rejectionReasons,
                  onReasonChanged: (value) {
                    setState(() {
                      _selectedRejectionReason = value;
                    });
                  },
                  onSave: _saveForm,
                  onGoBack: () => setState(() => _isRejectionMode = false),
                )
              : CollectionDataForm(
                  volumeController: _volumeController,
                  temperatureController: _temperatureController,
                  phController: _phController,
                  tubeNumberController: _tubeNumberController,
                  observationController: _observationController,
                  selectedNumtanque: _selectedNumtanque,
                  onNumTanqueChanged: (value) {
                    setState(() {
                      _selectedNumtanque = value;
                    });
                  },
                  onSave: _saveForm,
                  onCancel: _cancelSelection,
                  onFazerColeta: _saveForm,
                  onRejeitarColeta: () =>
                      setState(() => _isRejectionMode = true),
                ),
        ),
      ],
    );
  }
}
