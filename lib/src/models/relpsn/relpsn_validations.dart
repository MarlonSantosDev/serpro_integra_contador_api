/// Validações específicas para os serviços RELPSN
class RelpsnValidations {
  /// Valida o número do parcelamento
  static String? validarNumeroParcelamento(int? numeroParcelamento) {
    if (numeroParcelamento == null) {
      return 'Número do parcelamento é obrigatório';
    }

    if (numeroParcelamento <= 0) {
      return 'Número do parcelamento deve ser maior que zero';
    }

    return null;
  }

  /// Valida o ano/mês da parcela (formato AAAAMM)
  static String? validarAnoMesParcela(int? anoMesParcela) {
    if (anoMesParcela == null) {
      return 'Ano/mês da parcela é obrigatório';
    }

    final anoMesStr = anoMesParcela.toString();
    if (anoMesStr.length != 6) {
      return 'Ano/mês da parcela deve ter 6 dígitos (AAAAMM)';
    }

    final ano = int.parse(anoMesStr.substring(0, 4));
    final mes = int.parse(anoMesStr.substring(4, 6));

    if (ano < 2000 || ano > 2100) {
      return 'Ano deve estar entre 2000 e 2100';
    }

    if (mes < 1 || mes > 12) {
      return 'Mês deve estar entre 01 e 12';
    }

    return null;
  }

  /// Valida a parcela para emissão (formato AAAAMM)
  static String? validarParcelaParaEmitir(int? parcelaParaEmitir) {
    if (parcelaParaEmitir == null) {
      return 'Parcela para emitir é obrigatória';
    }

    final parcelaStr = parcelaParaEmitir.toString();
    if (parcelaStr.length != 6) {
      return 'Parcela para emitir deve ter 6 dígitos (AAAAMM)';
    }

    final ano = int.parse(parcelaStr.substring(0, 4));
    final mes = int.parse(parcelaStr.substring(4, 6));

    if (ano < 2000 || ano > 2100) {
      return 'Ano deve estar entre 2000 e 2100';
    }

    if (mes < 1 || mes > 12) {
      return 'Mês deve estar entre 01 e 12';
    }

    // Validação adicional: não pode ser uma parcela muito futura
    final hoje = DateTime.now();
    final parcelaData = DateTime(ano, mes);
    final limiteFuturo = DateTime(hoje.year + 2, hoje.month);

    if (parcelaData.isAfter(limiteFuturo)) {
      return 'Parcela não pode ser mais de 2 anos no futuro';
    }

    return null;
  }

  /// Valida o CNPJ do contribuinte
  static String? validarCnpjContribuinte(String? cnpj) {
    if (cnpj == null || cnpj.isEmpty) {
      return 'CNPJ do contribuinte é obrigatório';
    }

    // Remove caracteres não numéricos
    final cnpjLimpo = cnpj.replaceAll(RegExp(r'[^0-9]'), '');

    if (cnpjLimpo.length != 14) {
      return 'CNPJ deve ter 14 dígitos';
    }

    // Validação básica de CNPJ
    if (RegExp(r'^(\d)\1+$').hasMatch(cnpjLimpo)) {
      return 'CNPJ não pode ter todos os dígitos iguais';
    }

    return null;
  }

  /// Valida se a parcela está dentro do prazo para emissão
  static String? validarPrazoEmissaoParcela(int parcelaParaEmitir) {
    final hoje = DateTime.now();
    final parcelaStr = parcelaParaEmitir.toString();

    if (parcelaStr.length != 6) {
      return 'Formato de parcela inválido';
    }

    final ano = int.parse(parcelaStr.substring(0, 4));
    final mes = int.parse(parcelaStr.substring(4, 6));
    final parcelaData = DateTime(ano, mes);

    // Parcela do mês corrente só pode ser emitida a partir do dia 1º
    if (parcelaData.year == hoje.year && parcelaData.month == hoje.month) {
      if (hoje.day < 1) {
        return 'O DAS da parcela do mês corrente só pode ser emitido a partir do dia 1º';
      }
    }

    // Parcela futura não pode ser emitida
    if (parcelaData.isAfter(DateTime(hoje.year, hoje.month))) {
      return 'Não é possível emitir DAS para parcelas futuras';
    }

    return null;
  }

