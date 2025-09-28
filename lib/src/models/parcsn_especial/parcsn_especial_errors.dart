/// Tratamento de erros específicos do sistema PARCSN-ESP (Parcelamento Especial do Simples Nacional)
class ParcsnEspecialErrors {
  /// Analisa um erro específico do PARCSN-ESP e retorna informações detalhadas
  static ParcsnEspecialErrorAnalysis analyzeError(String codigo, String mensagem) {
    final errorInfo = getErrorInfo(codigo);

    return ParcsnEspecialErrorAnalysis(
      codigo: codigo,
      mensagem: mensagem,
      tipo: errorInfo?.tipo ?? ParcsnEspecialErrorType.desconhecido,
      categoria: errorInfo?.categoria ?? ParcsnEspecialErrorCategory.outros,
      acaoRecomendada: errorInfo?.acaoRecomendada ?? 'Verifique os dados e tente novamente.',
      isConhecido: errorInfo != null,
    );
  }

  /// Verifica se um código de erro é conhecido pelo sistema
  static bool isKnownError(String codigo) {
    return _errors.containsKey(codigo);
  }

  /// Obtém informações sobre um erro específico do PARCSN-ESP
  static ParcsnEspecialErrorInfo? getErrorInfo(String codigo) {
    return _errors[codigo];
  }

  /// Obtém todos os erros de aviso do PARCSN-ESP
  static List<ParcsnEspecialErrorInfo> getAvisos() {
    return _errors.values.where((e) => e.tipo == ParcsnEspecialErrorType.aviso).toList();
  }

  /// Obtém todos os erros de entrada incorreta do PARCSN-ESP
  static List<ParcsnEspecialErrorInfo> getEntradasIncorretas() {
    return _errors.values.where((e) => e.tipo == ParcsnEspecialErrorType.entradaIncorreta).toList();
  }

  /// Obtém todos os erros gerais do PARCSN-ESP
  static List<ParcsnEspecialErrorInfo> getErros() {
    return _errors.values.where((e) => e.tipo == ParcsnEspecialErrorType.erro).toList();
  }

  /// Obtém todos os sucessos do PARCSN-ESP
  static List<ParcsnEspecialErrorInfo> getSucessos() {
    return _errors.values.where((e) => e.tipo == ParcsnEspecialErrorType.sucesso).toList();
  }

