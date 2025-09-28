/// Modelo de dados para entrega de declaração PGDASD
///
/// Representa os dados necessários para transmitir uma declaração do Simples Nacional
/// através do serviço TRANSDECLARACAO11
class EntregarDeclaracaoRequest {
  /// CNPJ completo sem formatação (14 dígitos)
  final String cnpjCompleto;

  /// Período de apuração da declaração em formato AAAAMM
  final int pa;

  /// Indica se a declaração deve ser transmitida
  /// No caso de "false", serão devolvidos os valores devidos sem transmissão
  final bool indicadorTransmissao;

  /// Indica se há a necessidade de comparação dos valoresParaComparacao
  /// enviados na entrada com os valores calculados antes da transmissão
  final bool indicadorComparacao;

  /// Objeto contendo os dados da declaração
  final Declaracao declaracao;

  /// Valores para comparação com o valor apurado pelo sistema
  /// Obrigatório, exceto quando não há valor devido
  final List<ValorDevido>? valoresParaComparacao;

  EntregarDeclaracaoRequest({
    required this.cnpjCompleto,
    required this.pa,
    required this.indicadorTransmissao,
    required this.indicadorComparacao,
    required this.declaracao,
    this.valoresParaComparacao,
  });

  /// Valida se o CNPJ possui 14 dígitos
  bool get isCnpjValido =>
      cnpjCompleto.length == 14 && RegExp(r'^\d{14}$').hasMatch(cnpjCompleto);

  /// Valida se o período de apuração está no formato correto (AAAAMM)
  bool get isPaValido => pa >= 201801 && pa <= 999912;

  /// Valida se todos os campos obrigatórios estão preenchidos
  bool get isValid {
    if (!isCnpjValido) return false;
    if (!isPaValido) return false;
    if (!declaracao.isValid) return false;
    return true;
  }

  Map<String, dynamic> toJson() {
    return {
      'cnpjCompleto': cnpjCompleto,
      'pa': pa,
      'indicadorTransmissao': indicadorTransmissao,
      'indicadorComparacao': indicadorComparacao,
      'declaracao': declaracao.toJson(),
      if (valoresParaComparacao != null)
        'valoresParaComparacao': valoresParaComparacao!
            .map((v) => v.toJson())
            .toList(),
    };
  }

  factory EntregarDeclaracaoRequest.fromJson(Map<String, dynamic> json) {
    return EntregarDeclaracaoRequest(
      cnpjCompleto: json['cnpjCompleto'].toString(),
      pa: int.parse(json['pa'].toString()),
      indicadorTransmissao: json['indicadorTransmissao'] as bool,
      indicadorComparacao: json['indicadorComparacao'] as bool,
      declaracao: Declaracao.fromJson(
        json['declaracao'] as Map<String, dynamic>,
      ),
      valoresParaComparacao: json['valoresParaComparacao'] != null
          ? (json['valoresParaComparacao'] as List)
                .map((v) => ValorDevido.fromJson(v))
                .toList()
          : null,
    );
  }
}

/// Objeto contendo os dados da declaração
class Declaracao {
  /// Tipo da declaração (1 = Original, 2 = Retificadora)
  final int tipoDeclaracao;

  /// Receita do mercado interno no PA de regime de competência
  final double receitaPaCompetenciaInterno;

  /// Receita do mercado externo no PA de regime de competência
  final double receitaPaCompetenciaExterno;

  /// Receita do mercado interno no PA de regime de caixa
  final double? receitaPaCaixaInterno;

  /// Receita do mercado externo no PA de regime de caixa
  final double? receitaPaCaixaExterno;

  /// Valor fixo de ICMS, deve ser maior que zero e obedecer às regras de negócio
  final double? valorFixoIcms;

  /// Valor fixo de ISS, deve ser maior que zero e obedecer às regras de negócio
  final double? valorFixoIss;

  /// Lista de receita bruta anterior
  final List<ReceitaBrutaAnterior>? receitasBrutasAnteriores;

  /// Valores de folha de salário
  final List<FolhaSalario>? folhasSalario;

  /// Informações de não optante
  final NaoOptante? naoOptante;

  /// Estabelecimentos da declaração
  final List<Estabelecimento> estabelecimentos;

  Declaracao({
    required this.tipoDeclaracao,
    required this.receitaPaCompetenciaInterno,
    required this.receitaPaCompetenciaExterno,
    this.receitaPaCaixaInterno,
    this.receitaPaCaixaExterno,
    this.valorFixoIcms,
    this.valorFixoIss,
    this.receitasBrutasAnteriores,
    this.folhasSalario,
    this.naoOptante,
    required this.estabelecimentos,
  });