  /// Valida se o período de apuração está no formato correto
  static String? validarPeriodoApuracao(int? periodoApuracao) {
    if (periodoApuracao == null) {
      return 'Período de apuração é obrigatório';
    }

    final periodoStr = periodoApuracao.toString();
    if (periodoStr.length != 6) {
      return 'Período de apuração deve ter 6 dígitos (AAAAMM)';
    }

    final ano = int.parse(periodoStr.substring(0, 4));
    final mes = int.parse(periodoStr.substring(4, 6));

    if (ano < 2000 || ano > 2100) {
      return 'Ano deve estar entre 2000 e 2100';
    }

    if (mes < 1 || mes > 12) {
      return 'Mês deve estar entre 01 e 12';
    }

    return null;
  }

  /// Valida se a data está no formato AAAAMMDD
  static String? validarDataFormato(int? data) {
    if (data == null) {
      return 'Data é obrigatória';
    }

    final dataStr = data.toString();
    if (dataStr.length != 8) {
      return 'Data deve ter 8 dígitos (AAAAMMDD)';
    }

    final ano = int.parse(dataStr.substring(0, 4));
    final mes = int.parse(dataStr.substring(4, 6));
    final dia = int.parse(dataStr.substring(6, 8));

    if (ano < 1900 || ano > 2100) {
      return 'Ano deve estar entre 1900 e 2100';
    }

    if (mes < 1 || mes > 12) {
      return 'Mês deve estar entre 01 e 12';
    }

    if (dia < 1 || dia > 31) {
      return 'Dia deve estar entre 01 e 31';
    }

    // Validação adicional: verifica se a data é válida
    try {
      DateTime(ano, mes, dia);
    } catch (e) {
      return 'Data inválida';
    }

    return null;
  }

