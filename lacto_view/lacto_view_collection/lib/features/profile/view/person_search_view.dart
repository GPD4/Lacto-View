import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../view_model/search_person_view_model.dart';
import '../service/service_person_search.dart';
import '../model/person_model.dart';

class PersonSearchView extends StatefulWidget {
  const PersonSearchView({Key? key}) : super(key: key);

  @override
  State<PersonSearchView> createState() => _PersonSearchViewState();
}

class _PersonSearchViewState extends State<PersonSearchView> {
  final TextEditingController _searchController = TextEditingController();
  final SearchPersonViewModel _viewModel =
      SearchPersonViewModel(ServicePersonSearch());
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Debounce para evitar muitas chamadas à API
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _viewModel.search(query, limit: 20);
    });
  }

  // Traduz role para português
  String _translateRole(String role) {
    switch (role) {
      case 'admin':
        return 'Administrador';
      case 'producer':
        return 'Produtor';
      case 'collector':
        return 'Coletor';
      default:
        return role;
    }
  }

  // Formata CPF ou CNPJ
  String _formatCpfCnpj(String cpfCnpj) {
    final digits = cpfCnpj.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length == 11) {
      // CPF: 000.000.000-00
      return '${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6, 9)}-${digits.substring(9)}';
    } else if (digits.length == 14) {
      // CNPJ: 00.000.000/0000-00
      return '${digits.substring(0, 2)}.${digits.substring(2, 5)}.${digits.substring(5, 8)}/${digits.substring(8, 12)}-${digits.substring(12)}';
    }
    return cpfCnpj;
  }

  // Exibe detalhes da pessoa em um modal
  void _showPersonDetails(Person person) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.green[100],
                    child: Icon(
                      Icons.person,
                      size: 35,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          person.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _translateRole(person.role),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[900],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32, thickness: 1),
              
              // Informações
              _buildDetailRow(
                Icons.badge,
                'CPF/CNPJ',
                _formatCpfCnpj(person.cpfCnpj),
              ),
              const SizedBox(height: 16),
              if (person.email != null && person.email!.isNotEmpty)
                _buildDetailRow(Icons.email, 'Email', person.email!),
              if (person.email != null && person.email!.isNotEmpty)
                const SizedBox(height: 16),
              _buildDetailRow(Icons.phone, 'Telefone', person.phone),
              const SizedBox(height: 16),
              _buildDetailRow(
                person.isActive ? Icons.check_circle : Icons.cancel,
                'Status',
                person.isActive ? 'Ativo' : 'Inativo',
                valueColor: person.isActive ? Colors.green : Colors.red,
              ),
              
              // Informações adicionais para produtores
              if (person.cadpro != null && person.cadpro!.isNotEmpty) ...[
                const Divider(height: 32, thickness: 1),
                const Text(
                  'Informações do Produtor',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.assignment_ind, 'Cadpro', person.cadpro!),
                if (person.propertyId != null) const SizedBox(height: 16),
                if (person.propertyId != null)
                  _buildDetailRow(
                    Icons.home_work,
                    'ID Propriedade',
                    person.propertyId!,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para linhas de detalhes
  Widget _buildDetailRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: valueColor ?? Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Consultar Usuários',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green[800],
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            // Campo de busca
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Buscar por nome ou CPF/CNPJ...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _viewModel.search('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            // Lista de resultados
            Expanded(
              child: Consumer<SearchPersonViewModel>(
                builder: (context, viewModel, child) {
                  // Estado de carregamento
                  if (viewModel.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // Estado de erro
                  if (viewModel.errorMessage.isNotEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Erro ao buscar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              viewModel.errorMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Verifique se o backend está rodando',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Lista vazia
                  if (viewModel.results.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'Digite para buscar usuários'
                                : 'Nenhum usuário encontrado',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Lista com resultados
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: viewModel.results.length,
                    itemBuilder: (context, index) {
                      final person = viewModel.results[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () => _showPersonDetails(person),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Avatar
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.green[100],
                                  child: Icon(
                                    Icons.person,
                                    size: 28,
                                    color: Colors.green[800],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // Informações
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        person.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatCpfCnpj(person.cpfCnpj),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              _translateRole(person.role),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.blue[900],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            person.isActive
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            size: 16,
                                            color: person.isActive
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Ícone de seta
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey[400],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
