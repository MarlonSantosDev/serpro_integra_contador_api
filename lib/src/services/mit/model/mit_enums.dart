/// Re-export do enum TipoDocumento específico para MIT
export '../../../base/tipo_documento.dart' show MitTipoDocumento;

/// Enums específicos do MIT (Módulo de Inclusão de Tributos)

/// Situação da apuração MIT
enum SituacaoApuracao {
  emEdicaoComPendencias(1, 'EM_EDICAO (com pendências)'),
  emEdicao(2, 'EM_EDICAO'),
  encerrada(3, 'ENCERRADA'),
  encerramentoEmCurso(4, 'ENCERRAMENTO_EM_CURSO');

  const SituacaoApuracao(this.codigo, this.descricao);
  final int codigo;
  final String descricao;

  static SituacaoApuracao? fromCodigo(int codigo) {
    for (final situacao in SituacaoApuracao.values) {
      if (situacao.codigo == codigo) return situacao;
    }
    return null;
  }
}

/// Qualificação da Pessoa Jurídica
enum QualificacaoPj {
  pjEmGeral(1, 'PJ em geral'),
  agenciaFomentoBanco(2, 'Agência de Fomento, Banco ou outra PJ de que trata o § 1° do art. 22 da Lei n° 8.212/1991'),
  cooperativaCredito(3, 'Cooperativa de Crédito'),
  sociedadeCorretoraSeguros(4, 'Sociedade Corretora de Seguros'),
  sociedadeSeguradora(5, 'Sociedade Seguradora e de Capitalização ou Entidade Aberta de Previdência Complementar com fins lucrativos'),
  entidadeFechadaPrevidencia(6, 'Entidade Fechada de Previdência Complementar ou Entidade Aberta de Previdência Complementar sem fins lucrativos'),
  sociedadeCooperativa(7, 'Sociedade Cooperativa'),
  sociedadeCooperativaAgropecuaria(8, 'Sociedade Cooperativa de Produção Agropecuária ou de Consumo'),
  autarquiaFundacaoPublica(9, 'Autarquia ou Fundação Pública'),
  empresaPublica(10, 'Empresa Pública, Sociedade de Economia Mista ou PJ de que trata o inc. III do art. 34 da Lei n° 10.833/2003'),
  estadoMunicipio(11, 'Estado, Distrito Federal, Município ou Órgão Público da Administração Direta'),
  maisDeUmaQualificacao(12, 'Mais de uma qualificação durante o mês');

  const QualificacaoPj(this.codigo, this.descricao);
  final int codigo;
  final String descricao;

  static QualificacaoPj? fromCodigo(int codigo) {
    for (final qualificacao in QualificacaoPj.values) {
      if (qualificacao.codigo == codigo) return qualificacao;
    }
    return null;
  }
}

/// Forma de Tributação do Lucro
enum TributacaoLucro {
  realAnual(1, 'Real Anual'),
  realTrimestral(2, 'Real Trimestral'),
  presumido(3, 'Presumido'),
  arbitrado(4, 'Arbitrado'),
  imuneIrpj(5, 'Imune do IRPJ'),
  isentaIrpj(6, 'Isenta do IRPJ'),
  optanteSimplesNacional(7, 'Optante pelo Simples Nacional');

  const TributacaoLucro(this.codigo, this.descricao);
  final int codigo;
  final String descricao;

  static TributacaoLucro? fromCodigo(int codigo) {
    for (final tributacao in TributacaoLucro.values) {
      if (tributacao.codigo == codigo) return tributacao;
    }
    return null;
  }
}

/// Critério de reconhecimento das variações monetárias
enum VariacoesMonetarias {
  regimeCaixa(1, 'Regime de Caixa'),
  regimeCompetencia(2, 'Regime de Competência'),
  regimeCaixaElevadaOscilacao(3, 'Regime de Caixa - Elevada oscilação da taxa de câmbio');

  const VariacoesMonetarias(this.codigo, this.descricao);
  final int codigo;
  final String descricao;

  static VariacoesMonetarias? fromCodigo(int codigo) {
    for (final variacao in VariacoesMonetarias.values) {
      if (variacao.codigo == codigo) return variacao;
    }
    return null;
  }
}

/// Regime de apuração do PIS/Pasep e/ou da Cofins
enum RegimePisCofins {
  naoCumulativa(1, 'Não-cumulativa'),
  cumulativa(2, 'Cumulativa'),
  naoCumulativaECumulativa(3, 'Não-cumulativa e Cumulativa'),
  naoSeAplica(4, 'Não se aplica');

  const RegimePisCofins(this.codigo, this.descricao);
  final int codigo;
  final String descricao;

  static RegimePisCofins? fromCodigo(int codigo) {
    for (final regime in RegimePisCofins.values) {
      if (regime.codigo == codigo) return regime;
    }
    return null;
  }
}

/// Tipo do evento especial
enum TipoEventoEspecial {
  extincao(1, 'Extinção'),
  fusao(2, 'Fusão'),
  cisaoTotal(3, 'Cisão Total'),
  cisaoParcial(4, 'Cisão Parcial'),
  incorporacaoIncorporada(5, 'Incorporação (incorporada)'),
  incorporacaoIncorporadora(6, 'Incorporação (incorporadora)');