  /// Valida se a data está no formato AAAAMMDDHHMMSS
  static String? validarDataHoraFormato(int? dataHora) {
    if (dataHora == null) {
      return 'Data/hora é obrigatória';
    }

    final dataHoraStr = dataHora.toString();
    if (dataHoraStr.length != 14) {
      return 'Data/hora deve ter 14 dígitos (AAAAMMDDHHMMSS)';
    }

    final ano = int.parse(dataHoraStr.substring(0, 4));
    final mes = int.parse(dataHoraStr.substring(4, 6));
    final dia = int.parse(dataHoraStr.substring(6, 8));
    final hora = int.parse(dataHoraStr.substring(8, 10));
    final minuto = int.parse(dataHoraStr.substring(10, 12));
    final segundo = int.parse(dataHoraStr.substring(12, 14));

    if (ano < 1900 || ano > 2100) {
      return 'Ano deve estar entre 1900 e 2100';
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

    // Validação adicional: verifica se a data/hora é válida
    try {
      DateTime(ano, mes, dia, hora, minuto, segundo);
    } catch (e) {
      return 'Data/hora inválida';
    }

    return null;
  }

  /// Valida se o valor monetário é válido
  static String? validarValorMonetario(double? valor) {
    if (valor == null) {
      return 'Valor é obrigatório';
    }

    if (valor < 0) {
      return 'Valor não pode ser negativo';
    }

    if (valor > 999999999.99) {
      return 'Valor muito alto (máximo: 999.999.999,99)';
    }

    return null;
  }

  /// Valida se o identificador de consolidação é válido
  static String? validarIdentificadorConsolidacao(int? identificador) {
    if (identificador == null) {
      return 'Identificador de consolidação é obrigatório';
    }

    if (identificador != 1 && identificador != 2) {
      return 'Identificador de consolidação deve ser 1 ou 2';
    }

    return null;
  }

  /// Valida se o número da parcela é válido
  static String? validarNumeroParcela(String? numeroParcela) {
    if (numeroParcela == null || numeroParcela.isEmpty) {
      return 'Número da parcela é obrigatório';
    }

    if (!RegExp(r'^\d+$').hasMatch(numeroParcela)) {
      return 'Número da parcela deve conter apenas dígitos';
    }

    final numero = int.tryParse(numeroParcela);
    if (numero == null || numero <= 0) {
      return 'Número da parcela deve ser maior que zero';
    }

    return null;
  }

  /// Valida se o banco/agência está no formato correto
  static String? validarBancoAgencia(String? bancoAgencia) {
    if (bancoAgencia == null || bancoAgencia.isEmpty) {
      return 'Banco/agência é obrigatório';
    }

    // Formato esperado: número/agência (ex: 001/1234)
    if (!RegExp(r'^\d+/\d+$').hasMatch(bancoAgencia)) {
      return 'Banco/agência deve estar no formato número/agência (ex: 001/1234)';
    }

    return null;
  }

  /// Valida se o número do DAS está no formato correto
  static String? validarNumeroDas(String? numeroDas) {
    if (numeroDas == null || numeroDas.isEmpty) {
      return 'Número do DAS é obrigatório';
    }

    // DAS deve ter pelo menos 10 dígitos
    if (!RegExp(r'^\d{10,}$').hasMatch(numeroDas)) {
      return 'Número do DAS deve ter pelo menos 10 dígitos';
    }

    return null;
  }

  /// Valida se o processo está no formato correto
  static String? validarNumeroProcesso(String? processo) {
    if (processo == null || processo.isEmpty) {
      return null; // Processo pode ser vazio
    }

    // Processo deve ter pelo menos 10 dígitos
    if (!RegExp(r'^\d{10,}$').hasMatch(processo)) {
      return 'Número do processo deve ter pelo menos 10 dígitos';
    }

    return null;
  }

  /// Valida se o tributo está preenchido
  static String? validarTributo(String? tributo) {
    if (tributo == null || tributo.isEmpty) {
      return 'Tributo é obrigatório';
    }

    if (tributo.length < 2) {
      return 'Tributo deve ter pelo menos 2 caracteres';
    }

    return null;
  }

  /// Valida se o ente federado está preenchido
  static String? validarEnteFederado(String? enteFederado) {
    if (enteFederado == null || enteFederado.isEmpty) {
      return 'Ente federado é obrigatório';
    }

    if (enteFederado.length < 2) {
      return 'Ente federado deve ter pelo menos 2 caracteres';
    }

    return null;
  }

  /// Valida se a faixa de parcelas está no formato correto
  static String? validarFaixaParcelas(String? faixaParcelas) {
    if (faixaParcelas == null || faixaParcelas.isEmpty) {
      return 'Faixa de parcelas é obrigatória';
    }

    // Formato esperado: "1ª a 12ª" ou similar
    if (!RegExp(r'^\d+ª\s+a\s+\d+ª$').hasMatch(faixaParcelas)) {
      return 'Faixa de parcelas deve estar no formato "1ª a 12ª"';
    }

    return null;
  }

  /// Valida se a situação do parcelamento é válida
  static String? validarSituacaoParcelamento(String? situacao) {
    if (situacao == null || situacao.isEmpty) {
      return 'Situação do parcelamento é obrigatória';
    }

    final situacoesValidas = ['Em parcelamento', 'Parcelamento encerrado', 'Parcelamento cancelado', 'Parcelamento suspenso', 'Aguardando pagamento'];

    if (!situacoesValidas.contains(situacao)) {
      return 'Situação do parcelamento inválida';
    }

    return null;
  }
}
