import 'mensagem_ccmei.dart';
import 'dart:convert';

class ConsultarDadosCcmeiResponse {
  final int status;
  final List<MensagemCcmei> mensagens;
  final ConsultarDadosCcmeiDados dados;

  ConsultarDadosCcmeiResponse({
    required this.status,
    required this.mensagens,
    required this.dados,
  });

  factory ConsultarDadosCcmeiResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarDadosCcmeiResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List)
          .map((e) => MensagemCcmei.fromJson(e))
          .toList(),
      dados: ConsultarDadosCcmeiDados.fromJson(jsonDecode(json['dados'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'mensagens': mensagens.map((e) => e.toJson()).toList(),
      'dados': dados.toJson(),
    };
  }
}

class ConsultarDadosCcmeiDados {
  final String cnpj;
  final Empresario empresario;
  final String dataInicioAtividades;
  final String nomeEmpresarial;
  final double capitalSocial;
  final String situacaoCadastralVigente;
  final String dataInicioSituacaoCadastral;
  final EnderecoComercial enderecoComercial;
  final Enquadramento enquadramento;
  final Atividade atividade;
  final TermoCienciaDispensa termoCienciaDispensa;
  final String? qrcode;

  ConsultarDadosCcmeiDados({
    required this.cnpj,
    required this.empresario,
    required this.dataInicioAtividades,
    required this.nomeEmpresarial,
    required this.capitalSocial,
    required this.situacaoCadastralVigente,
    required this.dataInicioSituacaoCadastral,
    required this.enderecoComercial,
    required this.enquadramento,
    required this.atividade,
    required this.termoCienciaDispensa,
    required this.qrcode,
  });

  factory ConsultarDadosCcmeiDados.fromJson(Map<String, dynamic> json) {
    return ConsultarDadosCcmeiDados(
      cnpj: json['cnpj'].toString(),
      empresario: Empresario.fromJson(json['empresario']),
      dataInicioAtividades: json['dataInicioAtividades'].toString(),
      nomeEmpresarial: json['nomeEmpresarial'].toString(),
      capitalSocial: double.parse(json['capitalSocial'].toString()),
      situacaoCadastralVigente: json['situacaoCadastralVigente'].toString(),
      dataInicioSituacaoCadastral: json['dataInicioSituacaoCadastral']
          .toString(),
      enderecoComercial: EnderecoComercial.fromJson(json['enderecoComercial']),
      enquadramento: Enquadramento.fromJson(json['enquadramento']),
      atividade: Atividade.fromJson(json['atividade']),
      termoCienciaDispensa: TermoCienciaDispensa.fromJson(
        json['termoCienciaDispensa'],
      ),
      qrcode: json['qrcode']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cnpj': cnpj,
      'empresario': empresario.toJson(),
      'dataInicioAtividades': dataInicioAtividades,
      'nomeEmpresarial': nomeEmpresarial,
      'capitalSocial': capitalSocial,
      'situacaoCadastralVigente': situacaoCadastralVigente,
      'dataInicioSituacaoCadastral': dataInicioSituacaoCadastral,
      'enderecoComercial': enderecoComercial.toJson(),
      'enquadramento': enquadramento.toJson(),
      'atividade': atividade.toJson(),
      'termoCienciaDispensa': termoCienciaDispensa.toJson(),
      'qrcode': qrcode,
    };
  }
}

class Empresario {
  final String nomeCivil;
  final String? nomeSocial;
  final String cpf;

  Empresario({required this.nomeCivil, this.nomeSocial, required this.cpf});

  factory Empresario.fromJson(Map<String, dynamic> json) {
    return Empresario(
      nomeCivil: json['nomeCivil'].toString(),
      nomeSocial: json['nomeSocial']?.toString(),
      cpf: json['cpf'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'nomeCivil': nomeCivil, 'nomeSocial': nomeSocial, 'cpf': cpf};
  }
}

class EnderecoComercial {
  final String cep;
  final String? logradouro;
  final String numero;
  final String? complemento;
  final String bairro;
  final String municipio;
  final String uf;

