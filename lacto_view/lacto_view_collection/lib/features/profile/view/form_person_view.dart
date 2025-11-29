import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../view_model/view_models_person.dart';
import '../view_model/search_property_view_model.dart';
import '../model/property_model.dart';
import '../utils/validators.dart';

class FormPersonView extends StatefulWidget {
  @override
  _FormPersonViewState createState() => _FormPersonViewState();
}

class _FormPersonViewState extends State<FormPersonView> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedRole;

  final Map<String, String> _roles = {
    'Administrador': 'admin',
    'Coletor': 'collector',
    'Produtor': 'producer',
  };

  bool _isActive = true;
  Property? _selectedProperty;

  final _searchPropertyController = TextEditingController();
  final _nameController = TextEditingController();
  final _cpfCnpjController = TextEditingController();
  final _cadproController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _searchPropertyController.dispose();
    _cpfCnpjController.dispose();
    _cadproController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // A lógica de submissão agora chama o ViewModel
  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = Provider.of<PersonViewModel>(context, listen: false);

    // Remove formatação do CPF/CNPJ e telefone antes de enviar
    final cpfCnpjClean = _cpfCnpjController.text.replaceAll(RegExp(r'[^\d]'), '');
    final phoneClean = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');

    bool success = await viewModel.savePerson(
      name: _nameController.text.trim(),
      cpfCnpj: cpfCnpjClean,
      cadpro: _cadproController.text.trim(),
      email: _emailController.text.trim().toLowerCase(),
      phone: phoneClean,
      password: _passwordController.text,
      role: _selectedRole!,
      propertyId: _selectedProperty?.id,
      isActive: _isActive,
    );

    if (mounted) {
      // Verifica se o widget ainda está na tela
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário cadastrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        _formKey.currentState!.reset();
        _nameController.clear();
        _searchPropertyController.clear();
        _cadproController.clear();
        _cpfCnpjController.clear();
        _emailController.clear();
        _phoneController.clear();
        _passwordController.clear();
        setState(() {
          _selectedRole = null;
          _isActive = false;
          _selectedProperty = null;
        });
      } else {
        // Mostra o erro vindo do ViewModel
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage ?? "Erro desconhecido"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ouve o ViewModel para saber se está carregando
    final isLoading = context.watch<PersonViewModel>().isLoading;
    final searchViewModel = context.read<SearchPropertyViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Novo Usuário',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[800],
        // Adiciona automaticamente a seta de "voltar"
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          // Stack para mostrar o loading por cima de tudo
          child: Stack(
            children: [
              // Coluna com o formulário
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- 1 SELEÇÃO DE ROLE---
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    hint: const Text("Selecione um papel"),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.work_outline),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Selecione um papel'
                        : null,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRole = newValue;
                      });
                    },
                    items: _roles.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.value,
                        child: Text(entry.key),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  if (_selectedRole != null) ...[
                    // --- 2 BOTÃO ATIVAR/DESATIVAR (SWITCH) ---
                    SwitchListTile(
                      title: const Text('Usuário Ativo?'),
                      value: _isActive,
                      activeColor: Colors.green.shade600,
                      inactiveTrackColor: Colors.grey.shade400,
                      thumbColor: WidgetStateProperty.all<Color>(
                        Colors.white,
                      ),
                      onChanged: (bool value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    // --- 3 CAMPO NOME COMPLETO ---
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Nome Completo",
                        prefixIcon: Icon(Icons.person),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? 'Campo obrigatório'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    // Campo para Buscar Propriedades --->>>
                    if (_selectedRole == 'producer') ...[
                      FormField<Property>(
                        validator: (value) {
                          if (_selectedProperty == null) {
                            return 'Selecione uma Propriedade';
                          }
                          return null;
                        },
                        builder: (FormFieldState<Property> field) {
                          return TypeAheadField<Property>(
                            debounceDuration: const Duration(seconds: 1),

                            suggestionsCallback: (pattern) async {
                              if (pattern.isEmpty) {
                                return [];
                              }
                              await searchViewModel.search(pattern, limit: 5);
                              return searchViewModel.results;
                            },
                            builder: (context, controller, focusNode) {
                              controller.text = _searchPropertyController.text;

                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  labelText: "Propriedade",
                                  hintText: "Buscar Propriedade...",
                                  prefixIcon: const Icon(Icons.search),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  errorText: field.errorText,
                                ),
                              );
                            },
                            itemBuilder: (context, suggestion) {
                              return ListTile(
                                title: Text(suggestion.name),
                                subtitle: Text(suggestion.city),
                              );
                            },
                            onSelected: (suggestion) {
                              _searchPropertyController.text = suggestion.name;
                              field.didChange(suggestion);
                              _selectedProperty = suggestion;
                              print(
                                "Propriedade selecionada: ${suggestion.id}",
                              );
                            },
                            loadingBuilder: (context) => const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            emptyBuilder: (context) => const ListTile(
                              title: Text("Nenhuma propriedade encontrada"),
                            ),
                            errorBuilder: (context, error) =>
                                ListTile(title: Text("Erro ao buscar: $error")),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    // --- 4 CAMPO CPF/CNPJ ---
                    TextFormField(
                      controller: _cpfCnpjController,
                      decoration: const InputDecoration(
                        labelText: "CPF/CNPJ",
                        prefixIcon: Icon(Icons.badge),
                        hintText: "000.000.000-00",
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CpfCnpjInputFormatter(),
                      ],
                      validator: Validators.validateCpfCnpj,
                    ),
                    const SizedBox(height: 16),
                    if (_selectedRole == 'producer') ...[
                      // ---5 CAMPO CadPro ---
                      TextFormField(
                        controller: _cadproController,
                        decoration: const InputDecoration(
                          labelText: "Cadpro",
                          prefixIcon: Icon(Icons.assignment_ind),
                        ),
                        validator: (value) => (value == null || value.trim().isEmpty)
                            ? 'Campo obrigatório'
                            : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                    // --- 6 CAMPO Email ---
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email),
                        hintText: "exemplo@email.com",
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    // --- 7 CAMPO phone ---
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: "Telefone",
                        prefixIcon: Icon(Icons.phone),
                        hintText: "(00) 00000-0000",
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        PhoneInputFormatter(),
                      ],
                      validator: Validators.validatePhone,
                    ),
                    const SizedBox(height: 16),
                    // --- 8 CAMPO Senha ---
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: "Senha",
                        prefixIcon: Icon(Icons.lock),
                        hintText: "Mínimo 6 caracteres",
                      ),
                      obscureText: true,
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 30),
                    // --- BOTÃO DE SUBMISSÃO ---
                    ElevatedButton(
                      // Desabilita o botão enquanto carrega
                      onPressed: isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("CADASTRAR", style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ],
              ),
              // --- 5 INDICADOR DE LOADING ---
              // Se estiver carregando, mostra um overlay
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
