/// Tratamento de erros específicos para os serviços RELPSN
class RelpsnErrors {
  /// Códigos de erro específicos do RELPSN
  static const Map<String, RelpsnErrorInfo> errorCodes = {
    '[Aviso-RELPSN-ER_E001]': RelpsnErrorInfo(
      codigo: '[Aviso-RELPSN-ER_E001]',
      mensagem: 'Não há parcelamento ativo para o contribuinte.',
      acao: 'O número do parcelamento informado não está ativo ou não existe.',
      tipo: RelpsnErrorType.aviso,
    ),
    '[Erro-RELPSN-ER_N001]': RelpsnErrorInfo(
      codigo: '[Erro-RELPSN-ER_N001]',
      mensagem: 'Erro ao utilizar o Integra Contador Parcelamentos. Tente novamente mais tarde.',
      acao: 'Erro interno. Efetuar nova tentativa.',
      tipo: RelpsnErrorType.erro,
    ),
    '[EntradaIncorreta-RELPSN-ER_N002]': RelpsnErrorInfo(
      codigo: '[EntradaIncorreta-RELPSN-ER_N002]',
      mensagem: 'Parâmetro de entrada inválido: {}.',
      acao: 'Foi enviado um parâmetro de forma incorreta. Reenviar corrigindo o problema.',
      tipo: RelpsnErrorType.entradaIncorreta,
    ),
    '[Aviso-RELPSN-ER_N003]': RelpsnErrorInfo(
      codigo: '[Aviso-RELPSN-ER_N003]',
      mensagem:
          'Não há mais saldo devedor para os débitos incluídos no parcelamento. No próximo processamento mensal, o parcelamento será encerrado.',
      acao: 'Não há parcela disponível.',
      tipo: RelpsnErrorType.aviso,
    ),
    '[EntradaIncorreta-RELPSN-ER_N004]': RelpsnErrorInfo(
      codigo: '[EntradaIncorreta-RELPSN-ER_N004]',
      mensagem:
          'Houve uma reconsolidação do parcelamento. Não é possível utilizar o Integra Contador para esta ação, que deve ser feita diretamente no portal do contribuinte ou eCac.',
      acao: 'Quando há reconsolidação, deve ser utilizada a versão web.',
      tipo: RelpsnErrorType.entradaIncorreta,
    ),
    '[Aviso-RELPSN-ER_N005]': RelpsnErrorInfo(
      codigo: '[Aviso-RELPSN-ER_N005]',
      mensagem: 'O DAS da parcela do mês corrente só pode ser emitido a partir do dia {}.',
      acao: 'Reenviar a partir do dia indicado.',
      tipo: RelpsnErrorType.aviso,
    ),
    '[Aviso-RELPSN-ER_N006]': RelpsnErrorInfo(
      codigo: '[Aviso-RELPSN-ER_N006]',
      mensagem:
          'A parcela {0} está indisponível para impressão devido a um dos seguintes motivos: 1- A parcela não existe no parcelamento; 2- Já existe pagamento para a parcela ou 3- É uma parcela de um mês futuro ainda não disponível.',
      acao: 'Foi solicitada uma parcela que não está disponível para o parcelamento solicitado.',
      tipo: RelpsnErrorType.aviso,
    ),
    '[EntradaIncorreta-RELPSN-ER_N007]': RelpsnErrorInfo(
      codigo: '[EntradaIncorreta-RELPSN-ER_N007]',
      mensagem: 'Esta funcionalidade não requer nenhuma informação no campo dados. Remova e envie novamente a requisição.',
      acao: 'Foram enviados parâmetros de entrada desnecessários. Reenviar retirando os parâmetros.',
      tipo: RelpsnErrorType.entradaIncorreta,
    ),
    '[Aviso-RELPSN-ER_N008]': RelpsnErrorInfo(
      codigo: '[Aviso-RELPSN-ER_N008]',
      mensagem: 'Não foram encontradas parcelas para emissão.',
      acao: 'Não há parcelas para o parcelamento solicitado.',
      tipo: RelpsnErrorType.aviso,
    ),
    '[Aviso-RELPSN-ER_N009]': RelpsnErrorInfo(
      codigo: '[Aviso-RELPSN-ER_N009]',
      mensagem: 'Não existe parcelamento para o numeroParcelamento informado.',
      acao: 'Verificar o número do parcelamento passado no parâmetro',
      tipo: RelpsnErrorType.aviso,
    ),
    '[Aviso-RELPSN-ER_N010]': RelpsnErrorInfo(
      codigo: '[Aviso-RELPSN-ER_N010]',
      mensagem: 'A parcela {} informada não é uma parcela válida para consulta de pagamento do parcelamento {}.',
      acao: 'Foi passada uma parcela que não existe ou não possui pagamento.',
      tipo: RelpsnErrorType.aviso,
    ),
    '[Aviso-RELPSN-ER_N011]': RelpsnErrorInfo(
      codigo: '[Aviso-RELPSN-ER_N011]',
      mensagem: 'Não existe parcelamento com o número informado.',
      acao: 'Reenviar corrigindo o parâmetro.',
      tipo: RelpsnErrorType.aviso,
    ),
    '[Aviso-RELPSN-ER_N012]': RelpsnErrorInfo(
      codigo: '[Aviso-RELPSN-ER_N012]',
      mensagem: 'Não existe pagamento para o anoMesParcela e numeroParcelamento informados.',
      acao: 'Não existe pagamento para a parcela informada.',
      tipo: RelpsnErrorType.aviso,
    ),
    '[Aviso-RELPSN-ER_N013]': RelpsnErrorInfo(
      codigo: '[Aviso-RELPSN-ER_N013]',
      mensagem:
          'Há um pedido de parcelamento para o contribuinte aguardando confirmação do pagamento da primeira parcela. Mensalmente, após a confirmação, estarão disponíveis os documentos para pagamento das demais.',
      acao: 'Aguardar o pagamento.',
      tipo: RelpsnErrorType.aviso,
    ),
    '[EntradaIncorreta-RELPSN-ER_N014]': RelpsnErrorInfo(
      codigo: '[EntradaIncorreta-RELPSN-ER_N014]',
      mensagem: 'Não será possível utilizar o IC para este contribuinte. Utilize o sistema web.',
      acao: 'A condição do parcelamento do contribuinte não permite a utilização pelo Integra Contador.',
      tipo: RelpsnErrorType.entradaIncorreta,
    ),
    '[Aviso-RELPSN-ER_N015]': RelpsnErrorInfo(
      codigo: '[Aviso-RELPSN-ER_N015]',
      mensagem: 'Informe a parcela {0} na requisição para obter o documento de arrecadação da primeira parcela.',
      acao: 'Mensagem que pode ser emitida em conjunto com outra. Deve ser corrigido o parâmetro de entrada.',
      tipo: RelpsnErrorType.aviso,
    ),
    '[EntradaIncorreta-RELPSN-ER_N016]': RelpsnErrorInfo(
      codigo: '[EntradaIncorreta-RELPSN-ER_N016]',
      mensagem:
          'O Integra Contador Parcelamento possui o limite de {0} parcelas e este parcelamento possui {1} parcelas. Utilize o sistema na WEB para obter a guia.',
      acao: 'Não será possível emitir guia para este parcelamento.',
      tipo: RelpsnErrorType.entradaIncorreta,
    ),
  };

