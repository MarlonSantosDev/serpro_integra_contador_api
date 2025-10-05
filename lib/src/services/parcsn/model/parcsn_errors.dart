/// Tratamento de erros específicos do sistema PARCSN
class PertsnErrors {
  /// Analisa um erro específico do PARCSN e retorna informações detalhadas
  static PertsnErrorAnalysis analyzeError(String codigo, String mensagem) {
    final errorInfo = getErrorInfo(codigo);

    return PertsnErrorAnalysis(
      codigo: codigo,
      mensagem: mensagem,
      tipo: errorInfo?.tipo ?? PertsnErrorType.desconhecido,
      categoria: errorInfo?.categoria ?? PertsnErrorCategory.outros,
      descricao: errorInfo?.descricao ?? 'Erro não catalogado',
      solucao: errorInfo?.solucao ?? 'Entre em contato com o suporte técnico',
      isConhecido: errorInfo != null,
    );
  }

  /// Verifica se um código de erro é conhecido pelo sistema
  static bool isKnownError(String codigo) {
    return _erros.containsKey(codigo);
  }

  /// Obtém informações sobre um erro específico do PARCSN
  static PertsnErrorInfo? getErrorInfo(String codigo) {
    return _erros[codigo];
  }

  /// Obtém todos os erros de aviso do PARCSN
  static List<PertsnErrorInfo> getAvisos() {
    return _erros.values.where((e) => e.tipo == PertsnErrorType.aviso).toList();
  }

  /// Obtém todos os erros de entrada incorreta do PARCSN
  static List<PertsnErrorInfo> getEntradasIncorretas() {
    return _erros.values
        .where((e) => e.categoria == PertsnErrorCategory.entradaIncorreta)
        .toList();
  }

  /// Obtém todos os erros gerais do PARCSN
  static List<PertsnErrorInfo> getErros() {
    return _erros.values.where((e) => e.tipo == PertsnErrorType.erro).toList();
  }

  /// Obtém todos os sucessos do PARCSN
  static List<PertsnErrorInfo> getSucessos() {
    return _erros.values
        .where((e) => e.tipo == PertsnErrorType.sucesso)
        .toList();
  }

