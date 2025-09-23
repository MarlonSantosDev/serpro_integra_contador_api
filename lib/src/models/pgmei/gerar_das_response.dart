class GerarDasResponse {
  final int status;
  final List<String> mensagens;
  final List<GerarDas> dados;

  GerarDasResponse({required this.status, required this.mensagens, required this.dados});

  factory GerarDasResponse.fromJson(Map<String, dynamic> json) {
    return GerarDasResponse(status: json['status'] as int, mensagens: (json['mensagens'] as List<dynamic>).map((e) => e.toString()).toList(), dados: (json['dados'] as List<dynamic>).map((e) => GerarDas.fromJson(e as Map<String, dynamic>)).toList());
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
    return GerarDas(pdf: json['pdf'] as String, cnpjCompleto: json['cnpjCompleto'] as String, detalhamento: DetalhamentoDas.fromJson(json['detalhamento'] as Map<String, dynamic>));
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

  DetalhamentoDas({required this.periodoApuracao, required this.numeroDocumento, required this.dataVencimento, required this.dataLimiteAcolhimento, required this.valores, required this.observacao1, required this.observacao2, required this.observacao3, required this.composicao});

  factory DetalhamentoDas.fromJson(Map<String, dynamic> json) {
    return DetalhamentoDas(periodoApuracao: json['periodoApuracao'] as String, numeroDocumento: json['numeroDocumento'] as String, dataVencimento: json['dataVencimento'] as String, dataLimiteAcolhimento: json['dataLimiteAcolhimento'] as String, valores: Valores.fromJson(json['valores'] as Map<String, dynamic>), observacao1: json['observacao1'] as String, observacao2: json['observacao2'] as String, observacao3: json['observacao3'] as String, composicao: (json['composicao'] as List<dynamic>).map((e) => Composicao.fromJson(e as Map<String, dynamic>)).toList());
  }

  Map<String, dynamic> toJson() {
    return {'periodoApuracao': periodoApuracao, 'numeroDocumento': numeroDocumento, 'dataVencimento': dataVencimento, 'dataLimiteAcolhimento': dataLimiteAcolhimento, 'valores': valores.toJson(), 'observacao1': observacao1, 'observacao2': observacao2, 'observacao3': observacao3, 'composicao': composicao.map((e) => e.toJson()).toList()};
  }
}

class Valores {
  final double principal;
  final double multa;
  final double juros;
  final double total;

  Valores({required this.principal, required this.multa, required this.juros, required this.total});

  factory Valores.fromJson(Map<String, dynamic> json) {
    return Valores(principal: (json['principal'] as num).toDouble(), multa: (json['multa'] as num).toDouble(), juros: (json['juros'] as num).toDouble(), total: (json['total'] as num).toDouble());
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
    return Composicao(periodoApuracao: json['periodoApuracao'] as String, codigo: json['codigo'] as String, denominacao: json['denominacao'] as String, valores: Valores.fromJson(json['valores'] as Map<String, dynamic>));
  }

  Map<String, dynamic> toJson() {
    return {'periodoApuracao': periodoApuracao, 'codigo': codigo, 'denominacao': denominacao, 'valores': valores.toJson()};
  }
}