  /// Obtém informações sobre um erro específico
  static RelpsnErrorInfo? getErrorInfo(String codigo) {
    return errorCodes[codigo];
  }

  /// Verifica se um código é um erro conhecido
  static bool isKnownError(String codigo) {
    return errorCodes.containsKey(codigo);
  }

  /// Obtém todos os erros de um tipo específico
  static List<RelpsnErrorInfo> getErrorsByType(RelpsnErrorType tipo) {
    return errorCodes.values.where((error) => error.tipo == tipo).toList();
  }

  /// Obtém todos os erros de aviso
  static List<RelpsnErrorInfo> getAvisos() {
    return getErrorsByType(RelpsnErrorType.aviso);
  }

  /// Obtém todos os erros de entrada incorreta
  static List<RelpsnErrorInfo> getEntradasIncorretas() {
    return getErrorsByType(RelpsnErrorType.entradaIncorreta);
  }

  /// Obtém todos os erros gerais
  static List<RelpsnErrorInfo> getErros() {
    return getErrorsByType(RelpsnErrorType.erro);
  }

  /// Analisa uma mensagem de erro e retorna informações detalhadas
  static RelpsnErrorAnalysis analyzeError(String codigo, String mensagem) {
    final errorInfo = getErrorInfo(codigo);

    if (errorInfo != null) {
      return RelpsnErrorAnalysis(
        codigo: codigo,
        mensagem: mensagem,
        errorInfo: errorInfo,
        isKnown: true,
        severity: _getSeverity(errorInfo.tipo),
        canRetry: _canRetry(errorInfo.tipo),
        requiresUserAction: _requiresUserAction(errorInfo.tipo),
      );
    }

    return RelpsnErrorAnalysis(
      codigo: codigo,
      mensagem: mensagem,
      errorInfo: null,
      isKnown: false,
      severity: RelpsnErrorSeverity.unknown,
      canRetry: false,
      requiresUserAction: true,
    );
  }

