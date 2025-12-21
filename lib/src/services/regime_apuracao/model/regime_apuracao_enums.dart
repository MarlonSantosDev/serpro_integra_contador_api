/// Enums para o serviço de Regime de Apuração
///
/// Contém as constantes e tipos utilizados nos serviços de regime de apuração do Simples Nacional
library;

/// Tipos de regime de apuração disponíveis
enum TipoRegime {
  /// Regime de Competência (0)
  competencia(0, 'COMPETENCIA'),

  /// Regime de Caixa (1)
  caixa(1, 'CAIXA');

  const TipoRegime(this.codigo, this.descricao);

  /// Código numérico do regime
  final int codigo;

  /// Descrição textual do regime
  final String descricao;

  /// Converte código para enum
  static TipoRegime? fromCodigo(int codigo) {
    for (final tipo in TipoRegime.values) {
      if (tipo.codigo == codigo) return tipo;
    }
    return null;
  }

  /// Converte descrição para enum
  static TipoRegime? fromDescricao(String descricao) {
    for (final tipo in TipoRegime.values) {
      if (tipo.descricao.toUpperCase() == descricao.toUpperCase()) return tipo;
    }
    return null;
  }
}

/// Códigos de mensagens específicas do serviço de Regime de Apuração
class RegimeApuracaoMensagens {
  // Mensagens de sucesso
  static const String sucessoOpcaoRealizada = 'Sucesso-REGIME-MSG_ISN_054';
  static const String sucessoConsulta = 'Sucesso-REGIME';

  // Mensagens de erro
  static const String erroIntegraContador = 'Erro-REGIME-MSG_ISN_001';
  static const String entradaIncorretaDescritivo = 'EntradaIncorreta-REGIME-MSG_ISN_049';
  static const String entradaIncorretaAnoAnterior = 'EntradaIncorreta-REGIME-MSG_ISN_050';
  static const String entradaIncorretaAcordoResolucao = 'EntradaIncorreta-REGIME-MSG_ISN_051';
  static const String entradaIncorretaCoerencia = 'EntradaIncorreta-REGIME-MSG_ISN_053';
  static const String entradaIncorretaAnoLimites = 'EntradaIncorreta-REGIME-MSG_ISN_056';
  static const String entradaIncorretaParametroAusente = 'EntradaIncorreta-REGIME-MSG_ISN_058';
  static const String entradaIncorretaAnoFormato = 'EntradaIncorreta-REGIME-MSG_ISN_059';
  static const String entradaIncorretaTipoRegime = 'EntradaIncorreta-REGIME-MSG_ISN_060';

  // Mensagens de aviso
  static const String avisoOpcaoJaRealizada = 'Aviso-REGIME-MSG_ISN_052';
  static const String avisoNaoEncontradasOpcoes = 'Aviso-REGIME-MSG_I_055';
  static const String avisoNaoEncontradaOpcaoAno = 'Aviso-REGIME-MSG_ISN_057';
}

/// Validações específicas para o serviço de Regime de Apuração
class RegimeApuracaoValidations {
  /// Valida se o ano está dentro dos limites permitidos
  static bool isAnoValido(int ano) {
    final anoAtual = DateTime.now().year;
    return ano >= 2010 && ano <= anoAtual + 1;
  }

  /// Valida se o ano tem 4 dígitos
  static bool isAnoFormatoValido(int ano) {
    return ano >= 1000 && ano <= 9999;
  }

  /// Valida se o tipo de regime é válido
  static bool isTipoRegimeValido(int tipoRegime) {
    return tipoRegime == 0 || tipoRegime == 1;
  }

  /// Valida se o descritivo do regime é válido
  static bool isDescritivoRegimeValido(String descritivo) {
    return descritivo.toUpperCase() == 'COMPETENCIA' || descritivo.toUpperCase() == 'CAIXA';
  }

  /// Valida se o descritivo está coerente com o tipo de regime
  static bool isDescritivoCoerenteComTipo(int tipoRegime, String descritivo) {
    if (tipoRegime == 0) {
      return descritivo.toUpperCase() == 'COMPETENCIA';
    } else if (tipoRegime == 1) {
      return descritivo.toUpperCase() == 'CAIXA';
    }
    return false;
  }
}
