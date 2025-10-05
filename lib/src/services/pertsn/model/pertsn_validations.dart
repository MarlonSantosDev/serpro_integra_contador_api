import '../../../util/validacoes_utils.dart';

/// Validações específicas para os serviços PERTSN
class PertsnValidations {
  /// Valida o número do parcelamento
  static String? validarNumeroParcelamento(int? numeroParcelamento) {
    return ValidacoesUtils.validarNumeroParcelamento(numeroParcelamento);
  }

  /// Valida o ano/mês da parcela (formato AAAAMM)
  static String? validarAnoMesParcela(int? anoMesParcela) {
    return ValidacoesUtils.validarAnoMes(anoMesParcela);
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
    return ValidacoesUtils.validarCnpjContribuinte(cnpj);
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

  /// Valida se o código de receita está no formato correto
  static String? validarCodigoReceita(String? codigoReceita) {
    if (codigoReceita == null || codigoReceita.isEmpty) {
      return 'Código de receita é obrigatório';
    }

    // Código de receita deve ter pelo menos 3 dígitos
    if (!RegExp(r'^\d{3,}$').hasMatch(codigoReceita)) {
      return 'Código de receita deve ter pelo menos 3 dígitos';
    }

    return null;
  }

  /// Valida se a descrição da receita está preenchida
  static String? validarDescricaoReceita(String? descricaoReceita) {
    if (descricaoReceita == null || descricaoReceita.isEmpty) {
      return 'Descrição da receita é obrigatória';
    }

    if (descricaoReceita.length < 3) {
      return 'Descrição da receita deve ter pelo menos 3 caracteres';
    }

    return null;
  }

  /// Valida se o código de barras está no formato correto
  static String? validarCodigoBarras(String? codigoBarras) {
    if (codigoBarras == null || codigoBarras.isEmpty) {
      return 'Código de barras é obrigatório';
    }

    // Código de barras deve ter pelo menos 20 dígitos
    if (!RegExp(r'^\d{20,}$').hasMatch(codigoBarras)) {
      return 'Código de barras deve ter pelo menos 20 dígitos';
    }

    return null;
  }

  /// Valida se o PDF Base64 está no formato correto
  static String? validarPdfBase64(String? pdfBase64) {
    if (pdfBase64 == null || pdfBase64.isEmpty) {
      return 'PDF Base64 é obrigatório';
    }

    // Verifica se é um Base64 válido
    try {
      Uri.dataFromString(pdfBase64, mimeType: 'application/pdf');
    } catch (e) {
      return 'PDF Base64 inválido';
    }

    return null;
  }

  /// Valida se o tipo de contribuinte é válido para PERTSN
  static String? validarTipoContribuinte(int? tipoContribuinte) {
    if (tipoContribuinte == null) {
      return 'Tipo de contribuinte é obrigatório';
    }

    // PERTSN aceita apenas tipo 2 (Pessoa Jurídica)
    if (tipoContribuinte != 2) {
      return 'PERTSN aceita apenas contribuintes do tipo 2 (Pessoa Jurídica)';
    }

    return null;
  }

  /// Valida se o sistema é válido para PERTSN
  static String? validarSistema(String? sistema) {
    if (sistema == null || sistema.isEmpty) {
      return 'Sistema é obrigatório';
    }

    if (sistema != 'PERTSN') {
      return 'Sistema deve ser PERTSN';
    }

    return null;
  }

  /// Valida se o serviço é válido para PERTSN
  static String? validarServico(String? servico) {
    if (servico == null || servico.isEmpty) {
      return 'Serviço é obrigatório';
    }

    final servicosValidos = ['PEDIDOSPARC183', 'OBTERPARC184', 'PARCELASPARAGERAR182', 'DETPAGTOPARC185', 'GERARDAS181'];

    if (!servicosValidos.contains(servico)) {
      return 'Serviço inválido para PERTSN';
    }

    return null;
  }

  /// Valida se a versão do sistema é válida
  static String? validarVersaoSistema(String? versaoSistema) {
    if (versaoSistema == null || versaoSistema.isEmpty) {
      return 'Versão do sistema é obrigatória';
    }

    if (versaoSistema != '1.0') {
      return 'Versão do sistema deve ser 1.0';
    }

    return null;
  }
}
