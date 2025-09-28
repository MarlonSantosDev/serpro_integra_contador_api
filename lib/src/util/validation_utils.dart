/// Utilitário para validações de dados do SERPRO Integra Contador
class ValidationUtils {
  /// Valida se o CNPJ tem exatamente 14 dígitos
  static bool isValidCNPJ(String cnpj) {
    if (cnpj.isEmpty) return false;
    return cnpj.length == 14 && RegExp(r'^\d{14}$').hasMatch(cnpj);
  }

  /// Valida se o CPF tem exatamente 11 dígitos
  static bool isValidCPF(String cpf) {
    if (cpf.isEmpty) return false;
    return cpf.length == 11 && RegExp(r'^\d{11}$').hasMatch(cpf);
  }

  /// Valida se o período está no formato AAAAMM (6 dígitos)
  static bool isValidPeriodo(String periodo) {
    if (periodo.isEmpty) return false;
    if (!RegExp(r'^\d{6}$').hasMatch(periodo)) return false;

    final ano = int.tryParse(periodo.substring(0, 4));
    final mes = int.tryParse(periodo.substring(4, 6));

    if (ano == null || mes == null) return false;
    if (ano < 2000 || ano > 2099) return false;
    if (mes < 1 || mes > 12) return false;

    return true;
  }

  /// Valida se o número de declaração tem exatamente 17 dígitos
  static bool isValidNumeroDeclaracao(String numero) {
    if (numero.isEmpty) return false;
    return numero.length == 17 && RegExp(r'^\d{17}$').hasMatch(numero);
  }

  /// Valida se o número do DAS tem exatamente 17 dígitos
  static bool isValidNumeroDas(String numero) {
    if (numero.isEmpty) return false;
    return numero.length == 17 && RegExp(r'^\d{17}$').hasMatch(numero);
  }

  /// Valida se o ano tem exatamente 4 dígitos
  static bool isValidAno(String ano) {
    if (ano.isEmpty) return false;
    if (!RegExp(r'^\d{4}$').hasMatch(ano)) return false;

    final anoInt = int.tryParse(ano);
    if (anoInt == null) return false;
    if (anoInt < 2000 || anoInt > 2099) return false;

    return true;
  }

  /// Valida se o CNPJ ou CPF é válido
  static bool isValidCNPJOrCPF(String documento) {
    return isValidCNPJ(documento) || isValidCPF(documento);
  }

  /// Retorna o tipo do documento (CNPJ ou CPF)
  static String? getDocumentType(String documento) {
    if (isValidCNPJ(documento)) return 'CNPJ';
    if (isValidCPF(documento)) return 'CPF';
    return null;
  }

  /// Valida e lança exceção se inválido
  static void validateCNPJ(String cnpj, {String? fieldName}) {
    if (!isValidCNPJ(cnpj)) {
      throw ArgumentError('${fieldName ?? 'CNPJ'} inválido: deve ter exatamente 14 dígitos');
    }
  }

  /// Valida e lança exceção se inválido
  static void validateCPF(String cpf, {String? fieldName}) {
    if (!isValidCPF(cpf)) {
      throw ArgumentError('${fieldName ?? 'CPF'} inválido: deve ter exatamente 11 dígitos');
    }
  }

  /// Valida e lança exceção se inválido
  static void validatePeriodo(String periodo, {String? fieldName}) {
    if (!isValidPeriodo(periodo)) {
      throw ArgumentError('${fieldName ?? 'Período'} inválido: deve estar no formato AAAAMM (ex: 202401)');
    }
  }

  /// Valida e lança exceção se inválido
  static void validateNumeroDeclaracao(String numero, {String? fieldName}) {
    if (!isValidNumeroDeclaracao(numero)) {
      throw ArgumentError('${fieldName ?? 'Número da declaração'} inválido: deve ter exatamente 17 dígitos');
    }
  }

  /// Valida e lança exceção se inválido
  static void validateNumeroDas(String numero, {String? fieldName}) {
    if (!isValidNumeroDas(numero)) {
      throw ArgumentError('${fieldName ?? 'Número do DAS'} inválido: deve ter exatamente 17 dígitos');
    }
  }

  /// Valida e lança exceção se inválido
  static void validateAno(String ano, {String? fieldName}) {
    if (!isValidAno(ano)) {
      throw ArgumentError('${fieldName ?? 'Ano'} inválido: deve ter 4 dígitos (ex: 2024)');
    }
  }
}
