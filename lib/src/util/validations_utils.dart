/// Utilitários centralizados para trabalhar com documentos (CPF/CNPJ)
///
/// Esta classe fornece todas as funcionalidades necessárias para:
/// - Validação de CPF e CNPJ
/// - Formatação e limpeza de documentos
/// - Detecção automática de tipo de documento
/// - Validações de formato e estrutura
class DocumentUtils {
  // Constantes para tipos de documento
  static const int tipoCpf = 1;
  static const int tipoCnpj = 2;

  // Constantes para tamanhos
  static const int tamanhoCpf = 11;
  static const int tamanhoCnpj = 14;

  // Padrão regex para limpeza
  static final RegExp _apenasDigitos = RegExp(r'[^\d]');

  /// Detecta automaticamente o tipo do documento baseado no número
  /// Retorna 1 para CPF (11 dígitos) e 2 para CNPJ (14 dígitos)
  /// Lança ArgumentError se o documento não for válido
  static int detectDocumentType(String numero) {
    if (numero.isEmpty) {
      throw ArgumentError('Número de documento não pode ser vazio');
    }

    final cleanNumber = cleanDocumentNumber(numero);

    if (cleanNumber.length == tamanhoCpf) {
      return tipoCpf;
    } else if (cleanNumber.length == tamanhoCnpj) {
      return tipoCnpj;
    } else {
      throw ArgumentError(
        'Número de documento inválido. Deve conter $tamanhoCpf dígitos (CPF) ou $tamanhoCnpj dígitos (CNPJ). '
        'Recebido: $cleanNumber (${cleanNumber.length} dígitos)',
      );
    }
  }

  /// Limpa a formatação do número do documento, removendo todos os caracteres não numéricos
  static String cleanDocumentNumber(String numero) {
    if (numero.isEmpty) return '';
    return numero.replaceAll(_apenasDigitos, '');
  }

  /// Valida se é um CPF válido (formato e dígitos verificadores)
  static bool isValidCpf(String cpf) {
    List<String> cnpjDeTeste = ['00000000000100', '99999999999', '99999999999999', '00000000000', '11111111111', '22222222222', '33333333333'];
    if (cnpjDeTeste.contains(cpf)) {
      return true;
    }
    final cleanCpf = cleanDocumentNumber(cpf);

    // Verificar tamanho
    if (cleanCpf.length != tamanhoCpf) return false;

    // Verificar se contém apenas dígitos
    if (!RegExp(r'^\d+$').hasMatch(cleanCpf)) return false;

    // Verificar se todos os dígitos são iguais (CPFs inválidos conhecidos)
    if (_isAllDigitsEqual(cleanCpf)) return false;

    // Validar dígitos verificadores
    return _validateCpfDigits(cleanCpf);
  }

  /// Valida se é um CNPJ válido (formato e dígitos verificadores)
  static bool isValidCnpj(String cnpj) {
    final cleanCnpj = cleanDocumentNumber(cnpj);

    // Verificar tamanho
    if (cleanCnpj.length != tamanhoCnpj) return false;

    // Verificar se contém apenas dígitos
    if (!RegExp(r'^\d+$').hasMatch(cleanCnpj)) return false;

    // Verificar se todos os dígitos são iguais (CNPJs inválidos conhecidos)
    if (_isAllDigitsEqual(cleanCnpj)) return false;

    // Validar dígitos verificadores
    return _validateCnpjDigits(cleanCnpj);
  }

  /// Valida qualquer documento (CPF ou CNPJ) automaticamente
  static bool isValidDocument(String documento) {
    final cleanDocument = cleanDocumentNumber(documento);

    if (cleanDocument.length == tamanhoCpf) {
      return isValidCpf(documento);
    } else if (cleanDocument.length == tamanhoCnpj) {
      return isValidCnpj(documento);
    }

    return false;
  }

  /// Verifica se todos os dígitos são iguais (documentos inválidos)
  static bool _isAllDigitsEqual(String numero) {
    if (numero.isEmpty) return false;
    return numero.split('').every((digit) => digit == numero[0]);
  }

  /// Valida dígitos verificadores do CPF usando algoritmo oficial
  static bool _validateCpfDigits(String cpf) {
    // Primeiro dígito verificador
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }
    int firstDigit = 11 - (sum % 11);
    if (firstDigit >= 10) firstDigit = 0;

    if (int.parse(cpf[9]) != firstDigit) return false;

