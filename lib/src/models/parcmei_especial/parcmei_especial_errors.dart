/// Tratamento de erros específicos para os serviços PARCMEI-ESP
class ParcmeiEspecialErrors {
  /// Analisa um erro específico do PARCMEI-ESP e retorna informações detalhadas
  static ParcmeiEspecialErrorAnalysis analyzeError(String codigo, String mensagem) {
    final errorInfo = getErrorInfo(codigo);

    return ParcmeiEspecialErrorAnalysis(
      codigo: codigo,
      mensagem: mensagem,
      tipo: errorInfo?.tipo ?? ParcmeiEspecialErrorType.desconhecido,
      categoria: errorInfo?.categoria ?? ParcmeiEspecialErrorCategory.geral,
      solucao: errorInfo?.solucao ?? 'Entre em contato com o suporte técnico.',
      detalhes: errorInfo?.detalhes ?? 'Erro não catalogado.',
    );
  }

  /// Verifica se um código de erro é conhecido pelo sistema
  static bool isKnownError(String codigo) {
    return _errorCodes.containsKey(codigo);
  }

  /// Obtém informações sobre um erro específico do PARCMEI-ESP
  static ParcmeiEspecialErrorInfo? getErrorInfo(String codigo) {
    return _errorCodes[codigo];
  }

  /// Obtém todos os erros de aviso do PARCMEI-ESP
  static List<ParcmeiEspecialErrorInfo> getAvisos() {
    return _errorCodes.values.where((error) => error.tipo == ParcmeiEspecialErrorType.aviso).toList();
  }

  /// Obtém todos os erros de entrada incorreta do PARCMEI-ESP
  static List<ParcmeiEspecialErrorInfo> getEntradasIncorretas() {
    return _errorCodes.values.where((error) => error.tipo == ParcmeiEspecialErrorType.entradaIncorreta).toList();
  }

  /// Obtém todos os erros gerais do PARCMEI-ESP
  static List<ParcmeiEspecialErrorInfo> getErros() {
    return _errorCodes.values.where((error) => error.tipo == ParcmeiEspecialErrorType.erro).toList();
  }

  /// Obtém todos os sucessos do PARCMEI-ESP
  static List<ParcmeiEspecialErrorInfo> getSucessos() {
    return _errorCodes.values.where((error) => error.tipo == ParcmeiEspecialErrorType.sucesso).toList();
  }