  /// Valida se os valores estão dentro dos limites permitidos (0 a 99999999.99)
  bool get isValoresValidos {
    if (receitaPaCompetenciaInterno < 0 ||
        receitaPaCompetenciaInterno > 99999999.99)
      return false;
    if (receitaPaCompetenciaExterno < 0 ||
        receitaPaCompetenciaExterno > 99999999.99)
      return false;
    if (receitaPaCaixaInterno != null &&
        (receitaPaCaixaInterno! < 0 || receitaPaCaixaInterno! > 99999999.99))
      return false;
    if (receitaPaCaixaExterno != null &&
        (receitaPaCaixaExterno! < 0 || receitaPaCaixaExterno! > 99999999.99))
      return false;
    if (valorFixoIcms != null && valorFixoIcms! <= 0) return false;
    if (valorFixoIss != null && valorFixoIss! <= 0) return false;
    return true;
  }

  /// Valida se a declaração está completa
  bool get isValid {
    if (!isValoresValidos) return false;
    if (tipoDeclaracao < 1 || tipoDeclaracao > 2) return false;
    if (estabelecimentos.isEmpty) return false;
    for (final estabelecimento in estabelecimentos) {
      if (!estabelecimento.isValid) return false;
    }
    return true;
  }

  Map<String, dynamic> toJson() {
    return {
      'tipoDeclaracao': tipoDeclaracao,
      'receitaPaCompetenciaInterno': receitaPaCompetenciaInterno,
      'receitaPaCompetenciaExterno': receitaPaCompetenciaExterno,
      if (receitaPaCaixaInterno != null)
        'receitaPaCaixaInterno': receitaPaCaixaInterno,
      if (receitaPaCaixaExterno != null)
        'receitaPaCaixaExterno': receitaPaCaixaExterno,
      if (valorFixoIcms != null) 'valorFixoIcms': valorFixoIcms,
      if (valorFixoIss != null) 'valorFixoIss': valorFixoIss,
      if (receitasBrutasAnteriores != null)
        'receitasBrutasAnteriores': receitasBrutasAnteriores!
            .map((r) => r.toJson())
            .toList(),
      if (folhasSalario != null)
        'folhasSalario': folhasSalario!.map((f) => f.toJson()).toList(),
      if (naoOptante != null) 'naoOptante': naoOptante!.toJson(),
      'estabelecimentos': estabelecimentos.map((e) => e.toJson()).toList(),
    };
  }

  factory Declaracao.fromJson(Map<String, dynamic> json) {
    return Declaracao(
      tipoDeclaracao: int.parse(json['tipoDeclaracao'].toString()),
      receitaPaCompetenciaInterno: (num.parse(json['receitaPaCompetenciaInterno'].toString()))
          .toDouble(),
      receitaPaCompetenciaExterno: (num.parse(json['receitaPaCompetenciaExterno'].toString()))
          .toDouble(),
      receitaPaCaixaInterno: json['receitaPaCaixaInterno'] != null
          ? (num.parse(json['receitaPaCaixaInterno'].toString())).toDouble()
          : null,
      receitaPaCaixaExterno: json['receitaPaCaixaExterno'] != null
          ? (num.parse(json['receitaPaCaixaExterno'].toString())).toDouble()
          : null,
      valorFixoIcms: json['valorFixoIcms'] != null
          ? (num.parse(json['valorFixoIcms'].toString())).toDouble()
          : null,
      valorFixoIss: json['valorFixoIss'] != null
          ? (num.parse(json['valorFixoIss'].toString())).toDouble()
          : null,
      receitasBrutasAnteriores: json['receitasBrutasAnteriores'] != null
          ? (json['receitasBrutasAnteriores'] as List)
                .map((r) => ReceitaBrutaAnterior.fromJson(r))
                .toList()
          : null,
      folhasSalario: json['folhasSalario'] != null
          ? (json['folhasSalario'] as List)
                .map((f) => FolhaSalario.fromJson(f))
                .toList()
          : null,
      naoOptante: json['naoOptante'] != null
          ? NaoOptante.fromJson(json['naoOptante'])
          : null,
      estabelecimentos: (json['estabelecimentos'] as List)
          .map((e) => Estabelecimento.fromJson(e))
          .toList(),
    );
  }
}

/// Receita bruta anterior
class ReceitaBrutaAnterior {
  /// Período de Apuração em formato AAAAMM
  final int pa;

  /// Valor no mercado interno
  final double valorInterno;

  /// Valor no mercado externo
  final double valorExterno;

