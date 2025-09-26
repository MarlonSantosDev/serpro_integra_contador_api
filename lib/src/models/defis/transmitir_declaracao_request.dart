class TransmitirDeclaracaoRequest {
  final int ano;
  final SituacaoEspecial? situacaoEspecial;
  final int? inatividade;
  final Empresa empresa;

  TransmitirDeclaracaoRequest({
    required this.ano,
    this.situacaoEspecial,
    this.inatividade,
    required this.empresa,
  });

  factory TransmitirDeclaracaoRequest.fromJson(Map<String, dynamic> json) {
    return TransmitirDeclaracaoRequest(
      ano: json['ano'] as int,
      situacaoEspecial: json['situacaoEspecial'] != null
          ? SituacaoEspecial.fromJson(
              json['situacaoEspecial'] as Map<String, dynamic>,
            )
          : null,
      inatividade: json['inatividade'] as int?,
      empresa: Empresa.fromJson(json['empresa'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ano': ano,
      'situacaoEspecial': situacaoEspecial?.toJson(),
      'inatividade': inatividade,
      'empresa': empresa.toJson(),
    };
  }
}

class SituacaoEspecial {
  final int tipoEvento;
  final int dataEvento;

  SituacaoEspecial({required this.tipoEvento, required this.dataEvento});

  factory SituacaoEspecial.fromJson(Map<String, dynamic> json) {
    return SituacaoEspecial(
      tipoEvento: json['tipoEvento'] as int,
      dataEvento: json['dataEvento'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'tipoEvento': tipoEvento, 'dataEvento': dataEvento};
  }
}

class Empresa {
  final double ganhoCapital;
  final int qtdEmpregadoInicial;
  final int qtdEmpregadoFinal;
  final double? lucroContabil;
  final double receitaExportacaoDireta;
  final List<ComercialExportadora>? comerciaisExportadoras;
  final List<Socio> socios;
  final double? participacaoCotasTesouraria;
  final double ganhoRendaVariavel;
  final List<Doacao>? doacoesCampanhaEleitoral;
  final List<Estabelecimento> estabelecimentos;
  final NaoOptante? naoOptante;

  Empresa({
    required this.ganhoCapital,
    required this.qtdEmpregadoInicial,
    required this.qtdEmpregadoFinal,
    this.lucroContabil,
    required this.receitaExportacaoDireta,
    this.comerciaisExportadoras,
    required this.socios,
    this.participacaoCotasTesouraria,
    required this.ganhoRendaVariavel,
    this.doacoesCampanhaEleitoral,
    required this.estabelecimentos,
    this.naoOptante,
  });

  factory Empresa.fromJson(Map<String, dynamic> json) {
    return Empresa(
      ganhoCapital: (json['ganhoCapital'] as num).toDouble(),
      qtdEmpregadoInicial: json['qtdEmpregadoInicial'] as int,
      qtdEmpregadoFinal: json['qtdEmpregadoFinal'] as int,
      lucroContabil: (json['lucroContabil'] as num?)?.toDouble(),
      receitaExportacaoDireta: (json['receitaExportacaoDireta'] as num)
          .toDouble(),
      comerciaisExportadoras: json['comerciaisExportadoras'] != null
          ? (json['comerciaisExportadoras'] as List<dynamic>)
                .map(
                  (e) =>
                      ComercialExportadora.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
      socios: (json['socios'] as List<dynamic>)
          .map((e) => Socio.fromJson(e as Map<String, dynamic>))
          .toList(),
      participacaoCotasTesouraria: (json['participacaoCotasTesouraria'] as num?)
          ?.toDouble(),
      ganhoRendaVariavel: (json['ganhoRendaVariavel'] as num).toDouble(),
      doacoesCampanhaEleitoral: json['doacoesCampanhaEleitoral'] != null
          ? (json['doacoesCampanhaEleitoral'] as List<dynamic>)
                .map((e) => Doacao.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      estabelecimentos: (json['estabelecimentos'] as List<dynamic>)
          .map((e) => Estabelecimento.fromJson(e as Map<String, dynamic>))
          .toList(),
      naoOptante: json['naoOptante'] != null
          ? NaoOptante.fromJson(json['naoOptante'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ganhoCapital': ganhoCapital,
      'qtdEmpregadoInicial': qtdEmpregadoInicial,
      'qtdEmpregadoFinal': qtdEmpregadoFinal,
      'lucroContabil': lucroContabil,
      'receitaExportacaoDireta': receitaExportacaoDireta,
      'comerciaisExportadoras': comerciaisExportadoras
          ?.map((e) => e.toJson())
          .toList(),
      'socios': socios.map((e) => e.toJson()).toList(),
      'participacaoCotasTesouraria': participacaoCotasTesouraria,
      'ganhoRendaVariavel': ganhoRendaVariavel,
      'doacoesCampanhaEleitoral': doacoesCampanhaEleitoral
          ?.map((e) => e.toJson())
          .toList(),
      'estabelecimentos': estabelecimentos.map((e) => e.toJson()).toList(),
      'naoOptante': naoOptante?.toJson(),
    };
  }
}

class ComercialExportadora {
  final String cnpjCompleto;
  final double valor;

  ComercialExportadora({required this.cnpjCompleto, required this.valor});

  factory ComercialExportadora.fromJson(Map<String, dynamic> json) {
    return ComercialExportadora(
      cnpjCompleto: json['cnpjCompleto'] as String,
      valor: (json['valor'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'cnpjCompleto': cnpjCompleto, 'valor': valor};
  }
}

class Socio {
  final String cpf;
  final double rendimentosIsentos;
  final double rendimentosTributaveis;
  final double participacaoCapitalSocial;
  final double irRetidoFonte;

  Socio({
    required this.cpf,
    required this.rendimentosIsentos,
    required this.rendimentosTributaveis,
    required this.participacaoCapitalSocial,
    required this.irRetidoFonte,
  });

  factory Socio.fromJson(Map<String, dynamic> json) {
    return Socio(
      cpf: json['cpf'] as String,
      rendimentosIsentos: (json['rendimentosIsentos'] as num).toDouble(),
      rendimentosTributaveis: (json['rendimentosTributaveis'] as num)
          .toDouble(),
      participacaoCapitalSocial: (json['participacaoCapitalSocial'] as num)
          .toDouble(),
      irRetidoFonte: (json['irRetidoFonte'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cpf': cpf,
      'rendimentosIsentos': rendimentosIsentos,
      'rendimentosTributaveis': rendimentosTributaveis,
      'participacaoCapitalSocial': participacaoCapitalSocial,
      'irRetidoFonte': irRetidoFonte,
    };
  }
}

class Doacao {
  final String cnpjBeneficiario;
  final int tipoBeneficiario;
  final int formaDoacao;
  final double valor;

  Doacao({
    required this.cnpjBeneficiario,
    required this.tipoBeneficiario,
    required this.formaDoacao,
    required this.valor,
  });

  factory Doacao.fromJson(Map<String, dynamic> json) {
    return Doacao(
      cnpjBeneficiario: json['cnpjBeneficiario'] as String,
      tipoBeneficiario: json['tipoBeneficiario'] as int,
      formaDoacao: json['formaDoacao'] as int,
      valor: (json['valor'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cnpjBeneficiario': cnpjBeneficiario,
      'tipoBeneficiario': tipoBeneficiario,
      'formaDoacao': formaDoacao,
      'valor': valor,
    };
  }
}

class NaoOptante {
  final int administracaoTributaria;
  final String uf;
  final String codigoMunicipio;
  final String numeroProcesso;

  NaoOptante({
    required this.administracaoTributaria,
    required this.uf,
    required this.codigoMunicipio,
    required this.numeroProcesso,
  });

  factory NaoOptante.fromJson(Map<String, dynamic> json) {
    return NaoOptante(
      administracaoTributaria: json['administracaoTributaria'] as int,
      uf: json['uf'] as String,
      codigoMunicipio: json['codigoMunicipio'] as String,
      numeroProcesso: json['numeroProcesso'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'administracaoTributaria': administracaoTributaria,
      'uf': uf,
      'codigoMunicipio': codigoMunicipio,
      'numeroProcesso': numeroProcesso,
    };
  }
}

class Estabelecimento {
  final String cnpjCompleto;
  final double estoqueInicial;
  final double estoqueFinal;
  final double saldoCaixaInicial;
  final double saldoCaixaFinal;
  final double aquisicoesMercadoInterno;
  final double importacoes;
  final double totalEntradasPorTransferencia;
  final double totalSaidasPorTransferencia;
  final double totalDevolucoesVendas;
  final double totalEntradas;
  final double totalDevolucoesCompras;
  final double totalDespesas;
  final List<OperacaoInterestadual>? operacoesInterestaduais;
  final List<IssRetidoFonte>? issRetidosFonte;
  final List<PrestacaoServicoComunicacao>? prestacoesServicoComunicacao;
  final List<MudancaOutroMunicipio>? mudancaOutroMunicipio;
  final List<PrestacaoServicoTransporte>? prestacoesServicoTransporte;
  final InformacaoOpcional? informacaoOpcional;

  Estabelecimento({
    required this.cnpjCompleto,
    required this.estoqueInicial,
    required this.estoqueFinal,
    required this.saldoCaixaInicial,
    required this.saldoCaixaFinal,
    required this.aquisicoesMercadoInterno,
    required this.importacoes,
    required this.totalEntradasPorTransferencia,
    required this.totalSaidasPorTransferencia,
    required this.totalDevolucoesVendas,
    required this.totalEntradas,
    required this.totalDevolucoesCompras,
    required this.totalDespesas,
    this.operacoesInterestaduais,
    this.issRetidosFonte,
    this.prestacoesServicoComunicacao,
    this.mudancaOutroMunicipio,
    this.prestacoesServicoTransporte,
    this.informacaoOpcional,
  });

  factory Estabelecimento.fromJson(Map<String, dynamic> json) {
    return Estabelecimento(
      cnpjCompleto: json['cnpjCompleto'] as String,
      estoqueInicial: (json['estoqueInicial'] as num).toDouble(),
      estoqueFinal: (json['estoqueFinal'] as num).toDouble(),
      saldoCaixaInicial: (json['saldoCaixaInicial'] as num).toDouble(),
      saldoCaixaFinal: (json['saldoCaixaFinal'] as num).toDouble(),
      aquisicoesMercadoInterno: (json['aquisicoesMercadoInterno'] as num)
          .toDouble(),
      importacoes: (json['importacoes'] as num).toDouble(),
      totalEntradasPorTransferencia:
          (json['totalEntradasPorTransferencia'] as num).toDouble(),
      totalSaidasPorTransferencia: (json['totalSaidasPorTransferencia'] as num)
          .toDouble(),
      totalDevolucoesVendas: (json['totalDevolucoesVendas'] as num).toDouble(),
      totalEntradas: (json['totalEntradas'] as num).toDouble(),
      totalDevolucoesCompras: (json['totalDevolucoesCompras'] as num)
          .toDouble(),
      totalDespesas: (json['totalDespesas'] as num).toDouble(),
      operacoesInterestaduais: json['operacoesInterestaduais'] != null
          ? (json['operacoesInterestaduais'] as List<dynamic>)
                .map(
                  (e) =>
                      OperacaoInterestadual.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
      issRetidosFonte: json['issRetidosFonte'] != null
          ? (json['issRetidosFonte'] as List<dynamic>)
                .map((e) => IssRetidoFonte.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      prestacoesServicoComunicacao: json['prestacoesServicoComunicacao'] != null
          ? (json['prestacoesServicoComunicacao'] as List<dynamic>)
                .map(
                  (e) => PrestacaoServicoComunicacao.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList()
          : null,
      mudancaOutroMunicipio: json['mudancaOutroMunicipio'] != null
          ? (json['mudancaOutroMunicipio'] as List<dynamic>)
                .map(
                  (e) =>
                      MudancaOutroMunicipio.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
      prestacoesServicoTransporte: json['prestacoesServicoTransporte'] != null
          ? (json['prestacoesServicoTransporte'] as List<dynamic>)
                .map(
                  (e) => PrestacaoServicoTransporte.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList()
          : null,
      informacaoOpcional: json['informacaoOpcional'] != null
          ? InformacaoOpcional.fromJson(
              json['informacaoOpcional'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cnpjCompleto': cnpjCompleto,
      'estoqueInicial': estoqueInicial,
      'estoqueFinal': estoqueFinal,
      'saldoCaixaInicial': saldoCaixaInicial,
      'saldoCaixaFinal': saldoCaixaFinal,
      'aquisicoesMercadoInterno': aquisicoesMercadoInterno,
      'importacoes': importacoes,
      'totalEntradasPorTransferencia': totalEntradasPorTransferencia,
      'totalSaidasPorTransferencia': totalSaidasPorTransferencia,
      'totalDevolucoesVendas': totalDevolucoesVendas,
      'totalEntradas': totalEntradas,
      'totalDevolucoesCompras': totalDevolucoesCompras,
      'totalDespesas': totalDespesas,
      'operacoesInterestaduais': operacoesInterestaduais
          ?.map((e) => e.toJson())
          .toList(),
      'issRetidosFonte': issRetidosFonte?.map((e) => e.toJson()).toList(),
      'prestacoesServicoComunicacao': prestacoesServicoComunicacao
          ?.map((e) => e.toJson())
          .toList(),
      'mudancaOutroMunicipio': mudancaOutroMunicipio
          ?.map((e) => e.toJson())
          .toList(),
      'prestacoesServicoTransporte': prestacoesServicoTransporte
          ?.map((e) => e.toJson())
          .toList(),
      'informacaoOpcional': informacaoOpcional?.toJson(),
    };
  }
}

class OperacaoInterestadual {
  final String uf;
  final double valor;
  final int tipoOperacao;

  OperacaoInterestadual({
    required this.uf,
    required this.valor,
    required this.tipoOperacao,
  });

  factory OperacaoInterestadual.fromJson(Map<String, dynamic> json) {
    return OperacaoInterestadual(
      uf: json['uf'] as String,
      valor: (json['valor'] as num).toDouble(),
      tipoOperacao: json['tipoOperacao'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'uf': uf, 'valor': valor, 'tipoOperacao': tipoOperacao};
  }
}

class IssRetidoFonte {
  final String uf;
  final String codMunicipio;
  final double valor;

  IssRetidoFonte({
    required this.uf,
    required this.codMunicipio,
    required this.valor,
  });

  factory IssRetidoFonte.fromJson(Map<String, dynamic> json) {
    return IssRetidoFonte(
      uf: json['uf'] as String,
      codMunicipio: json['codMunicipio'] as String,
      valor: (json['valor'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'uf': uf, 'codMunicipio': codMunicipio, 'valor': valor};
  }
}

class PrestacaoServicoComunicacao {
  final String uf;
  final String codMunicipio;
  final double valor;

  PrestacaoServicoComunicacao({
    required this.uf,
    required this.codMunicipio,
    required this.valor,
  });

  factory PrestacaoServicoComunicacao.fromJson(Map<String, dynamic> json) {
    return PrestacaoServicoComunicacao(
      uf: json['uf'] as String,
      codMunicipio: json['codMunicipio'] as String,
      valor: (json['valor'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'uf': uf, 'codMunicipio': codMunicipio, 'valor': valor};
  }
}

class MudancaOutroMunicipio {
  final String uf;
  final String codMunicipio;
  final double valor;

  MudancaOutroMunicipio({
    required this.uf,
    required this.codMunicipio,
    required this.valor,
  });

  factory MudancaOutroMunicipio.fromJson(Map<String, dynamic> json) {
    return MudancaOutroMunicipio(
      uf: json['uf'] as String,
      codMunicipio: json['codMunicipio'] as String,
      valor: (json['valor'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'uf': uf, 'codMunicipio': codMunicipio, 'valor': valor};
  }
}

class PrestacaoServicoTransporte {
  final String uf;
  final String codMunicipio;
  final double valor;

  PrestacaoServicoTransporte({
    required this.uf,
    required this.codMunicipio,
    required this.valor,
  });

  factory PrestacaoServicoTransporte.fromJson(Map<String, dynamic> json) {
    return PrestacaoServicoTransporte(
      uf: json['uf'] as String,
      codMunicipio: json['codMunicipio'] as String,
      valor: (json['valor'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'uf': uf, 'codMunicipio': codMunicipio, 'valor': valor};
  }
}

class InformacaoOpcional {
  // ... campos da informação opcional

  InformacaoOpcional();

  factory InformacaoOpcional.fromJson(Map<String, dynamic> json) {
    return InformacaoOpcional();
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}