  /// Mapa de códigos de erro conhecidos do PARCMEI-ESP
  static final Map<String, ParcmeiEspecialErrorInfo> _errorCodes = {
    // Sucessos
    '[Sucesso-PARCMEI-ESP]': ParcmeiEspecialErrorInfo(
      codigo: '[Sucesso-PARCMEI-ESP]',
      tipo: ParcmeiEspecialErrorType.sucesso,
      categoria: ParcmeiEspecialErrorCategory.operacao,
      detalhes: 'Operação realizada com sucesso.',
      solucao: 'Operação concluída normalmente.',
    ),

    // Avisos
    '[Aviso-PARCMEI-ESP-001]': ParcmeiEspecialErrorInfo(
      codigo: '[Aviso-PARCMEI-ESP-001]',
      tipo: ParcmeiEspecialErrorType.aviso,
      categoria: ParcmeiEspecialErrorCategory.parcelamento,
      detalhes: 'Nenhum parcelamento encontrado para o contribuinte.',
      solucao: 'Verifique se o contribuinte possui parcelamentos ativos.',
    ),

    '[Aviso-PARCMEI-ESP-002]': ParcmeiEspecialErrorInfo(
      codigo: '[Aviso-PARCMEI-ESP-002]',
      tipo: ParcmeiEspecialErrorType.aviso,
      categoria: ParcmeiEspecialErrorCategory.parcela,
      detalhes: 'Nenhuma parcela disponível para emissão.',
      solucao: 'Verifique se há parcelas pendentes de emissão.',
    ),

    '[Aviso-PARCMEI-ESP-003]': ParcmeiEspecialErrorInfo(
      codigo: '[Aviso-PARCMEI-ESP-003]',
      tipo: ParcmeiEspecialErrorType.aviso,
      categoria: ParcmeiEspecialErrorCategory.pagamento,
      detalhes: 'Nenhum detalhe de pagamento encontrado para a parcela.',
      solucao: 'Verifique se a parcela foi efetivamente paga.',
    ),

    // Erros de entrada incorreta
    '[Erro-PARCMEI-ESP-001]': ParcmeiEspecialErrorInfo(
      codigo: '[Erro-PARCMEI-ESP-001]',
      tipo: ParcmeiEspecialErrorType.entradaIncorreta,
      categoria: ParcmeiEspecialErrorCategory.validacao,
      detalhes: 'Número do parcelamento inválido.',
      solucao: 'Verifique se o número do parcelamento está correto.',
    ),

    '[Erro-PARCMEI-ESP-002]': ParcmeiEspecialErrorInfo(
      codigo: '[Erro-PARCMEI-ESP-002]',
      tipo: ParcmeiEspecialErrorType.entradaIncorreta,
      categoria: ParcmeiEspecialErrorCategory.validacao,
      detalhes: 'Ano/mês da parcela inválido.',
      solucao: 'Verifique se o formato AAAAMM está correto.',
    ),

    '[Erro-PARCMEI-ESP-003]': ParcmeiEspecialErrorInfo(
      codigo: '[Erro-PARCMEI-ESP-003]',
      tipo: ParcmeiEspecialErrorType.entradaIncorreta,
      categoria: ParcmeiEspecialErrorCategory.validacao,
      detalhes: 'Parcela para emissão inválida.',
      solucao: 'Verifique se a parcela está disponível para emissão.',
    ),

    '[Erro-PARCMEI-ESP-004]': ParcmeiEspecialErrorInfo(
      codigo: '[Erro-PARCMEI-ESP-004]',
      tipo: ParcmeiEspecialErrorType.entradaIncorreta,
      categoria: ParcmeiEspecialErrorCategory.contribuinte,
      detalhes: 'Tipo de contribuinte inválido.',
      solucao: 'PARCMEI-ESP aceita apenas contribuintes do tipo 2 (Pessoa Jurídica).',
    ),

    '[Erro-PARCMEI-ESP-005]': ParcmeiEspecialErrorInfo(
      codigo: '[Erro-PARCMEI-ESP-005]',
      tipo: ParcmeiEspecialErrorType.entradaIncorreta,
      categoria: ParcmeiEspecialErrorCategory.cnpj,
      detalhes: 'CNPJ do contribuinte inválido.',
      solucao: 'Verifique se o CNPJ está correto e possui 14 dígitos.',
    ),

    // Erros gerais
    '[Erro-PARCMEI-ESP-100]': ParcmeiEspecialErrorInfo(
      codigo: '[Erro-PARCMEI-ESP-100]',
      tipo: ParcmeiEspecialErrorType.erro,
      categoria: ParcmeiEspecialErrorCategory.sistema,
      detalhes: 'Erro interno do sistema PARCMEI-ESP.',
      solucao: 'Tente novamente em alguns minutos. Se o problema persistir, entre em contato com o suporte.',
    ),

    '[Erro-PARCMEI-ESP-101]': ParcmeiEspecialErrorInfo(
      codigo: '[Erro-PARCMEI-ESP-101]',
      tipo: ParcmeiEspecialErrorType.erro,
      categoria: ParcmeiEspecialErrorCategory.conexao,
      detalhes: 'Erro de conexão com o sistema PARCMEI-ESP.',
      solucao: 'Verifique sua conexão com a internet e tente novamente.',
    ),

    '[Erro-PARCMEI-ESP-102]': ParcmeiEspecialErrorInfo(
      codigo: '[Erro-PARCMEI-ESP-102]',
      tipo: ParcmeiEspecialErrorType.erro,
      categoria: ParcmeiEspecialErrorCategory.timeout,
      detalhes: 'Timeout na comunicação com o sistema PARCMEI-ESP.',
      solucao: 'Tente novamente. Se o problema persistir, entre em contato com o suporte.',
    ),

    '[Erro-PARCMEI-ESP-103]': ParcmeiEspecialErrorInfo(
      codigo: '[Erro-PARCMEI-ESP-103]',
      tipo: ParcmeiEspecialErrorType.erro,
      categoria: ParcmeiEspecialErrorCategory.autenticacao,
      detalhes: 'Erro de autenticação no sistema PARCMEI-ESP.',
      solucao: 'Verifique suas credenciais de acesso.',
    ),

    '[Erro-PARCMEI-ESP-104]': ParcmeiEspecialErrorInfo(
      codigo: '[Erro-PARCMEI-ESP-104]',
      tipo: ParcmeiEspecialErrorType.erro,
      categoria: ParcmeiEspecialErrorCategory.autorizacao,
      detalhes: 'Usuário não autorizado a acessar o sistema PARCMEI-ESP.',
      solucao: 'Verifique suas permissões de acesso.',
    ),

    '[Erro-PARCMEI-ESP-105]': ParcmeiEspecialErrorInfo(
      codigo: '[Erro-PARCMEI-ESP-105]',
      tipo: ParcmeiEspecialErrorType.erro,
      categoria: ParcmeiEspecialErrorCategory.parcelamento,
      detalhes: 'Parcelamento não encontrado.',
      solucao: 'Verifique se o número do parcelamento está correto.',
    ),

    '[Erro-PARCMEI-ESP-106]': ParcmeiEspecialErrorInfo(
      codigo: '[Erro-PARCMEI-ESP-106]',
      tipo: ParcmeiEspecialErrorType.erro,
      categoria: ParcmeiEspecialErrorCategory.parcela,
      detalhes: 'Parcela não encontrada.',
      solucao: 'Verifique se a parcela existe e está disponível.',
    ),

    '[Erro-PARCMEI-ESP-107]': ParcmeiEspecialErrorInfo(
      codigo: '[Erro-PARCMEI-ESP-107]',
      tipo: ParcmeiEspecialErrorType.erro,
      categoria: ParcmeiEspecialErrorCategory.emissao,
      detalhes: 'Erro na emissão do DAS.',
      solucao: 'Tente novamente. Se o problema persistir, entre em contato com o suporte.',
    ),

    '[Erro-PARCMEI-ESP-108]': ParcmeiEspecialErrorInfo(
      codigo: '[Erro-PARCMEI-ESP-108]',
      tipo: ParcmeiEspecialErrorType.erro,
      categoria: ParcmeiEspecialErrorCategory.pagamento,
      detalhes: 'Erro ao consultar detalhes de pagamento.',
      solucao: 'Verifique se a parcela foi efetivamente paga.',
    ),

    '[Erro-PARCMEI-ESP-109]': ParcmeiEspecialErrorInfo(
      codigo: '[Erro-PARCMEI-ESP-109]',
      tipo: ParcmeiEspecialErrorType.erro,
      categoria: ParcmeiEspecialErrorCategory.servico,
      detalhes: 'Serviço temporariamente indisponível.',
      solucao: 'Tente novamente em alguns minutos.',
    ),

    '[Erro-PARCMEI-ESP-110]': ParcmeiEspecialErrorInfo(
      codigo: '[Erro-PARCMEI-ESP-110]',
      tipo: ParcmeiEspecialErrorType.erro,
      categoria: ParcmeiEspecialErrorCategory.manutencao,
      detalhes: 'Sistema em manutenção.',
      solucao: 'Tente novamente mais tarde.',
    ),
  };
}

