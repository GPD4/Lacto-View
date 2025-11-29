import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../auth/view_model/auth_view_model.dart';
import '../../auth/model/user_model.dart';
import '../../milk_collection/model/model_collection.dart';
import '../view_model/search_collection_view_model.dart';
import '../service/search_collection_service.dart';
import '../service/pdf_export_service.dart';
import '../widgets/collection_card.dart';

class SearchCollectionView extends StatefulWidget {
  const SearchCollectionView({super.key});

  @override
  State<SearchCollectionView> createState() => _SearchCollectionViewState();
}

class _SearchCollectionViewState extends State<SearchCollectionView> {
  final _searchController = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyyy');
  
  DateTime? _startDate;
  DateTime? _endDate;
  SearchType _selectedSearchType = SearchType.producer;
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate 
        ? (_startDate ?? DateTime.now()) 
        : (_endDate ?? DateTime.now());
    
    final firstDate = isStartDate 
        ? DateTime(2020) 
        : (_startDate ?? DateTime(2020));
    
    final lastDate = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: isStartDate ? 'Selecione a data inicial' : 'Selecione a data final',
      cancelText: 'Cancelar',
      confirmText: 'OK',
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Se data final for menor que inicial, ajusta
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = picked;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _startDate = null;
      _endDate = null;
      _selectedSearchType = SearchType.producer;
    });
  }

  void _performSearch(SearchCollectionViewModel viewModel, AuthViewModel authViewModel) {
    final user = authViewModel.currentUser;
    if (user == null) return;

    // Se for produtor, filtra apenas as coletas dele
    final producerId = user.role == UserRole.producer ? user.id : null;

    viewModel.setSearchType(_selectedSearchType);
    viewModel.setSearchTerm(_searchController.text);
    viewModel.setStartDate(_startDate);
    viewModel.setEndDate(_endDate);

    viewModel.search(
      token: user.token,
      producerId: producerId,
    );
  }

  Future<void> _exportToPdf(List<MilkCollection> collections) async {
    try {
      await PdfExportService.exportToPdf(collections);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao gerar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportSingleToPdf(MilkCollection collection) async {
    try {
      await PdfExportService.exportSingleCollectionToPdf(collection);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao gerar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.currentUser;
    final isProducer = user?.role == UserRole.producer;

    return ChangeNotifierProvider(
      create: (_) => SearchCollectionViewModel(SearchCollectionService()),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            'Histórico de Coletas',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.green[800],
          elevation: 0,
          actions: [
            // Botão de exportar PDF
            Consumer<SearchCollectionViewModel>(
              builder: (context, viewModel, _) {
                final hasCollections = viewModel.collections.isNotEmpty;
                return IconButton(
                  icon: const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.white,
                  ),
                  onPressed: hasCollections
                      ? () => _exportToPdf(viewModel.collections)
                      : null,
                  tooltip: 'Exportar PDF',
                  disabledColor: Colors.white38,
                );
              },
            ),
            IconButton(
              icon: Icon(
                _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
              tooltip: 'Filtros',
            ),
          ],
        ),
        body: Consumer<SearchCollectionViewModel>(
          builder: (context, viewModel, _) {
            return Column(
              children: [
                // Header com busca
                Container(
                  color: Colors.green[800],
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      // Barra de busca
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: _getSearchHint(),
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            prefixIcon: Icon(Icons.search, color: Colors.green[700]),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.grey),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                          onSubmitted: (_) => _performSearch(viewModel, authViewModel),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Dropdown tipo de busca (não mostrar para produtor se buscar por produtor)
                      if (!isProducer || _selectedSearchType != SearchType.producer)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<SearchType>(
                              value: _selectedSearchType,
                              isExpanded: true,
                              icon: Icon(Icons.arrow_drop_down, color: Colors.green[700]),
                              items: _getSearchTypeItems(isProducer),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedSearchType = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Filtros expandíveis
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _showFilters ? null : 0,
                  child: _showFilters
                      ? Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Filtrar por Data',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDateButton(
                                      label: 'Data Inicial',
                                      date: _startDate,
                                      onTap: () => _selectDate(context, true),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildDateButton(
                                      label: 'Data Final',
                                      date: _endDate,
                                      onTap: () => _selectDate(context, false),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _clearFilters,
                                      icon: const Icon(Icons.clear_all),
                                      label: const Text('Limpar'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.grey[700],
                                        side: BorderSide(color: Colors.grey[400]!),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _performSearch(viewModel, authViewModel),
                                      icon: const Icon(Icons.search),
                                      label: const Text('Buscar'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green[700],
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // Chips de filtros ativos
                if (_hasActiveFilters())
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _buildFilterChips(),
                      ),
                    ),
                  ),

                // Lista de resultados
                Expanded(
                  child: _buildResultsList(viewModel),
                ),
              ],
            );
          },
        ),
        // Botão flutuante para buscar
        floatingActionButton: Consumer<SearchCollectionViewModel>(
          builder: (context, viewModel, _) {
            return FloatingActionButton(
              onPressed: () => _performSearch(viewModel, authViewModel),
              backgroundColor: Colors.green[700],
              child: const Icon(Icons.search, color: Colors.white),
            );
          },
        ),
      ),
    );
  }

  String _getSearchHint() {
    switch (_selectedSearchType) {
      case SearchType.producer:
        return 'Buscar por nome do produtor...';
      case SearchType.collector:
        return 'Buscar por nome do coletor...';
      case SearchType.collectionNumber:
        return 'Buscar por número da coleta...';
    }
  }

  List<DropdownMenuItem<SearchType>> _getSearchTypeItems(bool isProducer) {
    final items = <DropdownMenuItem<SearchType>>[];
    
    // Produtor não pode buscar por produtor (só vê as próprias coletas)
    if (!isProducer) {
      items.add(const DropdownMenuItem(
        value: SearchType.producer,
        child: Row(
          children: [
            Icon(Icons.person, size: 20),
            SizedBox(width: 8),
            Text('Buscar por Produtor'),
          ],
        ),
      ));
    }
    
    items.addAll([
      const DropdownMenuItem(
        value: SearchType.collector,
        child: Row(
          children: [
            Icon(Icons.local_shipping, size: 20),
            SizedBox(width: 8),
            Text('Buscar por Coletor'),
          ],
        ),
      ),
      const DropdownMenuItem(
        value: SearchType.collectionNumber,
        child: Row(
          children: [
            Icon(Icons.numbers, size: 20),
            SizedBox(width: 8),
            Text('Buscar por Número da Coleta'),
          ],
        ),
      ),
    ]);

    return items;
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 18, color: Colors.green[700]),
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
                    date != null ? _dateFormat.format(date) : 'Selecionar',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: date != null ? Colors.black87 : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return _startDate != null || 
           _endDate != null || 
           _searchController.text.isNotEmpty;
  }

  List<Widget> _buildFilterChips() {
    final chips = <Widget>[];

    if (_searchController.text.isNotEmpty) {
      chips.add(_buildChip(
        label: '"${_searchController.text}"',
        onDelete: () {
          _searchController.clear();
          setState(() {});
        },
      ));
    }

    if (_startDate != null) {
      chips.add(_buildChip(
        label: 'De: ${_dateFormat.format(_startDate!)}',
        onDelete: () {
          setState(() {
            _startDate = null;
          });
        },
      ));
    }

    if (_endDate != null) {
      chips.add(_buildChip(
        label: 'Até: ${_dateFormat.format(_endDate!)}',
        onDelete: () {
          setState(() {
            _endDate = null;
          });
        },
      ));
    }

    return chips;
  }

  Widget _buildChip({required String label, required VoidCallback onDelete}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onDelete,
        backgroundColor: Colors.green[50],
        side: BorderSide(color: Colors.green[200]!),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  Widget _buildResultsList(SearchCollectionViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              viewModel.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.clearFilters(),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (viewModel.collections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhuma coleta encontrada',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente ajustar os filtros de busca',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.collections.length,
      itemBuilder: (context, index) {
        final collection = viewModel.collections[index];
        return CollectionCard(
          collection: collection,
          onTap: () => _showCollectionDetails(context, collection),
        );
      },
    );
  }

  void _showCollectionDetails(BuildContext context, MilkCollection collection) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CollectionDetailsSheet(
        collection: collection,
        onExportPdf: () => _exportSingleToPdf(collection),
      ),
    );
  }
}

