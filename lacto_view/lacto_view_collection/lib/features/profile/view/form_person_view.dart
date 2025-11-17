import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';

import '../view_model/view_models_person.dart';
import '../view_model/search_property_view_model.dart';
import '../model/property_model.dart';

class FormPersonView extends StatefulWidget {
  @override
  _FormPersonViewState createState() => _FormPersonViewState();
}

class _FormPersonViewState extends State<FormPersonView> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedRole;
  final List<String> _roles = ['admin', 'coletor', 'produtor'];
  bool _isActive = true;
  Property? _selectedProperty;

  final _searchPropertyController = TextEditingController();
  final _nameController = TextEditingController();
  final _cpfCnpjController = TextEditingController();
  final _cadproController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _searchPropertyController.dispose();
    _cpfCnpjController.dispose();
    _cadproController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // A lógica de submissão agora chama o ViewModel
  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = Provider.of<PersonViewModel>(context, listen: false);

    bool success = await viewModel.savePerson(
      name: _nameController.text,
      cpfCnpj: _cpfCnpjController.text,
      cadpro: _cadproController.text,
      email: _emailController.text,
      telefone: _telefoneController.text,
      password: _passwordController.text,
      role: _selectedRole!,
      isActive: _isActive,
    );

    if (mounted) {
      // Verifica se o widget ainda está na tela
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário cadastrado com sucesso!')),
        );
        _formKey.currentState!.reset();
        _nameController.clear();
        _searchPropertyController.clear();
        _cadproController.clear();
        _cpfCnpjController.clear();
        _emailController.clear();
        _telefoneController.clear();
        _passwordController.clear();
        setState(() {
          _selectedRole = null;
          _isActive = false;
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
          style: const TextStyle(color: Colors.white),
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
                    hint: Text("Selecione um papel"),
                    decoration: InputDecoration(
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
                    items: _roles.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  if (_selectedRole != null) ...[
                    // --- 2 BOTÃO ATIVAR/DESATIVAR (SWITCH) ---
                    SwitchListTile(
                      //cdigo Switch aqui
                      title: Text('Usuário Ativo?'),
                      value: _isActive,
                      activeColor: Colors.green.shade600,
                      inactiveTrackColor: Colors.grey.shade400,
                      thumbColor: MaterialStateProperty.all<Color>(
                        Colors.white,
                      ),
                      onChanged: (bool value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                      // ...
                    ),
                    SizedBox(height: 20),
                    Divider(),
                    SizedBox(height: 20),
                    // --- 3 CAMPO NOME COMPLETO ---
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Nome Completo",
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Campo obrigatório'
                          : null,
                    ),
                    SizedBox(height: 16),
                    // Campo para Buscar Propriedades --->>>
                    if (_selectedRole == 'produtor') ...[
                      FormField<Property>(
                        validator: (value) {
                          if (value == null) {
                            return 'Selecione uma Propriedade';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _selectedProperty = value;
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
                    ],
                    /*TextFormField(
                        controller: _searchPropertyController,
                        decoration: InputDecoration(
                          //estilo barra de busca
                          labelText: "Propriedade",
                          hintText: "Buscar Propriedade...",
                          prefixIcon: Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),*/
                    // --- 4 CAMPO CPF/CNPJ ---
                    TextFormField(
                      controller: _cpfCnpjController,
                      decoration: InputDecoration(
                        labelText: "CPF/CNPJ",
                        prefixIcon: Icon(Icons.badge),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Campo obrigatório'
                          : null,
                    ),
                    SizedBox(height: 16),
                    if (_selectedRole == 'produtor') ...[
                      // ---5 CAMPO CadPro ---
                      TextFormField(
                        controller: _cadproController,
                        decoration: InputDecoration(
                          labelText: "Cadpro",
                          prefixIcon: Icon(Icons.assignment_ind),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Campo obrigatório'
                            : null,
                      ),
                      SizedBox(height: 16),
                    ],
                    // --- 6 CAMPO Email ---
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Campo obrigatório'
                          : null,
                    ),
                    SizedBox(height: 16),
                    // --- 7 CAMPO Telefone ---
                    TextFormField(
                      controller: _telefoneController,
                      decoration: InputDecoration(
                        labelText: "Telefone",
                        prefixIcon: Icon(Icons.phone),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Campo obrigatório'
                          : null,
                    ),
                    SizedBox(height: 16),
                    // --- 8 CAMPO Senha ---
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: "Senha",
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Campo obrigatório'
                          : null,
                    ),
                    SizedBox(height: 30),
                    // --- BOTÃO DE SUBMISSÃO ---
                    ElevatedButton(
                      // Desabilita o botão enquanto carrega
                      onPressed: isLoading ? null : _submitForm,
                      child: Text("CADASTRAR", style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
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
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