  /// Mapa de erros conhecidos do PARCSN
  static final Map<String, PertsnErrorInfo> _erros = {
    // Sucessos
    '[Sucesso-PARCSN]': PertsnErrorInfo(
      codigo: '[Sucesso-PARCSN]',
      tipo: PertsnErrorType.sucesso,
      categoria: PertsnErrorCategory.sucesso,
      descricao: 'Requisição efetuada com sucesso',
      solucao: 'Operação realizada com sucesso',
    ),

    // Avisos
    '[Aviso-PARCSN-001]': PertsnErrorInfo(
      codigo: '[Aviso-PARCSN-001]',
      tipo: PertsnErrorType.aviso,
      categoria: PertsnErrorCategory.aviso,
      descricao: 'Nenhum parcelamento encontrado para o contribuinte',
      solucao:
          'Verifique se o CNPJ está correto e se possui parcelamentos ativos',
    ),

    '[Aviso-PARCSN-002]': PertsnErrorInfo(
      codigo: '[Aviso-PARCSN-002]',
      tipo: PertsnErrorType.aviso,
      categoria: PertsnErrorCategory.aviso,
      descricao: 'Parcelamento não encontrado',
      solucao: 'Verifique se o número do parcelamento está correto',
    ),

    '[Aviso-PARCSN-003]': PertsnErrorInfo(
      codigo: '[Aviso-PARCSN-003]',
      tipo: PertsnErrorType.aviso,
      categoria: PertsnErrorCategory.aviso,
      descricao: 'Nenhuma parcela disponível para impressão',
      solucao: 'Verifique se existem parcelas pendentes de pagamento',
    ),

    '[Aviso-PARCSN-004]': PertsnErrorInfo(
      codigo: '[Aviso-PARCSN-004]',
      tipo: PertsnErrorType.aviso,
      categoria: PertsnErrorCategory.aviso,
      descricao: 'Parcela já foi paga',
      solucao: 'Verifique o status da parcela antes de tentar emitir o DAS',
    ),

    // Erros de entrada incorreta
    '[Erro-PARCSN-001]': PertsnErrorInfo(
      codigo: '[Erro-PARCSN-001]',
      tipo: PertsnErrorType.erro,
      categoria: PertsnErrorCategory.entradaIncorreta,
      descricao: 'CNPJ do contribuinte inválido',
      solucao: 'Verifique se o CNPJ está correto e possui 14 dígitos',
    ),

    '[Erro-PARCSN-002]': PertsnErrorInfo(
      codigo: '[Erro-PARCSN-002]',
      tipo: PertsnErrorType.erro,
      categoria: PertsnErrorCategory.entradaIncorreta,
      descricao: 'Tipo de contribuinte inválido',
      solucao: 'PARCSN aceita apenas contribuintes do tipo 2 (Pessoa Jurídica)',
    ),

    '[Erro-PARCSN-003]': PertsnErrorInfo(
      codigo: '[Erro-PARCSN-003]',
      tipo: PertsnErrorType.erro,
      categoria: PertsnErrorCategory.entradaIncorreta,
      descricao: 'Número do parcelamento inválido',
      solucao: 'Verifique se o número do parcelamento está correto',
    ),

    '[Erro-PARCSN-004]': PertsnErrorInfo(
      codigo: '[Erro-PARCSN-004]',
      tipo: PertsnErrorType.erro,
      categoria: PertsnErrorCategory.entradaIncorreta,
      descricao: 'Ano/mês da parcela inválido',
      solucao: 'Verifique se o ano/mês está no formato AAAAMM',
    ),

    '[Erro-PARCSN-005]': PertsnErrorInfo(
      codigo: '[Erro-PARCSN-005]',
      tipo: PertsnErrorType.erro,
      categoria: PertsnErrorCategory.entradaIncorreta,
      descricao: 'Parcela para emitir inválida',
      solucao: 'Verifique se a parcela está no formato AAAAMM e é válida',
    ),

    // Erros gerais
    '[Erro-PARCSN-100]': PertsnErrorInfo(
      codigo: '[Erro-PARCSN-100]',
      tipo: PertsnErrorType.erro,
      categoria: PertsnErrorCategory.sistema,
      descricao: 'Erro interno do sistema PARCSN',
      solucao:
          'Tente novamente em alguns minutos. Se o erro persistir, entre em contato com o suporte',
    ),

    '[Erro-PARCSN-101]': PertsnErrorInfo(
      codigo: '[Erro-PARCSN-101]',
      tipo: PertsnErrorType.erro,
      categoria: PertsnErrorCategory.sistema,
      descricao: 'Sistema PARCSN temporariamente indisponível',
      solucao: 'Tente novamente em alguns minutos',
    ),

    '[Erro-PARCSN-102]': PertsnErrorInfo(
      codigo: '[Erro-PARCSN-102]',
      tipo: PertsnErrorType.erro,
      categoria: PertsnErrorCategory.sistema,
      descricao: 'Timeout na comunicação com o sistema PARCSN',
      solucao: 'Verifique sua conexão com a internet e tente novamente',
    ),

    '[Erro-PARCSN-103]': PertsnErrorInfo(
      codigo: '[Erro-PARCSN-103]',
      tipo: PertsnErrorType.erro,
      categoria: PertsnErrorCategory.sistema,
      descricao: 'Erro na geração do PDF do DAS',
      solucao:
          'Tente novamente. Se o erro persistir, entre em contato com o suporte',
    ),

    // Erros de autenticação
    '[Erro-PARCSN-200]': PertsnErrorInfo(
      codigo: '[Erro-PARCSN-200]',
      tipo: PertsnErrorType.erro,
      categoria: PertsnErrorCategory.autenticacao,
      descricao: 'Token de autenticação inválido',
      solucao: 'Verifique se o token JWT está correto e não expirou',
    ),

    '[Erro-PARCSN-201]': PertsnErrorInfo(
      codigo: '[Erro-PARCSN-201]',
      tipo: PertsnErrorType.erro,
      categoria: PertsnErrorCategory.autenticacao,
      descricao: 'Token de autenticação expirado',
      solucao: 'Renove o token de autenticação',
    ),

    '[Erro-PARCSN-202]': PertsnErrorInfo(
      codigo: '[Erro-PARCSN-202]',
      tipo: PertsnErrorType.erro,
      categoria: PertsnErrorCategory.autenticacao,
      descricao: 'Acesso não autorizado ao sistema PARCSN',
      solucao: 'Verifique se você tem permissão para acessar este serviço',
    ),

    // Erros de negócio
    '[Erro-PARCSN-300]': PertsnErrorInfo(
      codigo: '[Erro-PARCSN-300]',
      tipo: PertsnErrorType.erro,
      categoria: PertsnErrorCategory.negocio,
      descricao: 'Contribuinte não possui parcelamentos ativos',
      solucao:
          'Verifique se o contribuinte possui parcelamentos no sistema PARCSN',
    ),

    '[Erro-PARCSN-301]': PertsnErrorInfo(
      codigo: '[Erro-PARCSN-301]',
      tipo: PertsnErrorType.erro,
      categoria: PertsnErrorCategory.negocio,
      descricao: 'Parcelamento já foi encerrado',
      solucao: 'Verifique o status do parcelamento',
    ),

    '[Erro-PARCSN-302]': PertsnErrorInfo(
      codigo: '[Erro-PARCSN-302]',
      tipo: PertsnErrorType.erro,
      categoria: PertsnErrorCategory.negocio,
      descricao: 'Parcela não está disponível para emissão',
      solucao: 'Verifique se a parcela está pendente de pagamento',
    ),

    '[Erro-PARCSN-303]': PertsnErrorInfo(
      codigo: '[Erro-PARCSN-303]',
      tipo: PertsnErrorType.erro,
      categoria: PertsnErrorCategory.negocio,
      descricao: 'Parcela já foi emitida',
      solucao: 'Verifique se a parcela já possui DAS emitido',
    ),
  };
}

