import 'package:flutter/services.dart';

/// Classe utilitária para validações de formulários
class Validators {
  /// Valida CPF (11 dígitos)
  static String? validateCpf(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }

    // Remove caracteres não numéricos
    final cpf = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cpf.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }

    // Verifica se todos os dígitos são iguais (ex: 111.111.111-11)
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) {
      return 'CPF inválido';
    }

    // Validação do primeiro dígito verificador
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }
    int firstDigit = (sum * 10) % 11;
    if (firstDigit == 10) firstDigit = 0;

    if (firstDigit != int.parse(cpf[9])) {
      return 'CPF inválido';
    }

    // Validação do segundo dígito verificador
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }
    int secondDigit = (sum * 10) % 11;
    if (secondDigit == 10) secondDigit = 0;

    if (secondDigit != int.parse(cpf[10])) {
      return 'CPF inválido';
    }

    return null;
  }

  /// Valida CNPJ (14 dígitos)
  static String? validateCnpj(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }

    // Remove caracteres não numéricos
    final cnpj = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cnpj.length != 14) {
      return 'CNPJ deve ter 14 dígitos';
    }

    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1{13}$').hasMatch(cnpj)) {
      return 'CNPJ inválido';
    }

    // Validação do primeiro dígito verificador
    List<int> weights1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      sum += int.parse(cnpj[i]) * weights1[i];
    }
    int firstDigit = sum % 11;
    firstDigit = firstDigit < 2 ? 0 : 11 - firstDigit;

    if (firstDigit != int.parse(cnpj[12])) {
      return 'CNPJ inválido';
    }

    // Validação do segundo dígito verificador
    List<int> weights2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    sum = 0;
    for (int i = 0; i < 13; i++) {
      sum += int.parse(cnpj[i]) * weights2[i];
    }
    int secondDigit = sum % 11;
    secondDigit = secondDigit < 2 ? 0 : 11 - secondDigit;

    if (secondDigit != int.parse(cnpj[13])) {
      return 'CNPJ inválido';
    }

    return null;
  }

  /// Valida CPF ou CNPJ baseado no tamanho
  static String? validateCpfCnpj(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }

    final digits = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.length == 11) {
      return validateCpf(value);
    } else if (digits.length == 14) {
      return validateCnpj(value);
    } else {
      return 'CPF (11 dígitos) ou CNPJ (14 dígitos)';
    }
  }

  /// Valida email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }

    // Regex para validação de email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email inválido';
    }

    return null;
  }

  /// Valida telefone brasileiro (10-11 dígitos)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }

    // Remove caracteres não numéricos
    final phone = value.replaceAll(RegExp(r'[^\d]'), '');

    if (phone.length < 10 || phone.length > 11) {
      return 'Telefone deve ter 10 ou 11 dígitos';
    }

    // Verifica se o DDD é válido (11-99)
    final ddd = int.tryParse(phone.substring(0, 2)) ?? 0;
    if (ddd < 11 || ddd > 99) {
      return 'DDD inválido';
    }

    return null;
  }

  /// Valida senha (mínimo 6 caracteres)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }

    if (value.length < 6) {
      return 'Senha deve ter no mínimo 6 caracteres';
    }

    return null;
  }
}

/// Formatter para CPF: XXX.XXX.XXX-XX
class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove todos os caracteres não numéricos
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Limita a 11 dígitos
    final limited = digits.length > 11 ? digits.substring(0, 11) : digits;

    // Aplica a máscara
    final formatted = _formatCpf(limited);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatCpf(String digits) {
    if (digits.isEmpty) return '';

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6) buffer.write('.');
      if (i == 9) buffer.write('-');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

/// Formatter para CNPJ: XX.XXX.XXX/XXXX-XX
class CnpjInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final limited = digits.length > 14 ? digits.substring(0, 14) : digits;
    final formatted = _formatCnpj(limited);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatCnpj(String digits) {
    if (digits.isEmpty) return '';

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2 || i == 5) buffer.write('.');
      if (i == 8) buffer.write('/');
      if (i == 12) buffer.write('-');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

/// Formatter para CPF/CNPJ: detecta automaticamente pelo tamanho
class CpfCnpjInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Limita a 14 dígitos (CNPJ)
    final limited = digits.length > 14 ? digits.substring(0, 14) : digits;

    String formatted;
    if (limited.length <= 11) {
      formatted = _formatCpf(limited);
    } else {
      formatted = _formatCnpj(limited);
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatCpf(String digits) {
    if (digits.isEmpty) return '';

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6) buffer.write('.');
      if (i == 9) buffer.write('-');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  String _formatCnpj(String digits) {
    if (digits.isEmpty) return '';

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2 || i == 5) buffer.write('.');
      if (i == 8) buffer.write('/');
      if (i == 12) buffer.write('-');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

/// Formatter para telefone: (XX) XXXXX-XXXX ou (XX) XXXX-XXXX
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Limita a 11 dígitos
    final limited = digits.length > 11 ? digits.substring(0, 11) : digits;

    final formatted = _formatPhone(limited);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatPhone(String digits) {
    if (digits.isEmpty) return '';

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 0) buffer.write('(');
      if (i == 2) buffer.write(') ');
      // Para celular (11 dígitos): hífen após o 7º dígito (posição 6)
      // Para fixo (10 dígitos): hífen após o 6º dígito (posição 5)
      if (digits.length == 11 && i == 7) buffer.write('-');
      if (digits.length <= 10 && i == 6) buffer.write('-');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

