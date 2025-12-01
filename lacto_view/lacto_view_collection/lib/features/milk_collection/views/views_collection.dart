import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../model/model_collection.dart';
import '../model/producer_property_model.dart';
import '../view_models/view_models_collection.dart';
import '../views/form_rejection_view.dart';
import '../views/form_collection_view.dart';
import '../../auth/view_model/auth_view_model.dart';

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
  final _searchFocusNode = FocusNode();

  ProducerProperty? _selectedItem;
  String? _selectedNumtanque;
  String? _selectedRejectionReason;
  bool _producerPresent = false;
  bool _sampleCollected = false;
  bool _isRejectionMode = false;
  bool _isSaving = false;

  final List<String> _rejectionReasons = [
    "Requisitos para coleta não atendem o exigido (Temperatura e/ou Alizarol)",
    "Propriedade não acessível ou fechada",
  ];

  // Cores do tema
  static const _primaryGreen = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _primaryRed = Color(0xFFC62828);
  static const _lightRed = Color(0xFFFFEBEE);
  static const _primaryBlue = Color(0xFF1565C0);

  @override
  void dispose() {
    _searchController.dispose();
    _volumeController.dispose();
    _temperatureController.dispose();
    _phController.dispose();
    _observationController.dispose();
    _tubeNumberController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onItemSelected(ProducerProperty item) {
    setState(() {
      _selectedItem = item;
      _searchController.clear();
      _selectedNumtanque = null;
      context.read<MilkCollectionViewModel>().clearSearchResults();
    });
    _searchFocusNode.unfocus();
  }

  void _cancelSelection() {
    setState(() {
      _selectedItem = null;
      _searchController.clear();
      _volumeController.clear();
      _temperatureController.clear();
      _phController.clear();
      _observationController.clear();
      _tubeNumberController.clear();
      _selectedNumtanque = null;
      _producerPresent = false;
      _sampleCollected = false;
      _isRejectionMode = false;
    });
    context.read<MilkCollectionViewModel>().clearSearchResults();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewModel>();
    final token = authViewModel.currentUser?.token;

    if (token == null || token.isEmpty) {
      _showSnackBar('Erro: Usuário não autenticado. Faça login novamente.', isError: true);
      return;
    }

    final currentUser = authViewModel.currentUser!;

    setState(() => _isSaving = true);

    final newCollection = MilkCollection(
      producerId: _selectedItem!.producerId ?? _selectedItem!.propertyId ?? '',
      producerName: _selectedItem!.producerName ?? 'Produtor',
      producerPropertyId: _selectedItem!.propertyId ?? '',
      propertyName: _selectedItem!.propertyName ?? '',
      rejection: _isRejectionMode,
      rejectionReason: _selectedRejectionReason ?? '',
      temperature: double.tryParse(_temperatureController.text) ?? 0.0,
      volumeLt: double.tryParse(_volumeController.text) ?? 0.0,
      producerPresent: _producerPresent,
      ph: double.tryParse(_phController.text) ?? 0.0,
      numtanque: _selectedNumtanque ?? '1',
      sample: _sampleCollected,
      tubeNumber: _sampleCollected ? _tubeNumberController.text : '',
      observation: _observationController.text,
      status: _isRejectionMode ? "REJECTED" : "PENDING_ANALYSIS",
      collectorName: currentUser.name,
      collectorId: currentUser.id,
      analysisId: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final viewModel = context.read<MilkCollectionViewModel>();
      final success = await viewModel.addCollection(token, newCollection);

      if (mounted) {
        setState(() => _isSaving = false);

        if (success) {
          _showSnackBar(
            _isRejectionMode ? 'Rejeição registrada!' : 'Coleta salva com sucesso!',
          );
          _cancelSelection();
        } else {
          _showSnackBar('Erro: ${viewModel.errorMessage}', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showSnackBar('Erro: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? _primaryRed : _primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MilkCollectionViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: _isRejectionMode ? _lightRed : _lightGreen,
          appBar: _buildAppBar(),
          body: Stack(
            children: [
              SafeArea(
                child: _selectedItem == null
                    ? _buildSearchView(viewModel)
                    : _buildFormView(),
              ),
              if (_isSaving) _buildLoadingOverlay(),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: _isRejectionMode ? _primaryRed : _primaryGreen,
      foregroundColor: Colors.white,
      title: Row(
        children: [
          Icon(
            _isRejectionMode ? Icons.block_rounded : Icons.water_drop_rounded,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            _isRejectionMode ? 'Rejeitar Coleta' : 'Nova Coleta',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        if (_selectedItem != null)
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Limpar formulário',
            onPressed: _cancelSelection,
          ),
      ],
    );
  }

  Widget _buildSearchView(MilkCollectionViewModel viewModel) {
    final isProducerMode = viewModel.searchMode == SearchMode.producer;
    
    return Column(
      children: [
        // Header com toggle e busca
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _primaryGreen,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toggle de modo de busca
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSearchModeButton(
                        icon: Icons.home_work_rounded,
                        label: 'Propriedade',
                        isSelected: !isProducerMode,
                        onTap: () {
                          viewModel.setSearchMode(SearchMode.property);
                          _searchController.clear();
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildSearchModeButton(
                        icon: Icons.person_rounded,
                        label: 'Produtor',
                        isSelected: isProducerMode,
                        onTap: () {
                          viewModel.setSearchMode(SearchMode.producer);
                          _searchController.clear();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Título dinâmico
              Text(
                isProducerMode ? 'Buscar Produtor' : 'Buscar Propriedade',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isProducerMode 
                    ? 'Digite o nome do produtor para iniciar a coleta'
                    : 'Digite o nome da propriedade ou cidade',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              
              // Campo de busca
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (query) => viewModel.search(query),
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: isProducerMode 
                        ? 'Nome do produtor...'
                        : 'Nome da propriedade ou cidade...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(
                      isProducerMode ? Icons.person_search_rounded : Icons.search_rounded,
                      color: _primaryGreen,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              viewModel.clearSearchResults();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Resultados da busca
        Expanded(
          child: _buildSearchResults(viewModel),
        ),
      ],
    );
  }

  Widget _buildSearchModeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? _primaryGreen : Colors.white.withOpacity(0.8),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? _primaryGreen : Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(MilkCollectionViewModel viewModel) {
    final isProducerMode = viewModel.searchMode == SearchMode.producer;

    if (viewModel.isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: _primaryGreen),
            const SizedBox(height: 16),
            Text(
              isProducerMode ? 'Buscando produtores...' : 'Buscando propriedades...',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (viewModel.searchError.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Erro ao buscar',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                viewModel.searchError,
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isProducerMode ? Icons.person_search_rounded : Icons.agriculture_rounded,
              size: 80,
              color: _primaryGreen.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Digite para buscar',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isProducerMode 
                  ? 'Encontre o produtor pelo nome'
                  : 'Encontre a propriedade pelo nome ou cidade',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_searchController.text.length < 2) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.keyboard_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Continue digitando...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Digite pelo menos 2 caracteres para buscar',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (viewModel.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              isProducerMode ? 'Nenhum produtor encontrado' : 'Nenhuma propriedade encontrada',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente outro termo de busca',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.searchResults.length,
      itemBuilder: (context, index) {
        final item = viewModel.searchResults[index];
        return _buildResultCard(item, isProducerMode);
      },
    );
  }

  Widget _buildResultCard(ProducerProperty item, bool isProducerMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onItemSelected(item),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Ícone
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isProducerMode ? Colors.blue[50] : _lightGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isProducerMode ? Icons.person_rounded : Icons.home_work_rounded,
                    color: isProducerMode ? _primaryBlue : _primaryGreen,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Informações
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isProducerMode 
                            ? (item.producerName ?? 'Produtor')
                            : (item.propertyName ?? 'Propriedade'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Subtítulo
                      if (isProducerMode && item.hasProperty) ...[
                        Row(
                          children: [
                            Icon(Icons.home_work_outlined, size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.propertyName ?? 'Sem propriedade',
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                      ],
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.location.isNotEmpty ? item.location : 'Sem localização',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.storage_rounded,
                            '${item.tanksQtd} tanque${item.tanksQtd > 1 ? 's' : ''}',
                          ),
                          if (isProducerMode && !item.hasProperty) ...[
                            const SizedBox(width: 8),
                            _buildWarningChip('Sem propriedade'),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Seta
                const Icon(
                  Icons.chevron_right_rounded,
                  color: _primaryGreen,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 12, color: Colors.orange[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.orange[700],
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card do item selecionado
          _buildSelectedItemCard(),
          const SizedBox(height: 16),

          // Toggle Fazer/Rejeitar Coleta
          _buildCollectionModeToggle(),
          const SizedBox(height: 16),

          // Informações de requisitos (apenas no modo coleta)
          if (!_isRejectionMode) _buildRequirementsCard(),
          if (!_isRejectionMode) const SizedBox(height: 16),

          // Checkbox produtor presente
          _buildProducerPresentCard(),
          const SizedBox(height: 16),

          // Formulário
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
                      setState(() => _selectedRejectionReason = value);
                    },
                    onSave: _saveForm,
                    onGoBack: () => setState(() => _isRejectionMode = false),
                  )
                : _buildCollectionForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedItemCard() {
    final viewModel = context.read<MilkCollectionViewModel>();
    final isProducerMode = viewModel.searchMode == SearchMode.producer;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _isRejectionMode ? _lightRed : (isProducerMode ? Colors.blue[50] : _lightGreen),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isProducerMode ? Icons.person_rounded : Icons.home_work_rounded,
                  color: _isRejectionMode ? _primaryRed : (isProducerMode ? _primaryBlue : _primaryGreen),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isProducerMode 
                          ? (_selectedItem!.producerName ?? 'Produtor')
                          : (_selectedItem!.propertyName ?? 'Propriedade'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isProducerMode && _selectedItem!.hasProperty)
                      Text(
                        _selectedItem!.propertyName ?? '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    Text(
                      _selectedItem!.location,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.grey),
                onPressed: _cancelSelection,
                tooltip: 'Alterar seleção',
              ),
            ],
          ),
          if (isProducerMode && !_selectedItem!.hasProperty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Produtor sem propriedade vinculada',
                      style: TextStyle(color: Colors.orange[800], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCollectionModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              icon: Icons.check_circle_rounded,
              label: 'Fazer Coleta',
              isSelected: !_isRejectionMode,
              color: _primaryGreen,
              onTap: () => setState(() => _isRejectionMode = false),
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              icon: Icons.block_rounded,
              label: 'Rejeitar',
              isSelected: _isRejectionMode,
              color: _primaryRed,
              onTap: () => setState(() => _isRejectionMode = true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.grey[500],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[500],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.blue[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Requisitos para Coleta',
                  style: TextStyle(
                    color: Colors.blue[900],
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Temperatura: 2°C a 9°C  •  Alizarol: 75GL a 80GL',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProducerPresentCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CheckboxListTile(
        title: const Text(
          'Produtor presente na coleta?',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        value: _producerPresent,
        onChanged: (val) => setState(() => _producerPresent = val ?? false),
        activeColor: _primaryGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildCollectionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primeira linha: Volume e Temperatura
        Row(
          children: [
            Expanded(child: _buildTextField(
              controller: _volumeController,
              label: 'Volume (L)',
              icon: Icons.local_drink_outlined,
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField(
              controller: _temperatureController,
              label: 'Temp. (°C)',
              icon: Icons.thermostat_outlined,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Obrigatório';
                final temp = double.tryParse(value);
                if (temp == null) return 'Inválido';
                if (temp < 2.0 || temp > 9.0) return 'Fora do padrão';
                return null;
              },
            )),
          ],
        ),
        const SizedBox(height: 12),

        // Segunda linha: Alizarol e Tanque
        Row(
          children: [
            Expanded(child: _buildTextField(
              controller: _phController,
              label: 'Alizarol (GL)',
              icon: Icons.science_outlined,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Obrigatório';
                final aliz = double.tryParse(value);
                if (aliz == null) return 'Inválido';
                if (aliz < 75.0 || aliz > 80.0) return 'Fora do padrão';
                return null;
              },
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildTankDropdown()),
          ],
        ),
        const SizedBox(height: 12),

        // Número da amostra
        _buildTextField(
          controller: _tubeNumberController,
          label: 'Número da Amostra',
          icon: Icons.qr_code_rounded,
          keyboardType: TextInputType.number,
          validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
        ),
        const SizedBox(height: 12),

        // Observações
        _buildTextField(
          controller: _observationController,
          label: 'Observações (Opcional)',
          icon: Icons.notes_rounded,
          maxLines: 3,
        ),
        const SizedBox(height: 24),

        // Botões
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _cancelSelection,
                icon: const Icon(Icons.close_rounded),
                label: const Text('Cancelar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _saveForm,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Salvar Coleta'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: _primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _isRejectionMode ? _primaryRed : _primaryGreen,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primaryRed, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primaryRed, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildTankDropdown() {
    final tanks = _selectedItem?.availableTanks ?? ['1'];
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedNumtanque,
        decoration: InputDecoration(
          labelText: 'Tanque',
          prefixIcon: Icon(Icons.storage_rounded, color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _isRejectionMode ? _primaryRed : _primaryGreen,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: tanks.map((tank) => DropdownMenuItem(
          value: tank,
          child: Text('Tanque $tank'),
        )).toList(),
        onChanged: (value) => setState(() => _selectedNumtanque = value),
        validator: (v) => v == null ? 'Obrigatório' : null,
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: _isRejectionMode ? _primaryRed : _primaryGreen,
              ),
              const SizedBox(height: 20),
              Text(
                _isRejectionMode ? 'Registrando rejeição...' : 'Salvando coleta...',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