/// Análise de erro do PARCSN
class PertsnErrorAnalysis {
  final String codigo;
  final String mensagem;
  final PertsnErrorType tipo;
  final PertsnErrorCategory categoria;
  final String descricao;
  final String solucao;
  final bool isConhecido;

  PertsnErrorAnalysis({
    required this.codigo,
    required this.mensagem,
    required this.tipo,
    required this.categoria,
    required this.descricao,
    required this.solucao,
    required this.isConhecido,
  });

  /// Verifica se é um erro crítico que impede a operação
  bool get isErroCritico =>
      tipo == PertsnErrorType.erro && categoria == PertsnErrorCategory.sistema;

  /// Verifica se é um erro de entrada que pode ser corrigido pelo usuário
  bool get isErroEntrada => categoria == PertsnErrorCategory.entradaIncorreta;

  /// Verifica se é apenas um aviso
  bool get isApenasAviso => tipo == PertsnErrorType.aviso;

  /// Verifica se é um sucesso
  bool get isSucesso => tipo == PertsnErrorType.sucesso;

  @override
  String toString() {
    return 'PertsnErrorAnalysis(codigo: $codigo, tipo: $tipo, categoria: $categoria, conhecido: $isConhecido)';
  }
}

/// Informações sobre um erro específico do PARCSN
class PertsnErrorInfo {
  final String codigo;
  final PertsnErrorType tipo;
  final PertsnErrorCategory categoria;
  final String descricao;
  final String solucao;

  PertsnErrorInfo({
    required this.codigo,
    required this.tipo,
    required this.categoria,
    required this.descricao,
    required this.solucao,
  });

  @override
  String toString() {
    return 'PertsnErrorInfo(codigo: $codigo, tipo: $tipo, categoria: $categoria)';
  }
}

/// Tipos de erro do PARCSN
enum PertsnErrorType { sucesso, aviso, erro, desconhecido }

/// Categorias de erro do PARCSN
enum PertsnErrorCategory {
  sucesso,
  aviso,
  entradaIncorreta,
  sistema,
  autenticacao,
  negocio,
  outros,
}
