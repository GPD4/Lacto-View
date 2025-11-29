import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_model/view_model_property.dart';

class FormPropertyView extends StatefulWidget {
  @override
  _FormPropertyViewState createState() => _FormPropertyViewState();
}

class _FormPropertyViewState extends State<FormPropertyView> {
  final _formKey = GlobalKey<FormState>();

  bool _isActive = true;

  final _nameController = TextEditingController();
  final _cepController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _tanksQtdController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _cepController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _tanksQtdController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = Provider.of<PropertyViewModel>(context, listen: false);

    // ✅ CORREÇÃO: Usar int.tryParse para evitar erro se o campo estiver vazio
    final tanksQtd = int.tryParse(_tanksQtdController.text) ?? 0;

    bool success = await viewModel.saveProperty(
      name: _nameController.text,
      cep: _cepController.text,
      street: _streetController.text,
      city: _cityController.text,
      state: _stateController.text,
      isActive: _isActive,
      tanksQtd: tanksQtd, // Usando a variável segura
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Propriedade cadastrada com sucesso!')),
        );
        _formKey.currentState!.reset();
        _nameController.clear();
        _cepController.clear();
        _streetController.clear();
        _cityController.clear();
        _stateController.clear();
        _tanksQtdController.clear();
        setState(() {
          _isActive = true;
        });
      } else {
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
    final isLoading = context.watch<PropertyViewModel>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nova Propriedade',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[800],
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
                  SwitchListTile(
                    title: Text('Propriedade Ativa?'),
                    value: _isActive,
                    activeColor: Colors.green.shade600,
                    inactiveTrackColor: Colors.grey.shade400,
                    thumbColor: MaterialStateProperty.all<Color>(Colors.white),
                    onChanged: (bool value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Divider(),
                  SizedBox(height: 20),
                  // --- 2 CAMPO NOME COMPLETO ---
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Nome da Propriedade",
                      prefixIcon: Icon(Icons.business),
                    ),
                    textInputAction:
                        TextInputAction.next, // Pula para o próximo
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Campo obrigatório'
                        : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _cepController,
                    decoration: InputDecoration(
                      labelText: "CEP",
                      prefixIcon: Icon(Icons.location_pin),
                    ),
                    keyboardType: TextInputType.number, // Teclado numérico
                    textInputAction: TextInputAction.next,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Campo obrigatório'
                        : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _streetController,
                    decoration: InputDecoration(
                      labelText: "Nome da Rua",
                      prefixIcon: Icon(Icons.signpost),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Campo obrigatório'
                        : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: "Nome da Cidade",
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Campo obrigatório'
                        : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _stateController,
                    decoration: InputDecoration(
                      labelText: "Estado-UF",
                      prefixIcon: Icon(Icons.public),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Campo obrigatório'
                        : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _tanksQtdController,
                    decoration: InputDecoration(
                      labelText: "N° de Tanques",
                      prefixIcon: Icon(Icons.storage),
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done, // Finaliza o form
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Por favor, insira um número válido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: isLoading ? null : _submitForm,
                    child: Text("CADASTRAR", style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),

              if (isLoading)
                Positioned.fill(
                  child: Container(
                    // ✅ CORREÇÃO: Erro de digitação 'withOpacity'
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
