class ConsultarDadosCcmeiResponse {
  final int status;
  final List<String> mensagens;
  final ConsultarDadosCcmeiDados dados;

  ConsultarDadosCcmeiResponse({required this.status, required this.mensagens, required this.dados});

  factory ConsultarDadosCcmeiResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarDadosCcmeiResponse(
      status: json['status'] as int,
      mensagens: (json['mensagens'] as List<dynamic>).map((e) => e as String).toList(),
      dados: ConsultarDadosCcmeiDados.fromJson(json['dados'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens, 'dados': dados.toJson()};
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
  final String qrcode;

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
      cnpj: json['cnpj'] as String,
      empresario: Empresario.fromJson(json['empresario'] as Map<String, dynamic>),
      dataInicioAtividades: json['dataInicioAtividades'] as String,
      nomeEmpresarial: json['nomeEmpresarial'] as String,
      capitalSocial: (json['capitalSocial'] as num).toDouble(),
      situacaoCadastralVigente: json['situacaoCadastralVigente'] as String,
      dataInicioSituacaoCadastral: json['dataInicioSituacaoCadastral'] as String,
      enderecoComercial: EnderecoComercial.fromJson(json['enderecoComercial'] as Map<String, dynamic>),
      enquadramento: Enquadramento.fromJson(json['enquadramento'] as Map<String, dynamic>),
      atividade: Atividade.fromJson(json['atividade'] as Map<String, dynamic>),
      termoCienciaDispensa: TermoCienciaDispensa.fromJson(json['termoCienciaDispensa'] as Map<String, dynamic>),
      qrcode: json['qrcode'] as String,
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
    return Empresario(nomeCivil: json['nomeCivil'] as String, nomeSocial: json['nomeSocial'] as String?, cpf: json['cpf'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'nomeCivil': nomeCivil, 'nomeSocial': nomeSocial, 'cpf': cpf};
  }
}

class EnderecoComercial {
  final int cep;
  final String logradouro;
  final String numero;
  final String? complemento;
  final String bairro;
  final String municipio;
  final String uf;

  EnderecoComercial({
    required this.cep,
    required this.logradouro,
    required this.numero,
    this.complemento,
    required this.bairro,
    required this.municipio,
    required this.uf,
  });

  factory EnderecoComercial.fromJson(Map<String, dynamic> json) {
    return EnderecoComercial(
      cep: json['cep'] as int,
      logradouro: json['logradouro'] as String,
      numero: json['numero'] as String,
      complemento: json['complemento'] as String?,
      bairro: json['bairro'] as String,
      municipio: json['municipio'] as String,
      uf: json['uf'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'cep': cep, 'logradouro': logradouro, 'numero': numero, 'complemento': complemento, 'bairro': bairro, 'municipio': municipio, 'uf': uf};
  }
}

class Enquadramento {
  final PeriodosMei periodosMei;
  final String situacao;
  final bool optanteMei;

  Enquadramento({required this.periodosMei, required this.situacao, required this.optanteMei});

  factory Enquadramento.fromJson(Map<String, dynamic> json) {
    return Enquadramento(
      periodosMei: PeriodosMei.fromJson(json['periodosMei'] as Map<String, dynamic>),
      situacao: json['situacao'] as String,
      optanteMei: json['optanteMei'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'periodosMei': periodosMei.toJson(), 'situacao': situacao, 'optanteMei': optanteMei};
  }
}

class PeriodosMei {
  final int indice;
  final String dataInicio;
  final String dataFim;

  PeriodosMei({required this.indice, required this.dataInicio, required this.dataFim});

  factory PeriodosMei.fromJson(Map<String, dynamic> json) {
    return PeriodosMei(indice: json['indice'] as int, dataInicio: json['dataInicio'] as String, dataFim: json['dataFim'] as String);
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

  Atividade({required this.formasAtuacao, required this.ocupacaoPrincipal, required this.ocupacoesSecundarias, required this.optanteMei});

  factory Atividade.fromJson(Map<String, dynamic> json) {
    return Atividade(
      formasAtuacao: (json['formasAtuacao'] as List<dynamic>).map((e) => e as String).toList(),
      ocupacaoPrincipal: Ocupacao.fromJson(json['ocupacaoPrincipal'] as Map<String, dynamic>),
      ocupacoesSecundarias: (json['ocupacoesSecundarias'] as List<dynamic>).map((e) => Ocupacao.fromJson(e as Map<String, dynamic>)).toList(),
      optanteMei: json['optanteMei'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formasAtuacao': formasAtuacao,
      'ocupacaoPrincipal': ocupacaoPrincipal.toJson(),
      'ocupacoesSecundarias': ocupacoesSecundarias.map((e) => e.toJson()).toList(),
      'optanteMei': optanteMei,
    };
  }
}

class Ocupacao {
  final String descricaoOcupacao;
  final String codigoCNAE;
  final String descricaoCNAE;

  Ocupacao({required this.descricaoOcupacao, required this.codigoCNAE, required this.descricaoCNAE});

  factory Ocupacao.fromJson(Map<String, dynamic> json) {
    return Ocupacao(
      descricaoOcupacao: json['descricaoOcupacao'] as String,
      codigoCNAE: json['codigoCNAE'] as String,
      descricaoCNAE: json['descricaoCNAE'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'descricaoOcupacao': descricaoOcupacao, 'codigoCNAE': codigoCNAE, 'descricaoCNAE': descricaoCNAE};
  }
}

class TermoCienciaDispensa {
  final String titulo;
  final String texto;

  TermoCienciaDispensa({required this.titulo, required this.texto});

  factory TermoCienciaDispensa.fromJson(Map<String, dynamic> json) {
    return TermoCienciaDispensa(titulo: json['titulo'] as String, texto: json['texto'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'titulo': titulo, 'texto': texto};
  }
}
