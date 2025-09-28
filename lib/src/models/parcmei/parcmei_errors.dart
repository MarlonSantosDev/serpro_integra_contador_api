class ParcmeiErrorInfo {
  final String codigo;
  final String descricao;
  final String categoria;
  final String? solucao;

  ParcmeiErrorInfo({
    required this.codigo,
    required this.descricao,
    required this.categoria,
    this.solucao,
  });
}

class ParcmeiErrorAnalysis {
  final String codigo;
  final String mensagem;
  final ParcmeiErrorInfo? errorInfo;
  final String categoria;
  final String? solucao;

  ParcmeiErrorAnalysis({
    required this.codigo,
    required this.mensagem,
    this.errorInfo,
    required this.categoria,
    this.solucao,
  });

  bool get isKnownError => errorInfo != null;
  bool get isSucesso => categoria == 'Sucesso';
  bool get isErro => categoria == 'Erro';
  bool get isAviso => categoria == 'Aviso';
  bool get isEntradaIncorreta => categoria == 'Entrada Incorreta';
}

class ParcmeiErrors {
  static final Map<String, ParcmeiErrorInfo> _errors = {
    // Sucessos
    '[Sucesso-PARCMEI]': ParcmeiErrorInfo(
      codigo: '[Sucesso-PARCMEI]',
      descricao: 'Requisição efetuada com sucesso.',
      categoria: 'Sucesso',
    ),

    // Erros de entrada incorreta
    '[ERRO-ENTRADA-INCORRETA-001]': ParcmeiErrorInfo(
      codigo: '[ERRO-ENTRADA-INCORRETA-001]',
      descricao: 'Número do parcelamento inválido.',
      categoria: 'Entrada Incorreta',
      solucao: 'Verifique se o número do parcelamento está correto e existe.',
    ),
    '[ERRO-ENTRADA-INCORRETA-002]': ParcmeiErrorInfo(
      codigo: '[ERRO-ENTRADA-INCORRETA-002]',
      descricao: 'Ano/mês da parcela inválido.',
      categoria: 'Entrada Incorreta',
      solucao: 'Verifique se o ano/mês está no formato AAAAMM e é válido.',
    ),
    '[ERRO-ENTRADA-INCORRETA-003]': ParcmeiErrorInfo(
      codigo: '[ERRO-ENTRADA-INCORRETA-003]',
      descricao: 'Parcela para emitir inválida.',
      categoria: 'Entrada Incorreta',
      solucao: 'Verifique se a parcela está disponível para emissão.',
    ),
    '[ERRO-ENTRADA-INCORRETA-004]': ParcmeiErrorInfo(
      codigo: '[ERRO-ENTRADA-INCORRETA-004]',
      descricao: 'CNPJ do contribuinte inválido.',
      categoria: 'Entrada Incorreta',
      solucao: 'Verifique se o CNPJ está correto e é válido.',
    ),

    // Erros gerais
    '[ERRO-PARCMEI-001]': ParcmeiErrorInfo(
      codigo: '[ERRO-PARCMEI-001]',
      descricao: 'Parcelamento não encontrado.',
      categoria: 'Erro',
      solucao: 'Verifique se o parcelamento existe e está ativo.',
    ),
    '[ERRO-PARCMEI-002]': ParcmeiErrorInfo(
      codigo: '[ERRO-PARCMEI-002]',
      descricao: 'Parcela não encontrada.',
      categoria: 'Erro',
      solucao: 'Verifique se a parcela existe e está disponível.',
    ),
    '[ERRO-PARCMEI-003]': ParcmeiErrorInfo(
      codigo: '[ERRO-PARCMEI-003]',
      descricao: 'Parcela já foi emitida.',
      categoria: 'Erro',
      solucao: 'Esta parcela já possui DAS emitido.',
    ),
    '[ERRO-PARCMEI-004]': ParcmeiErrorInfo(
      codigo: '[ERRO-PARCMEI-004]',
      descricao: 'Parcela não está disponível para emissão.',
      categoria: 'Erro',
      solucao: 'Verifique se a parcela está dentro do prazo para emissão.',
    ),
    '[ERRO-PARCMEI-005]': ParcmeiErrorInfo(
      codigo: '[ERRO-PARCMEI-005]',
      descricao: 'Parcelamento não está ativo.',
      categoria: 'Erro',
      solucao: 'O parcelamento deve estar ativo para realizar operações.',
    ),
    '[ERRO-PARCMEI-006]': ParcmeiErrorInfo(
      codigo: '[ERRO-PARCMEI-006]',
      descricao: 'Contribuinte não possui parcelamentos.',
      categoria: 'Erro',
      solucao: 'O contribuinte não possui parcelamentos PARCMEI.',
    ),
    '[ERRO-PARCMEI-007]': ParcmeiErrorInfo(
      codigo: '[ERRO-PARCMEI-007]',
      descricao: 'Erro ao gerar DAS.',
      categoria: 'Erro',
      solucao: 'Tente novamente em alguns minutos.',
    ),
    '[ERRO-PARCMEI-008]': ParcmeiErrorInfo(
      codigo: '[ERRO-PARCMEI-008]',
      descricao: 'Sistema temporariamente indisponível.',
      categoria: 'Erro',
      solucao: 'Tente novamente em alguns minutos.',
    ),

    // Avisos
    '[AVISO-PARCMEI-001]': ParcmeiErrorInfo(
      codigo: '[AVISO-PARCMEI-001]',
      descricao: 'Parcela próxima do vencimento.',
      categoria: 'Aviso',
      solucao: 'Considere pagar a parcela antes do vencimento.',
    ),
    '[AVISO-PARCMEI-002]': ParcmeiErrorInfo(
      codigo: '[AVISO-PARCMEI-002]',
      descricao: 'Parcelamento próximo do prazo limite.',
      categoria: 'Aviso',
      solucao: 'Verifique o status do parcelamento.',
    ),
  };

