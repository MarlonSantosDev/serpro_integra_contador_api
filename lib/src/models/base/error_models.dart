/// Enums base para tipos e categorias de erro utilizados em todos os módulos de parcelamento

/// Tipos de erro base
enum ErrorType { sucesso, aviso, entradaIncorreta, erro, desconhecido }

/// Categorias de erro base
enum ErrorCategory {
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

/// Classe base para informações de erro
class ErrorInfo {
  final String codigo;
  final ErrorType tipo;
  final ErrorCategory categoria;
  final String descricao;
  final String acaoRecomendada;

  ErrorInfo({required this.codigo, required this.tipo, required this.categoria, required this.descricao, required this.acaoRecomendada});

  /// Verifica se é um erro crítico
  bool get isCritico => tipo == ErrorType.erro;

  /// Verifica se é um erro de validação
  bool get isValidacao => tipo == ErrorType.entradaIncorreta;

  /// Verifica se é um aviso
  bool get isAviso => tipo == ErrorType.aviso;

  /// Verifica se é um sucesso
  bool get isSucesso => tipo == ErrorType.sucesso;

  /// Verifica se requer ação do usuário
  bool get requerAcaoUsuario => tipo == ErrorType.entradaIncorreta;

  /// Verifica se é temporário
  bool get isTemporario =>
      categoria == ErrorCategory.conexao ||
      categoria == ErrorCategory.timeout ||
      categoria == ErrorCategory.servico ||
      categoria == ErrorCategory.manutencao;

  @override
  String toString() {
    return 'ErrorInfo(codigo: $codigo, tipo: $tipo, categoria: $categoria)';
  }
}

/// Classe base para análise de erro
class ErrorAnalysis {
  final String codigo;
  final String mensagem;
  final ErrorType tipo;
  final ErrorCategory categoria;
  final String acaoRecomendada;
  final bool isConhecido;

  ErrorAnalysis({
    required this.codigo,
    required this.mensagem,
    required this.tipo,
    required this.categoria,
    required this.acaoRecomendada,
    required this.isConhecido,
  });

  /// Verifica se é um erro de sucesso
  bool get isSucesso => tipo == ErrorType.sucesso;

  /// Verifica se é um erro de aviso
  bool get isAviso => tipo == ErrorType.aviso;

  /// Verifica se é um erro de entrada incorreta
  bool get isEntradaIncorreta => tipo == ErrorType.entradaIncorreta;

  /// Verifica se é um erro geral
  bool get isErro => tipo == ErrorType.erro;

  /// Verifica se é um erro desconhecido
  bool get isDesconhecido => tipo == ErrorType.desconhecido;

  @override
  String toString() {
    return 'ErrorAnalysis(codigo: $codigo, tipo: $tipo, categoria: $categoria, '
        'conhecido: $isConhecido)';
  }
}

/// Classe base para validações comuns
class BaseValidations {
  /// Valida um número de parcelamento
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
  static String? validarAnoMesParcela(int? anoMesParcela) {
    if (anoMesParcela == null) {
      return 'Ano/mês da parcela é obrigatório';
    }

    final anoMesStr = anoMesParcela.toString();
    if (anoMesStr.length != 6) {
      return 'Ano/mês da parcela deve ter 6 dígitos (AAAAMM)';
    }

    final ano = int.tryParse(anoMesStr.substring(0, 4));
    final mes = int.tryParse(anoMesStr.substring(4, 6));

    if (ano == null || mes == null) {
      return 'Ano/mês da parcela deve conter apenas números';
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

    // Não pode emitir parcela muito futura (mais de 1 ano)
    if (ano > anoAtual + 1) {
      return 'Não é possível emitir parcela para mais de 1 ano no futuro';
    }

    // Se for o mesmo ano, não pode ser mais de 3 meses no futuro
    if (ano == anoAtual && mes > mesAtual + 3) {
      return 'Não é possível emitir parcela para mais de 3 meses no futuro';
    }

    return null;
  }
}
