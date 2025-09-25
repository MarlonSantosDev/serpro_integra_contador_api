import 'dart:convert';

class GerarDasResponse {
  final int status;
  final List<String> mensagens;
  final List<GerarDas> dados;

  GerarDasResponse({required this.status, required this.mensagens, required this.dados});

  factory GerarDasResponse.fromJson(Map<String, dynamic> json) {
    return GerarDasResponse(
      status: int.parse(json['status']),
      mensagens: (json['mensagens'] as List).map((e) => e.toString()).toList(),
      dados: (jsonDecode(json['dados']) as List).map((e) => GerarDas.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens, 'dados': dados.map((e) => e.toJson()).toList()};
  }
}

class GerarDas {
  final String pdf;
  final String cnpjCompleto;
  final DetalhamentoDas detalhamento;

  GerarDas({required this.pdf, required this.cnpjCompleto, required this.detalhamento});

  factory GerarDas.fromJson(Map<String, dynamic> json) {
    return GerarDas(
      pdf: json['pdf'].toString(),
      cnpjCompleto: json['cnpjCompleto'].toString(),
      detalhamento: DetalhamentoDas.fromJson(json['detalhamento'][0]),
    );
  }

  Map<String, dynamic> toJson() {
    return {'pdf': pdf, 'cnpjCompleto': cnpjCompleto, 'detalhamento': detalhamento.toJson()};
  }
}

class DetalhamentoDas {
  final String periodoApuracao;
  final String numeroDocumento;
  final String dataVencimento;
  final String dataLimiteAcolhimento;
  final Valores valores;
  final String observacao1;
  final String observacao2;
  final String observacao3;
  final List<Composicao> composicao;

  DetalhamentoDas({
    required this.periodoApuracao,
    required this.numeroDocumento,
    required this.dataVencimento,
    required this.dataLimiteAcolhimento,
    required this.valores,
    required this.observacao1,
    required this.observacao2,
    required this.observacao3,
    required this.composicao,
  });

  factory DetalhamentoDas.fromJson(Map<String, dynamic> json) {
    return DetalhamentoDas(
      periodoApuracao: json['periodoApuracao'].toString(),
      numeroDocumento: json['numeroDocumento'].toString(),
      dataVencimento: json['dataVencimento'].toString(),
      dataLimiteAcolhimento: json['dataLimiteAcolhimento'].toString(),
      valores: Valores.fromJson(json['valores']),
      observacao1: json['observacao1'].toString(),
      observacao2: json['observacao2'].toString(),
      observacao3: json['observacao3'].toString(),
      composicao: (json['composicao'] as List).map((e) => Composicao.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'periodoApuracao': periodoApuracao,
      'numeroDocumento': numeroDocumento,
      'dataVencimento': dataVencimento,
      'dataLimiteAcolhimento': dataLimiteAcolhimento,
      'valores': valores.toJson(),
      'observacao1': observacao1,
      'observacao2': observacao2,
      'observacao3': observacao3,
      'composicao': composicao.map((e) => e.toJson()).toList(),
    };
  }
}

class Valores {
  final double principal;
  final double multa;
  final double juros;
  final double total;

  Valores({required this.principal, required this.multa, required this.juros, required this.total});

  factory Valores.fromJson(Map<String, dynamic> json) {
    return Valores(
      principal: double.parse(json['principal'].toString()),
      multa: double.parse(json['multa'].toString()),
      juros: double.parse(json['juros'].toString()),
      total: double.parse(json['total'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {'principal': principal, 'multa': multa, 'juros': juros, 'total': total};
  }
}

class Composicao {
  final String periodoApuracao;
  final String codigo;
  final String denominacao;
  final Valores valores;

  Composicao({required this.periodoApuracao, required this.codigo, required this.denominacao, required this.valores});

  factory Composicao.fromJson(Map<String, dynamic> json) {
    return Composicao(
      periodoApuracao: json['periodoApuracao'].toString(),
      codigo: json['codigo'].toString(),
      denominacao: json['denominacao'].toString(),
      valores: Valores.fromJson(json['valores'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'periodoApuracao': periodoApuracao, 'codigo': codigo, 'denominacao': denominacao, 'valores': valores.toJson()};
  }
}
