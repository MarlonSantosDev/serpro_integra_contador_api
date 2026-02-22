/// Utilitários centralizados para trabalhar com documentos (CPF/CNPJ)
///
/// Esta classe fornece todas as funcionalidades necessárias para:
/// - Validação de CPF e CNPJ
/// - Formatação e limpeza de documentos
/// - Detecção automática de tipo de documento
/// - Validações de formato e estrutura
class ValidacoesUtils {
  /// Código do tipo documento CPF (11 dígitos).
  static const int tipoCpf = 1;

  /// Código do tipo documento CNPJ (14 dígitos).
  static const int tipoCnpj = 2;

  /// Quantidade de dígitos de um CPF.
  static const int tamanhoCpf = 11;

  /// Quantidade de dígitos de um CNPJ.
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
      // Caso quando for lista de cpfs ou cnpjs (EVENTOSATUALIZACAO)
      if (cleanNumber.length % 11 == 0) return 3;
      if (cleanNumber.length % 14 == 0) return 4;
      throw ArgumentError(
        'Número de documento inválido. Deve conter $tamanhoCpf dígitos (CPF) ou $tamanhoCnpj dígitos (CNPJ). '
        'Recebido: $cleanNumber (${cleanNumber.length} dígitos)',
      );
    }
  }

  /// Valida uma lista de documentos para garantir que todos sejam do mesmo tipo
  /// Retorna o tipo comum (1 para CPF, 2 para CNPJ) ou lança exceção se houver inconsistência
  static int validateDocumentListConsistency(List<String> documentos) {
    if (documentos.isEmpty) {
      throw ArgumentError('Lista de documentos não pode estar vazia');
    }

    int? tipoComum;

    for (int i = 0; i < documentos.length; i++) {
      final documento = documentos[i];
      final tipoAtual = detectDocumentType(documento);

      if (tipoComum == null) {
        tipoComum = tipoAtual;
      } else if (tipoComum != tipoAtual) {
        throw ArgumentError(
          'Lista de documentos inconsistente: todos os documentos devem ser do mesmo tipo (CPF ou CNPJ). '
          'Documento na posição $i ($documento) é diferente do tipo esperado.',
        );
      }
    }

    return tipoComum!; // Garantido que não será null devido à validação acima
  }

  /// Valida uma lista de CPFs
  static void validateCPFList(List<String> cpfs) {
    if (cpfs.isEmpty) {
      throw ArgumentError('Lista de CPFs não pode estar vazia');
    }

    final tipoComum = validateDocumentListConsistency(cpfs);
    if (tipoComum != tipoCpf) {
      throw ArgumentError(
        'Todos os documentos na lista devem ser CPFs válidos',
      );
    }

    // Validar cada CPF individualmente
    for (int i = 0; i < cpfs.length; i++) {
      if (!isValidCpf(cpfs[i])) {
        throw ArgumentError('CPF inválido na posição $i: ${cpfs[i]}');
      }
    }
  }

  /// Valida uma lista de CNPJs
  static void validateCNPJList(List<String> cnpjs) {
    if (cnpjs.isEmpty) {
      throw ArgumentError('Lista de CNPJs não pode estar vazia');
    }

    final tipoComum = validateDocumentListConsistency(cnpjs);
    if (tipoComum != tipoCnpj) {
      throw ArgumentError(
        'Todos os documentos na lista devem ser CNPJs válidos',
      );
    }

    // Validar cada CNPJ individualmente
    for (int i = 0; i < cnpjs.length; i++) {
      if (!isValidCnpj(cnpjs[i])) {
        throw ArgumentError('CNPJ inválido na posição $i: ${cnpjs[i]}');
      }
    }
  }

  /// Limpa a formatação do número do documento, removendo todos os caracteres não numéricos
  static String cleanDocumentNumber(String numero) {
    if (numero.isEmpty) return '';
    return numero.replaceAll(_apenasDigitos, '');
  }

  /// Valida se é um CPF válido (formato e dígitos verificadores)
  static bool isValidCpf(String cpf) {
    List<String> cnpjDeTeste = [
      '00000000000100',
      '99999999999',
      '99999999999999',
      '00000000000',
      '11111111111',
      '22222222222',
      '33333333333',
      '44444444444',
    ];
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
    List<String> cnpjDeTeste = [
      '00000000000000',
      '11111111111111',
      '22222222222222',
      '33333333333333',
      '99999999999999',
    ];
    if (cnpjDeTeste.contains(cnpj)) {
      return true;
    }
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
    List<String> cnpjDeTeste = [
      '00000000000100',
      '99999999999',
      '99999999999999',
      '00000000000000',
    ];
    if (cnpjDeTeste.contains(cnpj)) {
      return;
    }
    if (!isValidCnpj(cnpj)) {
      throw ArgumentError(
        '${fieldName ?? 'CNPJ'} inválido: deve ter exatamente 14 dígitos',
      );
    }
  }

  /// Valida e lança exceção se inválido
  static void validateCPF(String cpf, {String? fieldName}) {
    if (!isValidCpf(cpf)) {
      throw ArgumentError(
        '${fieldName ?? 'CPF'} inválido: deve ter exatamente 11 dígitos',
      );
    }
  }

  /// Valida e lança exceção se inválido
  static void validatePeriodo(String periodo, {String? fieldName}) {
    if (!isValidPeriodo(periodo)) {
      throw ArgumentError(
        '${fieldName ?? 'Período'} inválido: deve estar no formato AAAAMM (ex: 202401)',
      );
    }
  }

  /// Valida e lança exceção se inválido
  static void validateNumeroDeclaracao(String numero, {String? fieldName}) {
    if (!isValidNumeroDeclaracao(numero)) {
      throw ArgumentError(
        '${fieldName ?? 'Número da declaração'} inválido: deve ter exatamente 17 dígitos',
      );
    }
  }

  /// Valida e lança exceção se inválido
  static void validateNumeroDas(String numero, {String? fieldName}) {
    if (!isValidNumeroDas(numero)) {
      throw ArgumentError(
        '${fieldName ?? 'Número do DAS'} inválido: deve ter exatamente 17 dígitos',
      );
    }
  }

  /// Valida e lança exceção se inválido
  static void validateAno(String ano, {String? fieldName}) {
    if (!isValidAno(ano)) {
      throw ArgumentError(
        '${fieldName ?? 'Ano'} inválido: deve ter 4 dígitos (ex: 2024)',
      );
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
  static void validatePeriodoApuracao(
    String ano,
    String? mes,
    String? dia, {
    String? fieldName,
  }) {
    if (!isValidPeriodoApuracao(ano, mes, dia)) {
      final periodoStr = mes != null
          ? (dia != null ? '$ano$mes$dia' : '$ano$mes')
          : ano;
      throw ArgumentError(
        '${fieldName ?? 'Período de apuração'} inválido: $periodoStr',
      );
    }
  }

  /// Valida e lança exceção se data de acolhimento inválida
  static void validateDataAcolhimento(
    int dataAcolhimento, {
    String? fieldName,
  }) {
    if (!isValidDataAcolhimento(dataAcolhimento)) {
      throw ArgumentError(
        '${fieldName ?? 'Data de acolhimento'} inválida: deve estar no formato AAAAMMDD',
      );
    }
  }

  // ===== VALIDAÇÕES COMUNS PARA PARCELAMENTOS =====

  /// @validacoes_utils
  ///
  /// Valida um número de parcelamento
  ///
  /// **Exemplo de entrada:**
  /// ```dart
  /// validarNumeroParcelamento(123456)
  /// validarNumeroParcelamento(null)
  /// ```
  ///
  /// **Exemplo de saída:**
  /// ```dart
  /// null  // válido
  /// 'Número do parcelamento é obrigatório'  // inválido
  /// ```
  ///
  /// Retorna null se válido, ou uma mensagem de erro se inválido
  static String? validarNumeroParcelamento(int? numeroParcelamento) {
    if (numeroParcelamento == null) {
      return 'Número do parcelamento é obrigatório';
    }

    if (numeroParcelamento <= 0) {
      return 'Número do parcelamento deve ser maior que zero';
    }

    if (numeroParcelamento > 999999) {
      return 'Número do parcelamento deve ser menor que 999999';
    }

    return null;
  }

  /// @validacoes_utils
  ///
  /// Valida um ano/mês no formato AAAAMM
  ///
  /// **Exemplo de entrada:**
  /// ```dart
  /// validarAnoMes(202403)
  /// validarAnoMes(202313)  // mês inválido
  /// ```
  ///
  /// **Exemplo de saída:**
  /// ```dart
  /// null  // válido
  /// 'Mês deve estar entre 01 e 12'  // inválido
  /// ```
  ///
  /// Retorna null se válido, ou uma mensagem de erro se inválido
  static String? validarAnoMes(int? anoMes) {
    if (anoMes == null) {
      return 'Ano/mês é obrigatório';
    }

    final anoMesStr = anoMes.toString();
    if (anoMesStr.length != 6) {
      return 'Ano/mês deve estar no formato AAAAMM (ex: 202301)';
    }

    final ano = int.tryParse(anoMesStr.substring(0, 4));
    final mes = int.tryParse(anoMesStr.substring(4, 6));

    if (ano == null || mes == null) {
      return 'Ano/mês deve conter apenas números';
    }

    if (ano < 2000 || ano > 2100) {
      return 'Ano deve estar entre 2000 e 2100';
    }

    if (mes < 1 || mes > 12) {
      return 'Mês deve estar entre 01 e 12';
    }

    return null;
  }

  /// @validacoes_utils
  ///
  /// Valida uma data no formato AAAAMMDD (int)
  ///
  /// **Exemplo de entrada:**
  /// ```dart
  /// validarDataInt(20240315)
  /// validarDataInt(20240229)  // 2024 é bissexto, válido
  /// validarDataInt(20230229)  // 2023 não é bissexto, inválido
  /// ```
  ///
  /// **Exemplo de saída:**
  /// ```dart
  /// null  // válido
  /// 'Data inválida'  // inválido
  /// ```
  ///
  /// Retorna null se válido, ou uma mensagem de erro se inválido
  static String? validarDataInt(int? data) {
    if (data == null) {
      return 'Data é obrigatória';
    }

    final dataStr = data.toString();
    if (dataStr.length != 8) {
      return 'Data deve estar no formato AAAAMMDD';
    }

    final ano = int.tryParse(dataStr.substring(0, 4));
    final mes = int.tryParse(dataStr.substring(4, 6));
    final dia = int.tryParse(dataStr.substring(6, 8));

    if (ano == null || mes == null || dia == null) {
      return 'Data deve conter apenas números';
    }

    if (ano < 2000 || ano > 2100) {
      return 'Ano deve estar entre 2000 e 2100';
    }

    if (mes < 1 || mes > 12) {
      return 'Mês deve estar entre 01 e 12';
    }

    if (dia < 1 || dia > 31) {
      return 'Dia deve estar entre 01 e 31';
    }

    // Verifica se a data é válida
    try {
      DateTime(ano, mes, dia);
    } catch (e) {
      return 'Data inválida';
    }

    return null;
  }

  /// Valida uma data/hora no formato AAAAMMDDHHMMSS (int)
  /// Retorna null se válido, ou uma mensagem de erro se inválido
  static String? validarDataHoraInt(int? dataHora) {
    if (dataHora == null) {
      return 'Data/hora é obrigatória';
    }

    final dataHoraStr = dataHora.toString();
    if (dataHoraStr.length != 14) {
      return 'Data/hora deve ter 14 dígitos (AAAAMMDDHHMMSS)';
    }

    final ano = int.tryParse(dataHoraStr.substring(0, 4));
    final mes = int.tryParse(dataHoraStr.substring(4, 6));
    final dia = int.tryParse(dataHoraStr.substring(6, 8));
    final hora = int.tryParse(dataHoraStr.substring(8, 10));
    final minuto = int.tryParse(dataHoraStr.substring(10, 12));
    final segundo = int.tryParse(dataHoraStr.substring(12, 14));

    if (ano == null ||
        mes == null ||
        dia == null ||
        hora == null ||
        minuto == null ||
        segundo == null) {
      return 'Data/hora deve conter apenas números';
    }

    if (ano < 2000 || ano > 2100) {
      return 'Ano deve estar entre 2000 e 2100';
    }

    if (mes < 1 || mes > 12) {
      return 'Mês deve estar entre 01 e 12';
    }

    if (dia < 1 || dia > 31) {
      return 'Dia deve estar entre 01 e 31';
    }

    if (hora < 0 || hora > 23) {
      return 'Hora deve estar entre 00 e 23';
    }

    if (minuto < 0 || minuto > 59) {
      return 'Minuto deve estar entre 00 e 59';
    }

    if (segundo < 0 || segundo > 59) {
      return 'Segundo deve estar entre 00 e 59';
    }

    // Validação básica de data/hora válida
    try {
      DateTime(ano, mes, dia, hora, minuto, segundo);
    } catch (e) {
      return 'Data/hora inválida';
    }

    return null;
  }

  /// @validacoes_utils
  ///
  /// Valida um valor monetário
  ///
  /// **Exemplo de entrada:**
  /// ```dart
  /// validarValorMonetario(1234.56)
  /// validarValorMonetario(-10.00)  // negativo
  /// validarValorMonetario(1000000000.00)  // muito alto
  /// ```
  ///
  /// **Exemplo de saída:**
  /// ```dart
  /// null  // válido
  /// 'Valor não pode ser negativo'  // inválido
  /// 'Valor não pode ser maior que R$ 999.999.999,99'  // inválido
  /// ```
  ///
  /// Retorna null se válido, ou uma mensagem de erro se inválido
  static String? validarValorMonetario(double? valor) {
    if (valor == null) {
      return 'Valor é obrigatório';
    }

    if (valor < 0) {
      return 'Valor não pode ser negativo';
    }

    if (valor > 999999999.99) {
      return 'Valor não pode ser maior que R\$ 999.999.999,99';
    }

    return null;
  }

  /// @validacoes_utils
  ///
  /// Valida um CNPJ retornando mensagem de erro ou null
  ///
  /// **Exemplo de entrada:**
  /// ```dart
  /// validarCnpjContribuinte('12345678000195')
  /// validarCnpjContribuinte('12.345.678/0001-95')  // aceita formatado
  /// validarCnpjContribuinte('123456780001')  // tamanho incorreto
  /// ```
  ///
  /// **Exemplo de saída:**
  /// ```dart
  /// null  // válido
  /// 'CNPJ inválido'  // inválido
  /// ```
  ///
  /// Retorna null se válido, ou uma mensagem de erro se inválido
  static String? validarCnpjContribuinte(String? cnpj) {
    if (cnpj == null || cnpj.isEmpty) {
      return 'CNPJ do contribuinte é obrigatório';
    }

    if (!isValidCnpj(cnpj)) {
      return 'CNPJ inválido';
    }

    return null;
  }
}
