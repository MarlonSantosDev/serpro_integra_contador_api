import '../../../util/validacoes_utils.dart';

class ParcmeiValidations {
  /// Valida um número de parcelamento
  static String? validarNumeroParcelamento(int? numeroParcelamento) {
    return ValidacoesUtils.validarNumeroParcelamento(numeroParcelamento);
  }

  /// Valida um ano/mês de parcela no formato AAAAMM
  static String? validarAnoMesParcela(int? anoMesParcela) {
    return ValidacoesUtils.validarAnoMes(anoMesParcela);
  }

  /// Valida uma parcela para emissão no formato AAAAMM
  static String? validarParcelaParaEmitir(int? parcelaParaEmitir) {
    if (parcelaParaEmitir == null) {
      return 'Parcela para emitir é obrigatória';
    }

    return validarAnoMesParcela(parcelaParaEmitir);
  }

  /// Valida o prazo para emissão de uma parcela
  static String? validarPrazoEmissaoParcela(int parcelaParaEmitir) {
    final validacao = validarParcelaParaEmitir(parcelaParaEmitir);
    if (validacao != null) return validacao;

    final anoMesStr = parcelaParaEmitir.toString();
    final ano = int.parse(anoMesStr.substring(0, 4));
    final mes = int.parse(anoMesStr.substring(4, 6));

    final agora = DateTime.now();
    final anoAtual = agora.year;
    final mesAtual = agora.month;

    // Parcela não pode ser de mais de 2 anos no futuro
    if (ano > anoAtual + 2) {
      return 'Parcela não pode ser de mais de 2 anos no futuro';
    }

    // Parcela não pode ser de mais de 24 meses no futuro
    final mesesFuturo = (ano - anoAtual) * 12 + (mes - mesAtual);
    if (mesesFuturo > 24) {
      return 'Parcela não pode ser de mais de 24 meses no futuro';
    }

    return null;
  }

  /// Valida o CNPJ do contribuinte
  static String? validarCnpjContribuinte(String? cnpj) {
    return ValidacoesUtils.validarCnpjContribuinte(cnpj);
  }

  /// Valida o tipo de contribuinte
  static String? validarTipoContribuinte(int? tipoContribuinte) {
    if (tipoContribuinte == null) {
      return 'Tipo de contribuinte é obrigatório';
    }

    if (tipoContribuinte != 2) {
      return 'PARCMEI aceita apenas contribuintes do tipo 2 (Pessoa Jurídica)';
    }

    return null;
  }

  /// Valida se a parcela está disponível para emissão
  static String? validarParcelaDisponivelParaEmissao(int parcelaParaEmitir) {
    final validacao = validarParcelaParaEmitir(parcelaParaEmitir);
    if (validacao != null) return validacao;

    final anoMesStr = parcelaParaEmitir.toString();
    final ano = int.parse(anoMesStr.substring(0, 4));

    final agora = DateTime.now();
    final anoAtual = agora.year;

    // Parcela não pode ser de mais de 1 ano no passado
    if (ano < anoAtual - 1) {
      return 'Parcela não pode ser de mais de 1 ano no passado';
    }

    return null;
  }

  /// Valida um período de apuração no formato AAAAMM
  static String? validarPeriodoApuracao(int? periodoApuracao) {
    if (periodoApuracao == null) {
      return 'Período de apuração é obrigatório';
    }

    final periodoStr = periodoApuracao.toString();
    if (periodoStr.length != 6) {
      return 'Período de apuração deve ter 6 dígitos (AAAAMM)';
    }

    final ano = int.tryParse(periodoStr.substring(0, 4));
    final mes = int.tryParse(periodoStr.substring(4, 6));

    if (ano == null || mes == null) {
      return 'Período de apuração deve conter apenas números';
    }

    if (ano < 2000 || ano > 2100) {
      return 'Ano deve estar entre 2000 e 2100';
    }

    if (mes < 1 || mes > 12) {
      return 'Mês deve estar entre 01 e 12';
    }

    return null;
  }

  /// Valida uma data no formato AAAAMMDD
  static String? validarDataFormato(int? data) {
    return ValidacoesUtils.validarDataInt(data);
  }

  /// Valida uma data/hora no formato AAAAMMDDHHMMSS
  static String? validarDataHoraFormato(int? dataHora) {
    return ValidacoesUtils.validarDataHoraInt(dataHora);
  }

  /// Valida um valor monetário
  static String? validarValorMonetario(double? valor) {
    return ValidacoesUtils.validarValorMonetario(valor);
  }

  /// Valida um número de parcela
  static String? validarNumeroParcela(String? numeroParcela) {
    if (numeroParcela == null || numeroParcela.isEmpty) {
      return 'Número da parcela é obrigatório';
    }

    if (numeroParcela.length > 10) {
      return 'Número da parcela não pode ter mais de 10 caracteres';
    }

    return null;
  }

  /// Valida um banco/agência
  static String? validarBancoAgencia(String? bancoAgencia) {
    if (bancoAgencia == null || bancoAgencia.isEmpty) {
      return 'Banco/agência é obrigatório';
    }

    if (bancoAgencia.length > 20) {
      return 'Banco/agência não pode ter mais de 20 caracteres';
    }

    return null;
  }