/// Tipos de erro do PARCMEI-ESP
enum ParcmeiEspecialErrorType { sucesso, aviso, entradaIncorreta, erro, desconhecido }

/// Categorias de erro do PARCMEI-ESP
enum ParcmeiEspecialErrorCategory {
  operacao,
  validacao,
  contribuinte,
  cnpj,
  parcelamento,
  parcela,
  pagamento,
  emissao,
  sistema,
  conexao,
  timeout,
  autenticacao,
  autorizacao,
  servico,
  manutencao,
  geral,
}

/// Informações sobre um erro específico do PARCMEI-ESP
class ParcmeiEspecialErrorInfo {
  final String codigo;
  final ParcmeiEspecialErrorType tipo;
  final ParcmeiEspecialErrorCategory categoria;
  final String detalhes;
  final String solucao;

  ParcmeiEspecialErrorInfo({required this.codigo, required this.tipo, required this.categoria, required this.detalhes, required this.solucao});

  /// Verifica se é um erro crítico
  bool get isCritico => tipo == ParcmeiEspecialErrorType.erro;

  /// Verifica se é um erro de validação
  bool get isValidacao => tipo == ParcmeiEspecialErrorType.entradaIncorreta;

  /// Verifica se é um aviso
  bool get isAviso => tipo == ParcmeiEspecialErrorType.aviso;