  ReceitaBrutaAnterior({
    required this.pa,
    required this.valorInterno,
    required this.valorExterno,
  });

  /// Valida se o período está no formato correto
  bool get isPaValido => pa >= 201801 && pa <= 999912;

  /// Valida se os valores estão dentro dos limites
  bool get isValid => isPaValido && valorInterno >= 0 && valorExterno >= 0;

  Map<String, dynamic> toJson() {
    return {
      'pa': pa,
      'valorInterno': valorInterno,
      'valorExterno': valorExterno,
    };
  }

  factory ReceitaBrutaAnterior.fromJson(Map<String, dynamic> json) {
    return ReceitaBrutaAnterior(
      pa: int.parse(json['pa'].toString()),
      valorInterno: (num.parse(json['valorInterno'].toString())).toDouble(),
      valorExterno: (num.parse(json['valorExterno'].toString())).toDouble(),
    );
  }
}

/// Folha de salário
class FolhaSalario {
  /// Período de Apuração em formato AAAAMM
  final int pa;

  /// Valor
  final double valor;

  FolhaSalario({required this.pa, required this.valor});

  /// Valida se o período está no formato correto
  bool get isPaValido => pa >= 201801 && pa <= 999912;

  /// Valida se o valor é positivo
  bool get isValid => isPaValido && valor >= 0;

  Map<String, dynamic> toJson() {
    return {'pa': pa, 'valor': valor};
  }

  factory FolhaSalario.fromJson(Map<String, dynamic> json) {
    return FolhaSalario(
      pa: int.parse(json['pa'].toString()),
      valor: (num.parse(json['valor'].toString())).toDouble(),
    );
  }
}

/// Informações de não optante
class NaoOptante {
  /// 1 = Federal, 2 = Distrital, 3 = Estadual, 4 = Municipal
  final String esferaAdm;

  /// UF do processo
  final String uf;

  /// Código do município do processo
  final String codMunicipio;

  /// Número do processo sem formatação
  final String processo;

  NaoOptante({
    required this.esferaAdm,
    required this.uf,
    required this.codMunicipio,
    required this.processo,
  });

  /// Valida se a esfera administrativa é válida
  bool get isEsferaValida => ['1', '2', '3', '4'].contains(esferaAdm);

  /// Valida se a UF tem 2 caracteres
  bool get isUfValida => uf.length == 2;

  /// Valida se o código do município tem 4 caracteres
  bool get isCodMunicipioValido => codMunicipio.length == 4;

  /// Valida se todos os campos estão corretos
  bool get isValid =>
      isEsferaValida &&
      isUfValida &&
      isCodMunicipioValido &&
      processo.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'esferaAdm': esferaAdm,
      'uf': uf,
      'codMunicipio': codMunicipio,
      'processo': processo,
    };
  }

  factory NaoOptante.fromJson(Map<String, dynamic> json) {
    return NaoOptante(
      esferaAdm: json['esferaAdm'].toString(),
      uf: json['uf'].toString(),
      codMunicipio: json['codMunicipio'].toString(),
      processo: json['processo'].toString(),
    );
  }
}

/// Estabelecimento da declaração
class Estabelecimento {
  /// CNPJ do estabelecimento sem formatação
  final String cnpjCompleto;

  /// Atividades do estabelecimento
  final List<Atividade>? atividades;

  Estabelecimento({required this.cnpjCompleto, this.atividades});

  /// Valida se o CNPJ possui 14 dígitos
  bool get isCnpjValido =>
      cnpjCompleto.length == 14 && RegExp(r'^\d{14}$').hasMatch(cnpjCompleto);

  /// Valida se o estabelecimento está correto
  bool get isValid {
    if (!isCnpjValido) return false;
    if (atividades != null) {
      for (final atividade in atividades!) {
        if (!atividade.isValid) return false;
      }
    }
    return true;
  }

  Map<String, dynamic> toJson() {
    return {
      'cnpjCompleto': cnpjCompleto,
      if (atividades != null)
        'atividades': atividades!.map((a) => a.toJson()).toList(),
    };
  }

  factory Estabelecimento.fromJson(Map<String, dynamic> json) {
    return Estabelecimento(
      cnpjCompleto: json['cnpjCompleto'].toString(),
      atividades: json['atividades'] != null
          ? (json['atividades'] as List)
                .map((a) => Atividade.fromJson(a))
                .toList()
          : null,
    );
  }
}

/// Atividade do estabelecimento
class Atividade {
  /// ID da atividade
  final int idAtividade;

  /// Valor da atividade
  final double valorAtividade;

  /// Parcela de receita da atividade
  final List<ReceitaAtividade> receitasAtividade;