  /// Valida um número de DAS
  static String? validarNumeroDas(String? numeroDas) {
    if (numeroDas == null || numeroDas.isEmpty) {
      return 'Número do DAS é obrigatório';
    }

    if (numeroDas.length < 10 || numeroDas.length > 20) {
      return 'Número do DAS deve ter entre 10 e 20 caracteres';
    }

    return null;
  }

  /// Valida um número de processo
  static String? validarNumeroProcesso(String? processo) {
    if (processo == null || processo.isEmpty) {
      return 'Número do processo é obrigatório';
    }

    if (processo.length > 30) {
      return 'Número do processo não pode ter mais de 30 caracteres';
    }

    return null;
  }

  /// Valida um tributo
  static String? validarTributo(String? tributo) {
    if (tributo == null || tributo.isEmpty) {
      return 'Tributo é obrigatório';
    }

    if (tributo.length > 50) {
      return 'Tributo não pode ter mais de 50 caracteres';
    }

    return null;
  }

  /// Valida um ente federado
  static String? validarEnteFederado(String? enteFederado) {
    if (enteFederado == null || enteFederado.isEmpty) {
      return 'Ente federado é obrigatório';
    }

    if (enteFederado.length > 100) {
      return 'Ente federado não pode ter mais de 100 caracteres';
    }

    return null;
  }

  /// Valida uma situação de parcelamento
  static String? validarSituacaoParcelamento(String? situacao) {
    if (situacao == null || situacao.isEmpty) {
      return 'Situação do parcelamento é obrigatória';
    }

    if (situacao.length > 100) {
      return 'Situação do parcelamento não pode ter mais de 100 caracteres';
    }

    return null;
  }

  /// Valida um PDF Base64
  static String? validarPdfBase64(String? pdfBase64) {
    if (pdfBase64 == null || pdfBase64.isEmpty) {
      return 'PDF Base64 é obrigatório';
    }

    if (pdfBase64.length < 100) {
      return 'PDF Base64 parece muito pequeno';
    }

    if (pdfBase64.length > 10 * 1024 * 1024) {
      // 10MB
      return 'PDF Base64 é muito grande (máximo 10MB)';
    }

    // Verifica se é Base64 válido
    try {
      // Tenta decodificar uma pequena parte
      pdfBase64.substring(0, pdfBase64.length > 100 ? 100 : pdfBase64.length);
      // Se não conseguir decodificar, não é Base64 válido
      return null;
    } catch (e) {
      return 'PDF Base64 inválido';
    }
  }

  /// Valida um sistema
  static String? validarSistema(String? sistema) {
    if (sistema == null || sistema.isEmpty) {
      return 'Sistema é obrigatório';
    }

    if (sistema != 'PARCMEI') {
      return 'Sistema deve ser PARCMEI';
    }

    return null;
  }

  /// Valida um serviço
  static String? validarServico(String? servico) {
    if (servico == null || servico.isEmpty) {
      return 'Serviço é obrigatório';
    }

    final servicosValidos = ['PEDIDOSPARC203', 'OBTERPARC204', 'PARCELASPARAGERAR202', 'DETPAGTOPARC205', 'GERARDAS201'];

    if (!servicosValidos.contains(servico)) {
      return 'Serviço inválido para PARCMEI';
    }

    return null;
  }

  /// Valida uma versão de sistema
  static String? validarVersaoSistema(String? versaoSistema) {
    if (versaoSistema == null || versaoSistema.isEmpty) {
      return 'Versão do sistema é obrigatória';
    }

    if (versaoSistema != '1.0') {
      return 'Versão do sistema deve ser 1.0';
    }

    return null;
  }

  /// Valida um número de parcelamento no formato específico do PARCMEI
  static String? validarNumeroParcelamentoFormato(int? numeroParcelamento) {
    final validacao = validarNumeroParcelamento(numeroParcelamento);
    if (validacao != null) return validacao;

    // PARCMEI aceita parcelamentos de 1 a 999999
    if (numeroParcelamento! < 1 || numeroParcelamento > 999999) {
      return 'Número do parcelamento deve estar entre 1 e 999999';
    }

    return null;
  }

  /// Valida um período de apuração dentro de um range válido
  static String? validarPeriodoApuracaoRange(int? periodoApuracao) {
    final validacao = validarPeriodoApuracao(periodoApuracao);
    if (validacao != null) return validacao;

    final anoMesStr = periodoApuracao.toString();
    final ano = int.parse(anoMesStr.substring(0, 4));

    final agora = DateTime.now();
    final anoAtual = agora.year;

    // Período não pode ser de mais de 10 anos no passado
    if (ano < anoAtual - 10) {
      return 'Período não pode ser de mais de 10 anos no passado';
    }

    // Período não pode ser de mais de 1 ano no futuro
    if (ano > anoAtual + 1) {
      return 'Período não pode ser de mais de 1 ano no futuro';
    }

    return null;
  }
}