  EnderecoComercial({
    required this.cep,
    this.logradouro,
    required this.numero,
    this.complemento,
    required this.bairro,
    required this.municipio,
    required this.uf,
  });

  factory EnderecoComercial.fromJson(Map<String, dynamic> json) {
    return EnderecoComercial(
      cep: json['cep'].toString(),
      logradouro: json['logradouro']?.toString(),
      numero: json['numero'].toString(),
      complemento: json['complemento']?.toString(),
      bairro: json['bairro'].toString(),
      municipio: json['municipio'].toString(),
      uf: json['uf'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cep': cep,
      'logradouro': logradouro,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'municipio': municipio,
      'uf': uf,
    };
  }
}

class Enquadramento {
  final List<PeriodosMei> periodosMei;
  final String situacao;
  final bool optanteMei;

  Enquadramento({
    required this.periodosMei,
    required this.situacao,
    required this.optanteMei,
  });

  factory Enquadramento.fromJson(Map<String, dynamic> json) {
    return Enquadramento(
      periodosMei: (json['periodosMei'] as List)
          .map((e) => PeriodosMei.fromJson(e))
          .toList(),
      situacao: json['situacao'].toString(),
      optanteMei: json['optanteMei'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'periodosMei': periodosMei.map((e) => e.toJson()).toList(),
      'situacao': situacao,
      'optanteMei': optanteMei,
    };
  }
}

class PeriodosMei {
  final int indice;
  final String dataInicio;
  final String? dataFim;

  PeriodosMei({required this.indice, required this.dataInicio, this.dataFim});

  factory PeriodosMei.fromJson(Map<String, dynamic> json) {
    return PeriodosMei(
      indice: int.parse(json['indice'].toString()),
      dataInicio: json['dataInicio'].toString(),
      dataFim: json['dataFim']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'indice': indice, 'dataInicio': dataInicio, 'dataFim': dataFim};
  }
}

class Atividade {
  final List<String> formasAtuacao;
  final Ocupacao ocupacaoPrincipal;
  final List<Ocupacao> ocupacoesSecundarias;
  final bool optanteMei;

  Atividade({
    required this.formasAtuacao,
    required this.ocupacaoPrincipal,
    required this.ocupacoesSecundarias,
    required this.optanteMei,
  });

  factory Atividade.fromJson(Map<String, dynamic> json) {
    return Atividade(
      formasAtuacao: (json['formasAtuacao'] as List)
          .map((e) => e.toString())
          .toList(),
      ocupacaoPrincipal: Ocupacao.fromJson(json['ocupacaoPrincipal']),
      ocupacoesSecundarias: (json['ocupacoesSecundarias'] as List)
          .map((e) => Ocupacao.fromJson(e))
          .toList(),
      optanteMei: json['optanteMei'] == null ? false : json['optanteMei'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formasAtuacao': formasAtuacao,
      'ocupacaoPrincipal': ocupacaoPrincipal.toJson(),
      'ocupacoesSecundarias': ocupacoesSecundarias
          .map((e) => e.toJson())
          .toList(),
      'optanteMei': optanteMei,
    };
  }
}

class Ocupacao {
  final String descricaoOcupacao;
  final String? codigoCNAE;
  final String? descricaoCNAE;

  Ocupacao({
    required this.descricaoOcupacao,
    this.codigoCNAE,
    this.descricaoCNAE,
  });

  factory Ocupacao.fromJson(Map<String, dynamic> json) {
    return Ocupacao(
      descricaoOcupacao: json['descricaoOcupacao'].toString(),
      codigoCNAE: json['codigoCNAE']?.toString(),
      descricaoCNAE: json['descricaoCNAE']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'descricaoOcupacao': descricaoOcupacao,
      'codigoCNAE': codigoCNAE,
      'descricaoCNAE': descricaoCNAE,
    };
  }
}

class TermoCienciaDispensa {
  final String titulo;
  final String texto;

  TermoCienciaDispensa({required this.titulo, required this.texto});

  factory TermoCienciaDispensa.fromJson(Map<String, dynamic> json) {
    return TermoCienciaDispensa(
      titulo: json['titulo'].toString(),
      texto: json['texto'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'titulo': titulo, 'texto': texto};
  }
}