  Atividade({
    required this.idAtividade,
    required this.valorAtividade,
    required this.receitasAtividade,
  });

  /// Valida se o valor da atividade é positivo
  bool get isValorValido => valorAtividade > 0;

  /// Valida se a atividade está correta
  bool get isValid {
    if (!isValorValido) return false;
    if (receitasAtividade.isEmpty) return false;
    for (final receita in receitasAtividade) {
      if (!receita.isValid) return false;
    }
    return true;
  }

  Map<String, dynamic> toJson() {
    return {
      'idAtividade': idAtividade,
      'valorAtividade': valorAtividade,
      'receitasAtividade': receitasAtividade.map((r) => r.toJson()).toList(),
    };
  }

  factory Atividade.fromJson(Map<String, dynamic> json) {
    return Atividade(
      idAtividade: int.parse(json['idAtividade'].toString()),
      valorAtividade: (num.parse(json['valorAtividade'].toString())).toDouble(),
      receitasAtividade: (json['receitasAtividade'] as List)
          .map((r) => ReceitaAtividade.fromJson(r))
          .toList(),
    );
  }
}

/// Receita da atividade
class ReceitaAtividade {
  /// Valor da parcela
  final double valor;

  /// Código do município no caso de atividade em outro município
  final String? codigoOutroMunicipio;

  /// UF no caso de atividade em outro município/UF
  final String? outraUf;

  /// Informações de Isenção
  final List<Isencao>? isencoes;

  /// Informações de Redução
  final List<Reducao>? reducoes;

  /// Informações de qualificação tributária
  final List<QualificacaoTributaria>? qualificacoesTributarias;

  /// Informações de Exigibilidade Suspensa
  final List<ExigibilidadeSuspensa>? exigibilidadesSuspensas;

  ReceitaAtividade({
    required this.valor,
    this.codigoOutroMunicipio,
    this.outraUf,
    this.isencoes,
    this.reducoes,
    this.qualificacoesTributarias,
    this.exigibilidadesSuspensas,
  });

  /// Valida se o valor é positivo
  bool get isValorValido => valor > 0;

  /// Valida se a receita está correta
  bool get isValid {
    if (!isValorValido) return false;
    if (isencoes != null) {
      for (final isencao in isencoes!) {
        if (!isencao.isValid) return false;
      }
    }
    if (reducoes != null) {
      for (final reducao in reducoes!) {
        if (!reducao.isValid) return false;
      }
    }
    return true;
  }

  Map<String, dynamic> toJson() {
    return {
      'valor': valor,
      if (codigoOutroMunicipio != null)
        'codigoOutroMunicipio': codigoOutroMunicipio,
      if (outraUf != null) 'outraUf': outraUf,
      if (isencoes != null)
        'isencoes': isencoes!.map((i) => i.toJson()).toList(),
      if (reducoes != null)
        'reducoes': reducoes!.map((r) => r.toJson()).toList(),
      if (qualificacoesTributarias != null)
        'qualificacoesTributarias': qualificacoesTributarias!
            .map((q) => q.toJson())
            .toList(),
      if (exigibilidadesSuspensas != null)
        'exigibilidadesSuspensas': exigibilidadesSuspensas!
            .map((e) => e.toJson())
            .toList(),
    };
  }

  factory ReceitaAtividade.fromJson(Map<String, dynamic> json) {
    return ReceitaAtividade(
      valor: (num.parse(json['valor'].toString())).toDouble(),
      codigoOutroMunicipio: json['codigoOutroMunicipio']?.toString(),
      outraUf: json['outraUf']?.toString(),
      isencoes: json['isencoes'] != null
          ? (json['isencoes'] as List).map((i) => Isencao.fromJson(i)).toList()
          : null,
      reducoes: json['reducoes'] != null
          ? (json['reducoes'] as List).map((r) => Reducao.fromJson(r)).toList()
          : null,
      qualificacoesTributarias: json['qualificacoesTributarias'] != null
          ? (json['qualificacoesTributarias'] as List)
                .map((q) => QualificacaoTributaria.fromJson(q))
                .toList()
          : null,
      exigibilidadesSuspensas: json['exigibilidadesSuspensas'] != null
          ? (json['exigibilidadesSuspensas'] as List)
                .map((e) => ExigibilidadeSuspensa.fromJson(e))
                .toList()
          : null,
    );
  }
}

/// Isenção
class Isencao {
  /// Código do tributo
  final int codTributo;

  /// Valor da isenção
  final double valor;

  /// Identificador do tipo de isenção
  final int identificador;

  Isencao({
    required this.codTributo,
    required this.valor,
    required this.identificador,
  });