  static ParcmeiErrorAnalysis analyzeError(String codigo, String mensagem) {
    final errorInfo = _errors[codigo];

    if (errorInfo != null) {
      return ParcmeiErrorAnalysis(
        codigo: codigo,
        mensagem: mensagem,
        errorInfo: errorInfo,
        categoria: errorInfo.categoria,
        solucao: errorInfo.solucao,
      );
    }

    // Análise baseada no conteúdo da mensagem
    String categoria = 'Erro Desconhecido';
    String? solucao;

    if (mensagem.toLowerCase().contains('sucesso')) {
      categoria = 'Sucesso';
    } else if (mensagem.toLowerCase().contains('aviso')) {
      categoria = 'Aviso';
    } else if (mensagem.toLowerCase().contains('inválido') ||
        mensagem.toLowerCase().contains('incorreto') ||
        mensagem.toLowerCase().contains('formato')) {
      categoria = 'Entrada Incorreta';
      solucao = 'Verifique os dados de entrada e tente novamente.';
    } else if (mensagem.toLowerCase().contains('não encontrado')) {
      categoria = 'Erro';
      solucao = 'Verifique se os dados informados estão corretos.';
    } else if (mensagem.toLowerCase().contains('indisponível') ||
        mensagem.toLowerCase().contains('timeout')) {
      categoria = 'Erro';
      solucao = 'Tente novamente em alguns minutos.';
    }

    return ParcmeiErrorAnalysis(
      codigo: codigo,
      mensagem: mensagem,
      categoria: categoria,
      solucao: solucao,
    );
  }

  static bool isKnownError(String codigo) {
    return _errors.containsKey(codigo);
  }

  static ParcmeiErrorInfo? getErrorInfo(String codigo) {
    return _errors[codigo];
  }

  static List<ParcmeiErrorInfo> getAvisos() {
    return _errors.values.where((error) => error.categoria == 'Aviso').toList();
  }

  static List<ParcmeiErrorInfo> getEntradasIncorretas() {
    return _errors.values
        .where((error) => error.categoria == 'Entrada Incorreta')
        .toList();
  }

  static List<ParcmeiErrorInfo> getErros() {
    return _errors.values.where((error) => error.categoria == 'Erro').toList();
  }

  static List<ParcmeiErrorInfo> getSucessos() {
    return _errors.values
        .where((error) => error.categoria == 'Sucesso')
        .toList();
  }

  static List<ParcmeiErrorInfo> getAllErrors() {
    return _errors.values.toList();
  }

  static Map<String, List<ParcmeiErrorInfo>> getErrorsByCategory() {
    final Map<String, List<ParcmeiErrorInfo>> errorsByCategory = {};

    for (final error in _errors.values) {
      errorsByCategory.putIfAbsent(error.categoria, () => []);
      errorsByCategory[error.categoria]!.add(error);
    }

    return errorsByCategory;
  }
}