  /// Verifica se é um sucesso
  bool get isSucesso => tipo == ParcmeiEspecialErrorType.sucesso;

  /// Verifica se requer ação do usuário
  bool get requerAcaoUsuario => tipo == ParcmeiEspecialErrorType.entradaIncorreta;

  /// Verifica se é temporário
  bool get isTemporario =>
      categoria == ParcmeiEspecialErrorCategory.conexao ||
      categoria == ParcmeiEspecialErrorCategory.timeout ||
      categoria == ParcmeiEspecialErrorCategory.servico ||
      categoria == ParcmeiEspecialErrorCategory.manutencao;
}

/// Análise completa de um erro do PARCMEI-ESP
class ParcmeiEspecialErrorAnalysis {
  final String codigo;
  final String mensagem;
  final ParcmeiEspecialErrorType tipo;
  final ParcmeiEspecialErrorCategory categoria;
  final String solucao;
  final String detalhes;

  ParcmeiEspecialErrorAnalysis({
    required this.codigo,
    required this.mensagem,
    required this.tipo,
    required this.categoria,
    required this.solucao,
    required this.detalhes,
  });

  /// Verifica se é um erro crítico
  bool get isCritico => tipo == ParcmeiEspecialErrorType.erro;

  /// Verifica se é um erro de validação
  bool get isValidacao => tipo == ParcmeiEspecialErrorType.entradaIncorreta;

  /// Verifica se é um aviso
  bool get isAviso => tipo == ParcmeiEspecialErrorType.aviso;

  /// Verifica se é um sucesso
  bool get isSucesso => tipo == ParcmeiEspecialErrorType.sucesso;

  /// Verifica se requer ação do usuário
  bool get requerAcaoUsuario => tipo == ParcmeiEspecialErrorType.entradaIncorreta;

  /// Verifica se é temporário
  bool get isTemporario =>
      categoria == ParcmeiEspecialErrorCategory.conexao ||
      categoria == ParcmeiEspecialErrorCategory.timeout ||
      categoria == ParcmeiEspecialErrorCategory.servico ||
      categoria == ParcmeiEspecialErrorCategory.manutencao;

  /// Verifica se pode ser ignorado
  bool get podeSerIgnorado => tipo == ParcmeiEspecialErrorType.aviso;

  /// Verifica se deve ser reportado
  bool get deveSerReportado => tipo == ParcmeiEspecialErrorType.erro && categoria != ParcmeiEspecialErrorCategory.validacao;

  /// Obtém a prioridade do erro
  int get prioridade {
    switch (tipo) {
      case ParcmeiEspecialErrorType.erro:
        return 1; // Alta prioridade
      case ParcmeiEspecialErrorType.entradaIncorreta:
        return 2; // Média prioridade
      case ParcmeiEspecialErrorType.aviso:
        return 3; // Baixa prioridade
      case ParcmeiEspecialErrorType.sucesso:
        return 0; // Sem prioridade
      case ParcmeiEspecialErrorType.desconhecido:
        return 1; // Alta prioridade
    }
  }

  /// Obtém a cor do erro para interface
  String get cor {
    switch (tipo) {
      case ParcmeiEspecialErrorType.erro:
        return 'red';
      case ParcmeiEspecialErrorType.entradaIncorreta:
        return 'orange';
      case ParcmeiEspecialErrorType.aviso:
        return 'yellow';
      case ParcmeiEspecialErrorType.sucesso:
        return 'green';
      case ParcmeiEspecialErrorType.desconhecido:
        return 'gray';
    }
  }

  /// Obtém o ícone do erro para interface
  String get icone {
    switch (tipo) {
      case ParcmeiEspecialErrorType.erro:
        return 'error';
      case ParcmeiEspecialErrorType.entradaIncorreta:
        return 'warning';
      case ParcmeiEspecialErrorType.aviso:
        return 'info';
      case ParcmeiEspecialErrorType.sucesso:
        return 'check_circle';
      case ParcmeiEspecialErrorType.desconhecido:
        return 'help';
    }
  }

  @override
  String toString() {
    return 'ParcmeiEspecialErrorAnalysis(codigo: $codigo, tipo: $tipo, categoria: $categoria, mensagem: $mensagem)';
  }
}