  /// Valida se o valor é positivo
  bool get isValid => valor > 0;

  Map<String, dynamic> toJson() {
    return {
      'codTributo': codTributo,
      'valor': valor,
      'identificador': identificador,
    };
  }

  factory Isencao.fromJson(Map<String, dynamic> json) {
    return Isencao(
      codTributo: int.parse(json['codTributo'].toString()),
      valor: (num.parse(json['valor'].toString())).toDouble(),
      identificador: int.parse(json['identificador'].toString()),
    );
  }
}

/// Redução
class Reducao {
  /// Código do tributo
  final int codTributo;

  /// Valor da redução
  final double valor;

  /// Percentual da redução
  final double percentualReducao;

  /// Identificador do tipo de redução
  final int identificador;

  Reducao({
    required this.codTributo,
    required this.valor,
    required this.percentualReducao,
    required this.identificador,
  });

  /// Valida se os valores são positivos
  bool get isValid => valor > 0 && percentualReducao > 0;

  Map<String, dynamic> toJson() {
    return {
      'codTributo': codTributo,
      'valor': valor,
      'percentualReducao': percentualReducao,
      'identificador': identificador,
    };
  }

  factory Reducao.fromJson(Map<String, dynamic> json) {
    return Reducao(
      codTributo: int.parse(json['codTributo'].toString()),
      valor: (num.parse(json['valor'].toString())).toDouble(),
      percentualReducao: (num.parse(json['percentualReducao'].toString())).toDouble(),
      identificador: int.parse(json['identificador'].toString()),
    );
  }
}

/// Qualificação Tributária
class QualificacaoTributaria {
  /// Código do tributo
  final int codigoTributo;

  /// ID da qualificação
  final int id;

  QualificacaoTributaria({required this.codigoTributo, required this.id});

  Map<String, dynamic> toJson() {
    return {'codigoTributo': codigoTributo, 'id': id};
  }

  factory QualificacaoTributaria.fromJson(Map<String, dynamic> json) {
    return QualificacaoTributaria(
      codigoTributo: int.parse(json['codigoTributo'].toString()),
      id: int.parse(json['id'].toString()),
    );
  }
}

/// Exigibilidade Suspensa
class ExigibilidadeSuspensa {
  /// Código do tributo
  final int codTributo;

  /// Número do processo da exigibilidade suspensa
  final int numeroProcesso;

  /// Código de município da exigibilidade suspensa
  final String? codMunicipio;

  /// UF da exigibilidade suspensa
  final String uf;

  /// Vara do processo da exigibilidade suspensa
  final String vara;

  /// Indicador de existência de depósito
  final bool existeDeposito;

  /// Motivo da exigibilidade suspensa
  final int motivo;

  ExigibilidadeSuspensa({
    required this.codTributo,
    required this.numeroProcesso,
    this.codMunicipio,
    required this.uf,
    required this.vara,
    required this.existeDeposito,
    required this.motivo,
  });

  /// Valida se a UF tem 2 caracteres
  bool get isValid => uf.length == 2;

  Map<String, dynamic> toJson() {
    return {
      'codTributo': codTributo,
      'numeroProcesso': numeroProcesso,
      if (codMunicipio != null) 'codMunicipio': codMunicipio,
      'uf': uf,
      'vara': vara,
      'existeDeposito': existeDeposito,
      'motivo': motivo,
    };
  }

  factory ExigibilidadeSuspensa.fromJson(Map<String, dynamic> json) {
    return ExigibilidadeSuspensa(
      codTributo: int.parse(json['codTributo'].toString()),
      numeroProcesso: int.parse(json['numeroProcesso'].toString()),
      codMunicipio: json['codMunicipio']?.toString(),
      uf: json['uf'].toString(),
      vara: json['vara'].toString(),
      existeDeposito: json['existeDeposito'] as bool,
      motivo: int.parse(json['motivo'].toString()),
    );
  }
}

/// Valor devido
class ValorDevido {
  /// Código do tributo
  final int codigoTributo;

  /// Valor devido do tributo
  final double valor;

  ValorDevido({required this.codigoTributo, required this.valor});

  /// Valida se o valor é não negativo
  bool get isValid => valor >= 0;

  Map<String, dynamic> toJson() {
    return {'codigoTributo': codigoTributo, 'valor': valor};
  }

  factory ValorDevido.fromJson(Map<String, dynamic> json) {
    return ValorDevido(
      codigoTributo: int.parse(json['codigoTributo'].toString()),
      valor: (num.parse(json['valor'].toString())).toDouble(),
    );
  }
}