  /// Mapa de erros conhecidos do PARCSN-ESP
  static final Map<String, ParcsnEspecialErrorInfo> _errors = {
    // Sucessos
    '[Sucesso-PARCSN-ESP]': ParcsnEspecialErrorInfo(
      codigo: '[Sucesso-PARCSN-ESP]',
      tipo: ParcsnEspecialErrorType.sucesso,
      categoria: ParcsnEspecialErrorCategory.operacao,
      descricao: 'Requisição efetuada com sucesso.',
      acaoRecomendada: 'Operação realizada com sucesso.',
    ),

    // Avisos
    '[Aviso-PARCSN-ESP-ER_E001]': ParcsnEspecialErrorInfo(
      codigo: '[Aviso-PARCSN-ESP-ER_E001]',
      tipo: ParcsnEspecialErrorType.aviso,
      categoria: ParcsnEspecialErrorCategory.parcelamento,
      descricao: 'Não há parcelamento ativo para o contribuinte.',
      acaoRecomendada: 'O número do parcelamento informado não está ativo ou não existe.',
    ),

    '[Aviso-PARCSN-ESP-ER_N003]': ParcsnEspecialErrorInfo(
      codigo: '[Aviso-PARCSN-ESP-ER_N003]',
      tipo: ParcsnEspecialErrorType.aviso,
      categoria: ParcsnEspecialErrorCategory.parcelamento,
      descricao:
          'Não há mais saldo devedor para os débitos incluídos no parcelamento. No próximo processamento mensal, o parcelamento será encerrado.',
      acaoRecomendada: 'Não há parcela disponível.',
    ),

    '[Aviso-PARCSN-ESP-ER_N005]': ParcsnEspecialErrorInfo(
      codigo: '[Aviso-PARCSN-ESP-ER_N005]',
      tipo: ParcsnEspecialErrorType.aviso,
      categoria: ParcsnEspecialErrorCategory.emissao,
      descricao: 'O DAS da parcela do mês corrente só pode ser emitido a partir do dia {}.',
      acaoRecomendada: 'Reenviar a partir do dia indicado.',
    ),

    '[Aviso-PARCSN-ESP-ER_N006]': ParcsnEspecialErrorInfo(
      codigo: '[Aviso-PARCSN-ESP-ER_N006]',
      tipo: ParcsnEspecialErrorType.aviso,
      categoria: ParcsnEspecialErrorCategory.emissao,
      descricao:
          'A parcela {0} está indisponível para impressão devido a um dos seguintes motivos: 1- A parcela não existe no parcelamento; 2- Já existe pagamento para a parcela ou 3- É uma parcela de um mês futuro ainda não disponível.',
      acaoRecomendada: 'Foi solicitada uma parcela que não está disponível para o parcelamento solicitado.',
    ),

    '[Aviso-PARCSN-ESP-ER_N008]': ParcsnEspecialErrorInfo(
      codigo: '[Aviso-PARCSN-ESP-ER_N008]',
      tipo: ParcsnEspecialErrorType.aviso,
      categoria: ParcsnEspecialErrorCategory.emissao,
      descricao: 'Não foram encontradas parcelas para emissão.',
      acaoRecomendada: 'Não há parcelas para o parcelamento solicitado.',
    ),

    '[Aviso-PARCSN-ESP-ER_N009]': ParcsnEspecialErrorInfo(
      codigo: '[Aviso-PARCSN-ESP-ER_N009]',
      tipo: ParcsnEspecialErrorType.aviso,
      categoria: ParcsnEspecialErrorCategory.parcelamento,
      descricao: 'Não existe parcelamento para o numeroParcelamento informado.',
      acaoRecomendada: 'Verificar o número do parcelamento passado no parâmetro.',
    ),

    '[Aviso-PARCSN-ESP-ER_N010]': ParcsnEspecialErrorInfo(
      codigo: '[Aviso-PARCSN-ESP-ER_N010]',
      tipo: ParcsnEspecialErrorType.aviso,
      categoria: ParcsnEspecialErrorCategory.pagamento,
      descricao: 'A parcela {} informada não é uma parcela válida para consulta de pagamento do parcelamento {}.',
      acaoRecomendada: 'Foi passada uma parcela que não existe ou não possui pagamento.',
    ),

    '[Aviso-PARCSN-ESP-ER_N011]': ParcsnEspecialErrorInfo(
      codigo: '[Aviso-PARCSN-ESP-ER_N011]',
      tipo: ParcsnEspecialErrorType.aviso,
      categoria: ParcsnEspecialErrorCategory.parcelamento,
      descricao: 'Não existe parcelamento com o número informado.',
      acaoRecomendada: 'Reenviar corrigindo o parâmetro.',
    ),

    '[Aviso-PARCSN-ESP-ER_N012]': ParcsnEspecialErrorInfo(
      codigo: '[Aviso-PARCSN-ESP-ER_N012]',
      tipo: ParcsnEspecialErrorType.aviso,
      categoria: ParcsnEspecialErrorCategory.pagamento,
      descricao: 'Não existe pagamento para o anoMesParcela e numeroParcelamento informados.',
      acaoRecomendada: 'Não existe pagamento para a parcela informada.',
    ),

    '[Aviso-PARCSN-ESP-ER_N013]': ParcsnEspecialErrorInfo(
      codigo: '[Aviso-PARCSN-ESP-ER_N013]',
      tipo: ParcsnEspecialErrorType.aviso,
      categoria: ParcsnEspecialErrorCategory.parcelamento,
      descricao:
          'Há um pedido de parcelamento para o contribuinte aguardando confirmação do pagamento da primeira parcela. Mensalmente, após a confirmação, estarão disponíveis os documentos para pagamento das demais.',
      acaoRecomendada: 'Aguardar o pagamento.',
    ),

    '[Aviso-PARCSN-ESP-ER_N014]': ParcsnEspecialErrorInfo(
      codigo: '[Aviso-PARCSN-ESP-ER_N014]',
      tipo: ParcsnEspecialErrorType.aviso,
      categoria: ParcsnEspecialErrorCategory.emissao,
      descricao: 'Informe a parcela {0} na requisição para obter o documento de arrecadação da primeira parcela.',
      acaoRecomendada: 'Mensagem que pode ser emitida em conjunto com outra. Deve ser corrigido o parâmetro de entrada.',
    ),

    // Erros de entrada incorreta
    '[EntradaIncorreta-PARCSN-ESP-ER_N002]': ParcsnEspecialErrorInfo(
      codigo: '[EntradaIncorreta-PARCSN-ESP-ER_N002]',
      tipo: ParcsnEspecialErrorType.entradaIncorreta,
      categoria: ParcsnEspecialErrorCategory.validacao,
      descricao: 'Parâmetro de entrada inválido: {}.',
      acaoRecomendada: 'Foi enviado um parâmetro de forma incorreta. Reenviar corrigindo o problema.',
    ),

    '[EntradaIncorreta-PARCSN-ESP-ER_N004]': ParcsnEspecialErrorInfo(
      codigo: '[EntradaIncorreta-PARCSN-ESP-ER_N004]',
      tipo: ParcsnEspecialErrorType.entradaIncorreta,
      categoria: ParcsnEspecialErrorCategory.parcelamento,
      descricao:
          'Houve uma reconsolidação do parcelamento. Não é possível utilizar o Integra Contador para esta ação, que deve ser feita diretamente no portal do contribuinte ou eCac.',
      acaoRecomendada: 'Quando há reconsolidação, deve ser utilizada a versão web.',
    ),

    '[EntradaIncorreta-PARCSN-ESP-ER_N007]': ParcsnEspecialErrorInfo(
      codigo: '[EntradaIncorreta-PARCSN-ESP-ER_N007]',
      tipo: ParcsnEspecialErrorType.entradaIncorreta,
      categoria: ParcsnEspecialErrorCategory.validacao,
      descricao: 'Esta funcionalidade não requer nenhuma informação no campo dados. Remova e envie novamente a requisição.',
      acaoRecomendada: 'Foram enviados parâmetros de entrada desnecessários. Reenviar retirando os parâmetros.',
    ),

    // Erros gerais
    '[Erro-PARCSN-ESP-ER_N001]': ParcsnEspecialErrorInfo(
      codigo: '[Erro-PARCSN-ESP-ER_N001]',
      tipo: ParcsnEspecialErrorType.erro,
      categoria: ParcsnEspecialErrorCategory.sistema,
      descricao: 'Erro ao utilizar o Integra Contador Parcelamentos. Tente novamente mais tarde.',
      acaoRecomendada: 'Erro interno. Efetuar nova tentativa.',
    ),
  };
}