  const TipoEventoEspecial(this.codigo, this.descricao);
  final int codigo;
  final String descricao;

  static TipoEventoEspecial? fromCodigo(int codigo) {
    for (final tipo in TipoEventoEspecial.values) {
      if (tipo.codigo == codigo) return tipo;
    }
    return null;
  }
}

/// Grupos de tributos MIT
enum GrupoTributo {
  irpj('IRPJ'),
  csll('CSLL'),
  pisPasep('PisPasep'),
  cofins('Cofins'),
  irrf('Irrf'),
  ipi('Ipi'),
  iof('Iof'),
  cideCombustiveis('CideCombustiveis'),
  cideRemessas('CideRemessas'),
  condecine('Condecine'),
  contribuicaoConcursoPrognosticos('ContribuicaoConcursoPrognosticos'),
  cpss('Cpss'),
  retPagamentoUnificado('RetPagamentoUnificado'),
  contribuicoesDiversas('ContribuicoesDiversas');

  const GrupoTributo(this.nome);
  final String nome;
}

/// Periodicidade dos tributos
enum PeriodicidadeTributo {
  mensal('ME'),
  trimestral('TR'),
  anual('AN');

  const PeriodicidadeTributo(this.codigo);
  final String codigo;

  static PeriodicidadeTributo? fromCodigo(String codigo) {
    for (final periodicidade in PeriodicidadeTributo.values) {
      if (periodicidade.codigo == codigo) return periodicidade;
    }
    return null;
  }
}

/// Códigos de receita mais comuns para cada tributo
class CodigosReceitaMit {
  // IRPJ - Códigos mais comuns
  static const List<String> irpj = [
    '0220-01', // IRPJ - PJ OBRIGADA AO LUCRO REAL - ENTIDADE NÃO FINANCEIRA - APURAÇÃO TRIMESTRAL
    '0231-01', // IRPJ - GANHOS LIQUIDOS EM OPERAÇOES NA BOLSA - LUCRO PRESUMIDO OU ARBITRADO
    '3225-01', // IRPJ - GANHOS LÍQUIDOS EM OPERAÇÕES NA BOLSA - SIMPLES NACIONAL
  ];

  // CSLL - Códigos mais comuns
  static const List<String> csll = [
    '248408', // CSLL - Contribuição Social sobre o Lucro Líquido
  ];

  // PIS/PASEP - Códigos mais comuns
  static const List<String> pisPasep = [
    '236208', // PIS/PASEP - Contribuição para os Programas de Integração Social
  ];

  // COFINS - Códigos mais comuns
  static const List<String> cofins = [
    '237208', // COFINS - Contribuição para o Financiamento da Seguridade Social
  ];

  // IRRF - Códigos mais comuns
  static const List<String> irrf = [
    '056108', // IRRF - Imposto sobre a Renda Retido na Fonte
  ];

  // IPI - Códigos mais comuns
  static const List<String> ipi = [
    '057108', // IPI - Imposto sobre Produtos Industrializados
  ];

  // IOF - Códigos mais comuns
  static const List<String> iof = [
    '058108', // IOF - Imposto sobre Operações de Crédito, Câmbio e Seguro
  ];

  /// Obtém códigos de receita por tributo
  static List<String> obterCodigosPorTributo(GrupoTributo tributo) {
    switch (tributo) {
      case GrupoTributo.irpj:
        return irpj;
      case GrupoTributo.csll:
        return csll;
      case GrupoTributo.pisPasep:
        return pisPasep;
      case GrupoTributo.cofins:
        return cofins;
      case GrupoTributo.irrf:
        return irrf;
      case GrupoTributo.ipi:
        return ipi;
      case GrupoTributo.iof:
        return iof;
      default:
        return [];
    }
  }
}

/// Validações específicas do MIT
class ValidacoesMit {
  /// Valida se o código de débito é válido para o tributo
  static bool validarCodigoDebito(String codigoDebito, GrupoTributo tributo) {
    final codigosValidos = CodigosReceitaMit.obterCodigosPorTributo(tributo);
    return codigosValidos.contains(codigoDebito);
  }

  /// Valida se a qualificação PJ permite o tributo
  static bool validarTributoParaQualificacao(GrupoTributo tributo, QualificacaoPj qualificacao) {
    // Estado/Município não pode ter IRPJ, CSLL, IRRF, IPI
    if (qualificacao == QualificacaoPj.estadoMunicipio) {
      return ![GrupoTributo.irpj, GrupoTributo.csll, GrupoTributo.irrf, GrupoTributo.ipi].contains(tributo);
    }

    // Outras validações específicas podem ser adicionadas aqui
    return true;
  }

  /// Valida se a tributação do lucro permite o tributo
  static bool validarTributoParaTributacao(GrupoTributo tributo, TributacaoLucro tributacao) {
    // Simples Nacional tem regras específicas
    if (tributacao == TributacaoLucro.optanteSimplesNacional) {
      return [
        GrupoTributo.iof,
        GrupoTributo.cideCombustiveis,
        GrupoTributo.cideRemessas,
        GrupoTributo.condecine,
        GrupoTributo.contribuicaoConcursoPrognosticos,
      ].contains(tributo);
    }

    return true;
  }
}
