import 'defis_enums.dart';

class TransmitirDeclaracaoRequest {
  final int ano;
  final SituacaoEspecial? situacaoEspecial;
  final RegraInatividade? inatividade;
  final Empresa empresa;

  TransmitirDeclaracaoRequest({
    required this.ano,
    this.situacaoEspecial,
    this.inatividade,
    required this.empresa,
  });

  factory TransmitirDeclaracaoRequest.fromJson(Map<String, dynamic> json) {
    return TransmitirDeclaracaoRequest(
      ano: int.parse(json['ano'].toString()),
      situacaoEspecial: json['situacaoEspecial'] != null
          ? SituacaoEspecial.fromJson(
              json['situacaoEspecial'] as Map<String, dynamic>,
            )
          : null,
      inatividade: json['inatividade'] != null
          ? RegraInatividade.fromCodigo(
              int.parse(json['inatividade'].toString()),
            )
          : null,
      empresa: Empresa.fromJson(json['empresa'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ano': ano,
      'situacaoEspecial': situacaoEspecial?.toJson(),
      'inatividade': inatividade?.codigo,
      'empresa': empresa.toJson(),
    };
  }
}

class SituacaoEspecial {
  final TipoEventoSituacaoEspecial tipoEvento;
  final int dataEvento;

  SituacaoEspecial({required this.tipoEvento, required this.dataEvento});

  factory SituacaoEspecial.fromJson(Map<String, dynamic> json) {
    return SituacaoEspecial(
      tipoEvento:
          TipoEventoSituacaoEspecial.fromCodigo(
            int.parse(json['tipoEvento'].toString()),
          ) ??
          TipoEventoSituacaoEspecial.cisaoParcial,
      dataEvento: int.parse(json['dataEvento'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {'tipoEvento': tipoEvento.codigo, 'dataEvento': dataEvento};
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
      ganhoCapital: (num.parse(json['ganhoCapital'].toString())).toDouble(),
      qtdEmpregadoInicial: int.parse(json['qtdEmpregadoInicial'].toString()),
      qtdEmpregadoFinal: int.parse(json['qtdEmpregadoFinal'].toString()),
      lucroContabil: (num.parse(json['lucroContabil'].toString())).toDouble(),
      receitaExportacaoDireta: (num.parse(
        json['receitaExportacaoDireta'].toString(),
      )).toDouble(),
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
      participacaoCotasTesouraria: (num.parse(
        json['participacaoCotasTesouraria'].toString(),
      )).toDouble(),
      ganhoRendaVariavel: (num.parse(
        json['ganhoRendaVariavel'].toString(),
      )).toDouble(),
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
      cnpjCompleto: json['cnpjCompleto'].toString(),
      valor: (num.parse(json['valor'].toString())).toDouble(),
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
      cpf: json['cpf'].toString(),
      rendimentosIsentos: (num.parse(
        json['rendimentosIsentos'].toString(),
      )).toDouble(),
      rendimentosTributaveis: (num.parse(
        json['rendimentosTributaveis'].toString(),
      )).toDouble(),
      participacaoCapitalSocial: (num.parse(
        json['participacaoCapitalSocial'].toString(),
      )).toDouble(),
      irRetidoFonte: (num.parse(json['irRetidoFonte'].toString())).toDouble(),
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
  final TipoBeneficiarioDoacao tipoBeneficiario;
  final FormaDoacao formaDoacao;
  final double valor;

  Doacao({
    required this.cnpjBeneficiario,
    required this.tipoBeneficiario,
    required this.formaDoacao,
    required this.valor,
  });

  factory Doacao.fromJson(Map<String, dynamic> json) {
    return Doacao(
      cnpjBeneficiario: json['cnpjBeneficiario'].toString(),
      tipoBeneficiario:
          TipoBeneficiarioDoacao.fromCodigo(
            int.parse(json['tipoBeneficiario'].toString()),
          ) ??
          TipoBeneficiarioDoacao.candidatoCargoPolitico,
      formaDoacao:
          FormaDoacao.fromCodigo(int.parse(json['formaDoacao'].toString())) ??
          FormaDoacao.dinheiro,
      valor: (num.parse(json['valor'].toString())).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cnpjBeneficiario': cnpjBeneficiario,
      'tipoBeneficiario': tipoBeneficiario.codigo,
      'formaDoacao': formaDoacao.codigo,
      'valor': valor,
    };
  }
}

class NaoOptante {
  final AdministracaoTributaria administracaoTributaria;
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
      administracaoTributaria:
          AdministracaoTributaria.fromCodigo(
            int.parse(json['administracaoTributaria'].toString()),
          ) ??
          AdministracaoTributaria.federal,
      uf: json['uf'].toString(),
      codigoMunicipio: json['codigoMunicipio'].toString(),
      numeroProcesso: json['numeroProcesso'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'administracaoTributaria': administracaoTributaria.codigo,
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
      cnpjCompleto: json['cnpjCompleto'].toString(),
      estoqueInicial: (num.parse(json['estoqueInicial'].toString())).toDouble(),
      estoqueFinal: (num.parse(json['estoqueFinal'].toString())).toDouble(),
      saldoCaixaInicial: (num.parse(
        json['saldoCaixaInicial'].toString(),
      )).toDouble(),
      saldoCaixaFinal: (num.parse(
        json['saldoCaixaFinal'].toString(),
      )).toDouble(),
      aquisicoesMercadoInterno: (num.parse(
        json['aquisicoesMercadoInterno'].toString(),
      )).toDouble(),
      importacoes: (num.parse(json['importacoes'].toString())).toDouble(),
      totalEntradasPorTransferencia: (num.parse(
        json['totalEntradasPorTransferencia'].toString(),
      )).toDouble(),
      totalSaidasPorTransferencia: (num.parse(
        json['totalSaidasPorTransferencia'].toString(),
      )).toDouble(),
      totalDevolucoesVendas: (num.parse(
        json['totalDevolucoesVendas'].toString(),
      )).toDouble(),
      totalEntradas: (num.parse(json['totalEntradas'].toString())).toDouble(),
      totalDevolucoesCompras: (num.parse(
        json['totalDevolucoesCompras'].toString(),
      )).toDouble(),
      totalDespesas: (num.parse(json['totalDespesas'].toString())).toDouble(),
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
  final TipoOperacao tipoOperacao;

  OperacaoInterestadual({
    required this.uf,
    required this.valor,
    required this.tipoOperacao,
  });

  factory OperacaoInterestadual.fromJson(Map<String, dynamic> json) {
    return OperacaoInterestadual(
      uf: json['uf'].toString(),
      valor: (num.parse(json['valor'].toString())).toDouble(),
      tipoOperacao:
          TipoOperacao.fromCodigo(int.parse(json['tipoOperacao'].toString())) ??
          TipoOperacao.entrada,
    );
  }

  Map<String, dynamic> toJson() {
    return {'uf': uf, 'valor': valor, 'tipoOperacao': tipoOperacao.codigo};
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
      uf: json['uf'].toString(),
      codMunicipio: json['codMunicipio'].toString(),
      valor: (num.parse(json['valor'].toString())).toDouble(),
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
      uf: json['uf'].toString(),
      codMunicipio: json['codMunicipio'].toString(),
      valor: (num.parse(json['valor'].toString())).toDouble(),
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
      uf: json['uf'].toString(),
      codMunicipio: json['codMunicipio'].toString(),
      valor: (num.parse(json['valor'].toString())).toDouble(),
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
      uf: json['uf'].toString(),
      codMunicipio: json['codMunicipio'].toString(),
      valor: (num.parse(json['valor'].toString())).toDouble(),
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