  /// Determina a severidade do erro
  static RelpsnErrorSeverity _getSeverity(RelpsnErrorType tipo) {
    switch (tipo) {
      case RelpsnErrorType.aviso:
        return RelpsnErrorSeverity.low;
      case RelpsnErrorType.entradaIncorreta:
        return RelpsnErrorSeverity.medium;
      case RelpsnErrorType.erro:
        return RelpsnErrorSeverity.high;
    }
  }

  /// Determina se o erro permite nova tentativa
  static bool _canRetry(RelpsnErrorType tipo) {
    switch (tipo) {
      case RelpsnErrorType.aviso:
        return false;
      case RelpsnErrorType.entradaIncorreta:
        return true;
      case RelpsnErrorType.erro:
        return true;
    }
  }

  /// Determina se o erro requer ação do usuário
  static bool _requiresUserAction(RelpsnErrorType tipo) {
    switch (tipo) {
      case RelpsnErrorType.aviso:
        return true;
      case RelpsnErrorType.entradaIncorreta:
        return true;
      case RelpsnErrorType.erro:
        return false;
    }
  }
}

/// Informações sobre um erro específico do RELPSN
class RelpsnErrorInfo {
  final String codigo;
  final String mensagem;
  final String acao;
  final RelpsnErrorType tipo;

  const RelpsnErrorInfo({required this.codigo, required this.mensagem, required this.acao, required this.tipo});
}

/// Tipos de erro do RELPSN
enum RelpsnErrorType { aviso, entradaIncorreta, erro }

/// Severidade do erro
enum RelpsnErrorSeverity { low, medium, high, unknown }

/// Análise detalhada de um erro
class RelpsnErrorAnalysis {
  final String codigo;
  final String mensagem;
  final RelpsnErrorInfo? errorInfo;
  final bool isKnown;
  final RelpsnErrorSeverity severity;
  final bool canRetry;
  final bool requiresUserAction;

  RelpsnErrorAnalysis({
    required this.codigo,
    required this.mensagem,
    required this.errorInfo,
    required this.isKnown,
    required this.severity,
    required this.canRetry,
    required this.requiresUserAction,
  });

  /// Retorna uma descrição resumida do erro
  String get summary {
    if (errorInfo != null) {
      return '${errorInfo!.tipo.name.toUpperCase()}: ${errorInfo!.mensagem}';
    }
    return 'ERRO DESCONHECIDO: $mensagem';
  }

  /// Retorna a ação recomendada
  String get recommendedAction {
    if (errorInfo != null) {
      return errorInfo!.acao;
    }
    return 'Verifique os parâmetros enviados e tente novamente.';
  }

  /// Retorna se é um erro crítico
  bool get isCritical {
    return severity == RelpsnErrorSeverity.high;
  }

  /// Retorna se é um erro que pode ser ignorado
  bool get isIgnorable {
    return severity == RelpsnErrorSeverity.low;
  }

  /// Retorna se é um erro de validação
  bool get isValidationError {
    return errorInfo?.tipo == RelpsnErrorType.entradaIncorreta;
  }

  /// Retorna se é um erro de sistema
  bool get isSystemError {
    return errorInfo?.tipo == RelpsnErrorType.erro;
  }

  /// Retorna se é um aviso
  bool get isWarning {
    return errorInfo?.tipo == RelpsnErrorType.aviso;
  }
}
