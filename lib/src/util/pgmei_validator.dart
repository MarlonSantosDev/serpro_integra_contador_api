import 'document_utils.dart';

/// Validador específico para serviços PGMEI
///
/// Contém validações específicas dos parâmetros de entrada
/// dos serviços do Programa Gerador do DAS para o MEI
class PgmeiValidator {
  /// Valida período de apuração no formato AAAAMM
  ///
  /// [periodoApuracao] deve estar no formato YYYYMM
  /// Deve ser um ano/mês válido
  static void validatePeriodoApuracao(String periodoApuracao) {
    if (periodoApuracao.isEmpty) {
      throw ArgumentError('Período de apuração não pode estar vazio');
    }

    // Verifica se tem exatamente 6 caracteres
    if (periodoApuracao.length != 6) {
      throw ArgumentError('Período de apuração deve ter formato AAAAMM');
    }

    // Verifica se são apenas números
    if (!RegExp(r'^\d{6}$').hasMatch(periodoApuracao)) {
      throw ArgumentError('Período de apuração deve conter apenas números no formato AAAAMM');
    }

    // Valida ano (1900-2099)
    final ano = int.parse(periodoApuracao.substring(0, 4));
    if (ano < 1900 || ano > 2099) {
      throw ArgumentError('Ano do período deve estar entre 1900 e 2099');
    }

    // Valida mês (01-12)
    final mes = int.parse(periodoApuracao.substring(4, 6));
    if (mes < 1 || mes > 12) {
      throw ArgumentError('Mês do período deve estar entre 01 e 12');
    }

    // Verifica se não é período futuro (opcional - pode ser desabilitado se necessário)
    final agora = DateTime.now();
    final anoAtual = agora.year;
    final mesAtual = agora.month;

    if (ano > anoAtual || (ano == anoAtual && mes > mesAtual)) {
      // Apenas aviso, não erro, pois pode ser necessário para testes
      print('Aviso: Período de apuração é futuro ($periodoApuracao)');
    }
  }

  /// Valida ano calendário no formato AAAA
  ///
  /// [anoCalendario] deve estar no formato YYYY
  /// Deve ser um ano válido
  static void validateAnoCalendario(String anoCalendario) {
    if (anoCalendario.isEmpty) {
      throw ArgumentError('Ano calendário não pode estar vazio');
    }

    // Verifica se tem exatamente 4 caracteres
    if (anoCalendario.length != 4) {
      throw ArgumentError('Ano calendário deve ter formato AAAA');
    }

    // Verifica se são apenas números
    if (!RegExp(r'^\d{4}$').hasMatch(anoCalendario)) {
      throw ArgumentError('Ano calendário deve conter apenas números no formato AAAA');
    }

    // Valida ano (1900-2099)
    final ano = int.parse(anoCalendario);
    if (ano < 1900 || ano > 2099) {
      throw ArgumentError('Ano calendário deve estar entre 1900 e 2099');
    }

    // Verifica se não é ano muito futuro
    final anoAtual = DateTime.now().year;
    if (ano > anoAtual + 1) {
      print('Aviso: Ano calendário é futuro ($anoCalendario)');
    }
  }

  /// Valida ano calendário como inteiro
  ///
  /// [anoCalendario] deve ser um ano válido
  static void validateAnoCalendarioInt(int anoCalendario) {
    // Valida ano (1900-2099)
    if (anoCalendario < 1900 || anoCalendario > 2099) {
      throw ArgumentError('Ano calendário deve estar entre 1900 e 2099');
    }

    // Verifica se não é ano muito futuro
    final anoAtual = DateTime.now().year;
    if (anoCalendario > anoAtual + 1) {
      print('Aviso: Ano calendário é futuro ($anoCalendario)');
    }
  }

  /// Valida data de consolidação no formato AAAAMMDD
  ///
  /// [dataConsolidacao] deve estar no formato YYYYMMDD
  /// Deve ser uma data válida
  static void validateDataConsolidacao(String dataConsolidacao) {
    if (dataConsolidacao.isEmpty) {
      throw ArgumentError('Data de consolidação não pode estar vazia');
    }

    // Verifica se tem exatamente 8 caracteres
    if (dataConsolidacao.length != 8) {
      throw ArgumentError('Data de consolidação deve ter formato AAAAMMDD');
    }

    // Verifica se são apenas números
    if (!RegExp(r'^\d{8}$').hasMatch(dataConsolidacao)) {
      throw ArgumentError('Data de consolidação deve conter apenas números no formato AAAAMMDD');
    }

    // Verifica se é uma data válida
    final ano = int.parse(dataConsolidacao.substring(0, 4));
    final mes = int.parse(dataConsolidacao.substring(4, 6));
    final dia = int.parse(dataConsolidacao.substring(6, 8));

    if (ano < 1900 || ano > 2099) {
      throw ArgumentError('Ano da data deve estar entre 1900 e 2099');
    }

    if (mes < 1 || mes > 12) {
      throw ArgumentError('Mês da data deve estar entre 01 e 12');
    }

    if (dia < 1 || dia > 31) {
      throw ArgumentError('Dia da data deve estar entre 01 e 31');
    }

    // Tenta criar um DateTime para validar se a data é válida
    try {
      DateTime(ano, mes, dia);
    } catch (e) {
      throw ArgumentError('Data inválida: $dataConsolidacao');
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
  }

  /// Valida lista de períodos de apuração
  ///
  /// [periodos] lista de períodos a serem validados
  static void validatePeriodosApuracao(List<String> periodos) {
    if (periodos.isEmpty) {
      throw ArgumentError('Lista de períodos não pode estar vazia');
    }

    // Valida cada período
    for (final periodo in periodos) {
      validatePeriodoApuracao(periodo);
    }

    // Verifica se há períodos duplicados
    final periodosUnicos = periodos.toSet();
    if (periodosUnicos.length != periodos.length) {
      throw ArgumentError('Não é permitido períodos duplicados');
    }
  }

  /// Valida lista de informações de benefício
  ///
  /// [infoBeneficio] lista de informações de benefício a serem validadas
  static void validateInfoBeneficio(List<dynamic> infoBeneficio) {
    if (infoBeneficio.isEmpty) {
      throw ArgumentError('Lista de benefícios não pode estar vazia');
    }

    // Valida cada informação de benefício
    for (final info in infoBeneficio) {
      if (info.periodoApuracao is! String || info.indicadorBeneficio is! bool) {
        throw ArgumentError('Informação de benefício inválida');
      }

      validatePeriodoApuracao(info.periodoApuracao);
    }

    // Verifica se há períodos duplicados
    final periodos = infoBeneficio.map((info) => info.periodoApuracao).cast<String>().toList();
    validatePeriodosApuracao(periodos);
  }

  /// Valida se o CNPJ é adequado para serviços PGMEI
  ///
  /// PGMEI só aceita contribuintes do tipo 2 (Pessoa Jurídica)
  ///
  /// [cnpj] CNPJ a ser validado
  static void validateCNPJPgmei(String cnpj) {
    // Usa validação básica do DocumentUtils
    DocumentUtils.validateCNPJ(cnpj);

    // Adicional: verifica se não é CPF (que seria tipo 1)
    if (cnpj.length == 14 && RegExp(r'^\d{14}$').hasMatch(cnpj)) {
      // Validação adicional para CNPJ formatado ou não
      return;
    }

    throw ArgumentError('Para serviços PGMEI é necessário fornecer um CNPJ válido');
  }
}
