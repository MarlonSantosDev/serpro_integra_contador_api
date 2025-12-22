/// Validações específicas para o sistema PGMEI (Programa Gerador do DAS para o MEI)
class PgmeiValidations {
  /// Valida período de apuração no formato AAAAMM
  ///
  /// Retorna null se válido, ou uma mensagem de erro se inválido
  static String? validarPeriodoApuracao(String? periodoApuracao) {
    if (periodoApuracao == null || periodoApuracao.isEmpty) {
      return 'Período de apuração é obrigatório';
    }

    // Verifica se tem exatamente 6 caracteres
    if (periodoApuracao.length != 6) {
      return 'Período de apuração deve ter formato AAAAMM';
    }

    // Verifica se são apenas números
    if (!RegExp(r'^\d{6}$').hasMatch(periodoApuracao)) {
      return 'Período de apuração deve conter apenas números no formato AAAAMM';
    }

    // Verifica se é um período válido
    final ano = int.parse(periodoApuracao.substring(0, 4));
    final mes = int.parse(periodoApuracao.substring(4, 6));

    if (ano < 2000 || ano > 2100) {
      return 'Ano do período deve estar entre 2000 e 2100';
    }

    if (mes < 1 || mes > 12) {
      return 'Mês do período deve estar entre 01 e 12';
    }

    return null;
  }

  /// Valida data de consolidação no formato AAAAMMDD
  ///
  /// Retorna null se válido, ou uma mensagem de erro se inválido
  static String? validarDataConsolidacao(String? dataConsolidacao) {
    if (dataConsolidacao == null || dataConsolidacao.isEmpty) {
      return 'Data de consolidação é obrigatória';
    }

    // Verifica se tem exatamente 8 caracteres
    if (dataConsolidacao.length != 8) {
      return 'Data de consolidação deve ter formato AAAAMMDD';
    }

    // Verifica se são apenas números
    if (!RegExp(r'^\d{8}$').hasMatch(dataConsolidacao)) {
      return 'Data de consolidação deve conter apenas números no formato AAAAMMDD';
    }

    // Verifica se é uma data válida
    final ano = int.parse(dataConsolidacao.substring(0, 4));
    final mes = int.parse(dataConsolidacao.substring(4, 6));
    final dia = int.parse(dataConsolidacao.substring(6, 8));

    if (ano < 1900 || ano > 2099) {
      return 'Ano da data deve estar entre 1900 e 2099';
    }

    if (mes < 1 || mes > 12) {
      return 'Mês da data deve estar entre 01 e 12';
    }

    if (dia < 1 || dia > 31) {
      return 'Dia da data deve estar entre 01 e 31';
    }

    // Tenta criar um DateTime para validar se a data é válida
    try {
      DateTime(ano, mes, dia);
    } catch (e) {
      return 'Data inválida: $dataConsolidacao';
    }

    // Verifica se não é data futura
    final data = DateTime(ano, mes, dia);
    final agora = DateTime.now();
    if (data.isAfter(agora)) {
      print('Aviso: Data de consolidação é futura ($dataConsolidacao)');
    }

    // Verifica se não é muito antiga
    final limiteAntigo = DateTime(2010, 1, 1);
    if (data.isBefore(limiteAntigo)) {
      print('Aviso: Data de consolidação é muito antiga ($dataConsolidacao)');
    }

    return null;
  }

  /// Valida lista de períodos de apuração
  ///
  /// [periodos] lista de períodos a serem validados
  /// Retorna null se válido, ou uma mensagem de erro se inválido
  static String? validarPeriodosApuracao(List<String>? periodos) {
    if (periodos == null || periodos.isEmpty) {
      return 'Lista de períodos não pode estar vazia';
    }

    // Valida cada período
    for (final periodo in periodos) {
      final validacao = validarPeriodoApuracao(periodo);
      if (validacao != null) {
        return validacao;
      }
    }

    // Verifica se há períodos duplicados
    final periodosUnicos = periodos.toSet();
    if (periodosUnicos.length != periodos.length) {
      return 'Não é permitido períodos duplicados';
    }

    return null;
  }

  /// Valida lista de informações de benefício
  ///
  /// [infoBeneficio] lista de informações de benefício a serem validadas
  /// Retorna null se válido, ou uma mensagem de erro se inválido
  static String? validarInfoBeneficio(List<dynamic>? infoBeneficio) {
    if (infoBeneficio == null || infoBeneficio.isEmpty) {
      return 'Lista de benefícios não pode estar vazia';
    }

    // Valida cada informação de benefício
    for (final info in infoBeneficio) {
      if (info.periodoApuracao is! String || info.indicadorBeneficio is! bool) {
        return 'Informação de benefício inválida';
      }

      final validacao = validarPeriodoApuracao(info.periodoApuracao);
      if (validacao != null) {
        return validacao;
      }
    }

    // Verifica se há períodos duplicados
    final periodos = infoBeneficio
        .map((info) => info.periodoApuracao)
        .cast<String>()
        .toList();
    return validarPeriodosApuracao(periodos);
  }
}