/// Bottom sheet com detalhes da coleta
class _CollectionDetailsSheet extends StatelessWidget {
  final MilkCollection collection;
  final VoidCallback? onExportPdf;

  const _CollectionDetailsSheet({
    required this.collection,
    this.onExportPdf,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: collection.rejection 
                            ? Colors.red[50] 
                            : Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        collection.rejection 
                            ? Icons.cancel 
                            : Icons.check_circle,
                        color: collection.rejection 
                            ? Colors.red[700] 
                            : Colors.green[700],
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            collection.rejection ? 'Coleta Rejeitada' : 'Coleta Aprovada',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: collection.rejection 
                                  ? Colors.red[700] 
                                  : Colors.green[700],
                            ),
                          ),
                          Text(
                            'ID: ${collection.id ?? 'N/A'}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    // Botão de exportar PDF
                    if (onExportPdf != null)
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onExportPdf!();
                        },
                        icon: Icon(
                          Icons.picture_as_pdf,
                          color: Colors.green[700],
                          size: 28,
                        ),
                        tooltip: 'Exportar PDF',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.green[50],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Informações
                _buildInfoSection('Produtor', [
                  _buildInfoRow(Icons.person, 'Nome', collection.producerName),
                  _buildInfoRow(Icons.home, 'Propriedade', collection.propertyName),
                ]),

                _buildInfoSection('Coletor', [
                  _buildInfoRow(Icons.local_shipping, 'Nome', collection.collectorName),
                ]),

                _buildInfoSection('Dados da Coleta', [
                  _buildInfoRow(Icons.water_drop, 'Volume', '${collection.volumeLt} L'),
                  _buildInfoRow(Icons.thermostat, 'Temperatura', '${collection.temperature}°C'),
                  _buildInfoRow(Icons.science, 'pH', collection.ph.toString()),
                  _buildInfoRow(Icons.storage, 'Tanque', collection.numtanque),
                  if (collection.sample)
                    _buildInfoRow(Icons.biotech, 'Tubo Amostra', collection.tubeNumber),
                ]),

                _buildInfoSection('Data e Status', [
                  _buildInfoRow(Icons.calendar_today, 'Data', dateFormat.format(collection.createdAt)),
                  _buildInfoRow(Icons.info, 'Status', collection.status),
                  _buildInfoRow(
                    Icons.person_pin, 
                    'Produtor Presente', 
                    collection.producerPresent ? 'Sim' : 'Não',
                  ),
                ]),

                if (collection.observation.isNotEmpty)
                  _buildInfoSection('Observações', [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(collection.observation),
                    ),
                  ]),

                if (collection.rejection && collection.rejectionReason.isNotEmpty)
                  _buildInfoSection('Motivo da Rejeição', [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Text(
                        collection.rejectionReason,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ]),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 16),
        Divider(color: Colors.grey[200]),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey[600]),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