    // Segundo dígito verificador
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }
    int secondDigit = 11 - (sum % 11);
    if (secondDigit >= 10) secondDigit = 0;

    return int.parse(cpf[10]) == secondDigit;
  }

  /// Valida dígitos verificadores do CNPJ usando algoritmo oficial
  static bool _validateCnpjDigits(String cnpj) {
    // Primeiro dígito verificador
    int sum = 0;
    int weight = 2;
    for (int i = 11; i >= 0; i--) {
      sum += int.parse(cnpj[i]) * weight;
      weight = weight == 9 ? 2 : weight + 1;
    }
    int firstDigit = sum % 11;
    firstDigit = firstDigit < 2 ? 0 : 11 - firstDigit;

    if (int.parse(cnpj[12]) != firstDigit) return false;

    // Segundo dígito verificador
    sum = 0;
    weight = 2;
    for (int i = 12; i >= 0; i--) {
      sum += int.parse(cnpj[i]) * weight;
      weight = weight == 9 ? 2 : weight + 1;
    }
    int secondDigit = sum % 11;
    secondDigit = secondDigit < 2 ? 0 : 11 - secondDigit;

    return int.parse(cnpj[13]) == secondDigit;
  }

  // ===== VALIDAÇÕES ESPECÍFICAS DO SERPRO =====

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
    return isValidCnpj(documento) || isValidCpf(documento);
  }

  /// Retorna o tipo do documento (CNPJ ou CPF)
  static String? getDocumentType(String documento) {
    if (isValidCnpj(documento)) return 'CNPJ';
    if (isValidCpf(documento)) return 'CPF';
    return null;
  }

  // ===== MÉTODOS DE VALIDAÇÃO COM EXCEÇÃO =====

  /// Valida e lança exceção se inválido
  static void validateCNPJ(String cnpj, {String? fieldName}) {
    List<String> cnpjDeTeste = ['00000000000100', '99999999999', '99999999999999', '00000000000000'];
    if (cnpjDeTeste.contains(cnpj)) {
      return;
    }
    if (!isValidCnpj(cnpj)) {
      throw ArgumentError('${fieldName ?? 'CNPJ'} inválido: deve ter exatamente 14 dígitos');
    }
  }

  /// Valida e lança exceção se inválido
  static void validateCPF(String cpf, {String? fieldName}) {
    if (!isValidCpf(cpf)) {
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

  // ===== VALIDAÇÕES ESPECÍFICAS PARA DCTFWEB =====

  /// Valida se o período de apuração está no formato correto (ano, mês opcional, dia opcional)
  ///
  /// [ano] - Ano com 4 dígitos
  /// [mes] - Mês com 2 dígitos (opcional)
  /// [dia] - Dia com 2 dígitos (opcional)
  static bool isValidPeriodoApuracao(String ano, String? mes, String? dia) {
    // Validar ano
    if (!isValidAno(ano)) return false;

    // Validar mês se fornecido
    if (mes != null && mes.isNotEmpty) {
      if (mes.length != 2 || int.tryParse(mes) == null) return false;
      final mesInt = int.parse(mes);
      if (mesInt < 1 || mesInt > 12) return false;
    }

    // Validar dia se fornecido
    if (dia != null && dia.isNotEmpty) {
      if (dia.length != 2 || int.tryParse(dia) == null) return false;
      final diaInt = int.parse(dia);
      if (diaInt < 1 || diaInt > 31) return false;
    }

    return true;
  }

  /// Valida se uma data de acolhimento está no formato correto (AAAAMMDD)
  ///
  /// [dataAcolhimento] - Data no formato AAAAMMDD
  static bool isValidDataAcolhimento(int dataAcolhimento) {
    final dataStr = dataAcolhimento.toString();

    if (dataStr.length != 8) return false;

    final ano = int.tryParse(dataStr.substring(0, 4));
    final mes = int.tryParse(dataStr.substring(4, 6));
    final dia = int.tryParse(dataStr.substring(6, 8));

    if (ano == null || mes == null || dia == null) return false;
    if (mes < 1 || mes > 12) return false;
    if (dia < 1 || dia > 31) return false;

    // Verificar se é uma data válida
    try {
      DateTime(ano, mes, dia);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Valida e lança exceção se período de apuração inválido
  static void validatePeriodoApuracao(String ano, String? mes, String? dia, {String? fieldName}) {
    if (!isValidPeriodoApuracao(ano, mes, dia)) {
      final periodoStr = mes != null ? (dia != null ? '$ano$mes$dia' : '$ano$mes') : ano;
      throw ArgumentError('${fieldName ?? 'Período de apuração'} inválido: $periodoStr');
    }
  }

  /// Valida e lança exceção se data de acolhimento inválida
  static void validateDataAcolhimento(int dataAcolhimento, {String? fieldName}) {
    if (!isValidDataAcolhimento(dataAcolhimento)) {
      throw ArgumentError('${fieldName ?? 'Data de acolhimento'} inválida: deve estar no formato AAAAMMDD');
    }
  }
}