/// Tipos de erro do PARCSN-ESP
enum ParcsnEspecialErrorType { sucesso, aviso, entradaIncorreta, erro, desconhecido }

/// Categorias de erro do PARCSN-ESP
enum ParcsnEspecialErrorCategory { operacao, parcelamento, pagamento, emissao, validacao, sistema, outros }

/// Informações sobre um erro específico do PARCSN-ESP
class ParcsnEspecialErrorInfo {
  final String codigo;
  final ParcsnEspecialErrorType tipo;
  final ParcsnEspecialErrorCategory categoria;
  final String descricao;
  final String acaoRecomendada;

  ParcsnEspecialErrorInfo({
    required this.codigo,
    required this.tipo,
    required this.categoria,
    required this.descricao,
    required this.acaoRecomendada,
  });

  /// Verifica se é um erro de sucesso
  bool get isSucesso => tipo == ParcsnEspecialErrorType.sucesso;

  /// Verifica se é um erro de aviso
  bool get isAviso => tipo == ParcsnEspecialErrorType.aviso;

  /// Verifica se é um erro de entrada incorreta
  bool get isEntradaIncorreta => tipo == ParcsnEspecialErrorType.entradaIncorreta;

  /// Verifica se é um erro geral
  bool get isErro => tipo == ParcsnEspecialErrorType.erro;

  /// Verifica se é um erro desconhecido
  bool get isDesconhecido => tipo == ParcsnEspecialErrorType.desconhecido;

  @override
  String toString() {
    return 'ParcsnEspecialErrorInfo(codigo: $codigo, tipo: $tipo, categoria: $categoria)';
  }
}

/// Análise de erro do PARCSN-ESP
class ParcsnEspecialErrorAnalysis {
  final String codigo;
  final String mensagem;
  final ParcsnEspecialErrorType tipo;
  final ParcsnEspecialErrorCategory categoria;
  final String acaoRecomendada;
  final bool isConhecido;

  ParcsnEspecialErrorAnalysis({
    required this.codigo,
    required this.mensagem,
    required this.tipo,
    required this.categoria,
    required this.acaoRecomendada,
    required this.isConhecido,
  });

  /// Verifica se é um erro de sucesso
  bool get isSucesso => tipo == ParcsnEspecialErrorType.sucesso;

  /// Verifica se é um erro de aviso
  bool get isAviso => tipo == ParcsnEspecialErrorType.aviso;

  /// Verifica se é um erro de entrada incorreta
  bool get isEntradaIncorreta => tipo == ParcsnEspecialErrorType.entradaIncorreta;

  /// Verifica se é um erro geral
  bool get isErro => tipo == ParcsnEspecialErrorType.erro;

  /// Verifica se é um erro desconhecido
  bool get isDesconhecido => tipo == ParcsnEspecialErrorType.desconhecido;

  /// Verifica se é um erro crítico que impede a operação
  bool get isCritico => tipo == ParcsnEspecialErrorType.erro || tipo == ParcsnEspecialErrorType.entradaIncorreta;

  /// Verifica se é um erro que permite retry
  bool get permiteRetry => tipo == ParcsnEspecialErrorType.erro && categoria == ParcsnEspecialErrorCategory.sistema;

  @override
  String toString() {
    return 'ParcsnEspecialErrorAnalysis(codigo: $codigo, tipo: $tipo, categoria: $categoria, conhecido: $isConhecido)';
  }
}
