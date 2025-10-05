import '../../util/validations_utils.dart';

/// Validações específicas para o sistema PARCSN
class PertsnValidations {
  /// Valida um número de parcelamento
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

  /// Valida um ano/mês de parcela no formato AAAAMM
  ///
  /// Retorna null se válido, ou uma mensagem de erro se inválido
  static String? validarAnoMesParcela(int? anoMesParcela) {
    if (anoMesParcela == null) {
      return 'Ano/mês da parcela é obrigatório';
    }

    final anoMesStr = anoMesParcela.toString();
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

  /// Valida uma parcela para emissão no formato AAAAMM
  ///
  /// Retorna null se válido, ou uma mensagem de erro se inválido
  static String? validarParcelaParaEmitir(int? parcelaParaEmitir) {
    if (parcelaParaEmitir == null) {
      return 'Parcela para emitir é obrigatória';
    }

    final validacaoAnoMes = validarAnoMesParcela(parcelaParaEmitir);
    if (validacaoAnoMes != null) {
      return validacaoAnoMes;
    }

    return null;
  }

  /// Valida o prazo para emissão de uma parcela
  ///
  /// Retorna null se válido, ou uma mensagem de erro se inválido
  static String? validarPrazoEmissaoParcela(int parcelaParaEmitir) {
    final validacaoBasica = validarParcelaParaEmitir(parcelaParaEmitir);
    if (validacaoBasica != null) {
      return validacaoBasica;
    }

    final anoMesStr = parcelaParaEmitir.toString();
    final ano = int.parse(anoMesStr.substring(0, 4));
    final mes = int.parse(anoMesStr.substring(4, 6));

    final dataParcela = DateTime(ano, mes);
    final hoje = DateTime.now();
    final dataLimite = DateTime(hoje.year, hoje.month + 3); // 3 meses no futuro

    if (dataParcela.isAfter(dataLimite)) {
      return 'Parcela não pode ser emitida com mais de 3 meses de antecedência';
    }

    // Verificar se não é muito antiga (mais de 5 anos)
    final dataLimiteAntiga = DateTime(hoje.year - 5, hoje.month);
    if (dataParcela.isBefore(dataLimiteAntiga)) {
      return 'Parcela muito antiga para emissão (mais de 5 anos)';
    }

    return null;
  }

  /// Valida o CNPJ do contribuinte
  ///
  /// Retorna null se válido, ou uma mensagem de erro se inválido
  static String? validarCnpjContribuinte(String? cnpj) {
    if (cnpj == null || cnpj.isEmpty) {
      return 'CNPJ do contribuinte é obrigatório';
    }

    // Usa a validação centralizada do DocumentUtils
    if (!DocumentUtils.isValidCnpj(cnpj)) {
      return 'CNPJ inválido';
    }

    return null;
  }

  /// Valida o tipo de contribuinte
  ///
  /// Retorna null se válido, ou uma mensagem de erro se inválido
  static String? validarTipoContribuinte(int? tipoContribuinte) {
    if (tipoContribuinte == null) {
      return 'Tipo do contribuinte é obrigatório';
    }

    if (tipoContribuinte != 2) {
      return 'PARCSN aceita apenas contribuintes do tipo 2 (Pessoa Jurídica)';
    }

    return null;
  }

  /// Valida se uma data está no formato correto (AAAAMMDD)
  static String? validarDataFormato(int? data) {
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

  /// Valida se um valor monetário é válido
  static String? validarValorMonetario(double? valor) {
    if (valor == null) {
      return 'Valor é obrigatório';
    }

    if (valor < 0) {
      return 'Valor não pode ser negativo';
    }

    if (valor > 999999999.99) {
      return 'Valor muito alto (máximo: R\$ 999.999.999,99)';
    }

    return null;
  }

  /// Valida se uma competência está no formato correto (AAAAMM)
  static String? validarCompetencia(String? competencia) {
    if (competencia == null || competencia.isEmpty) {
      return 'Competência é obrigatória';
    }

    if (competencia.length != 6) {
      return 'Competência deve estar no formato AAAAMM';
    }

    final ano = int.tryParse(competencia.substring(0, 4));
    final mes = int.tryParse(competencia.substring(4, 6));

    if (ano == null || mes == null) {
      return 'Competência deve conter apenas números';
    }

    if (ano < 2000 || ano > 2100) {
      return 'Ano da competência deve estar entre 2000 e 2100';
    }

    if (mes < 1 || mes > 12) {
      return 'Mês da competência deve estar entre 01 e 12';
    }

    return null;
  }
}
