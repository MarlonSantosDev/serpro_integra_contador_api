class ProcuracoesResponse {
  final String idSistema;
  final String idServico;
  final String status;
  final String mensagem;
  final DadosSaida dadosSaida;

  ProcuracoesResponse({required this.idSistema, required this.idServico, required this.status, required this.mensagem, required this.dadosSaida});

  factory ProcuracoesResponse.fromJson(Map<String, dynamic> json) {
    return ProcuracoesResponse(idSistema: json['idSistema'] as String, idServico: json['idServico'] as String, status: json['status'] as String, mensagem: json['mensagem'] as String, dadosSaida: DadosSaida.fromJson(json['dadosSaida'] as Map<String, dynamic>));
  }

  Map<String, dynamic> toJson() {
    return {'idSistema': idSistema, 'idServico': idServico, 'status': status, 'mensagem': mensagem, 'dadosSaida': dadosSaida.toJson()};
  }
}

class DadosSaida {
  final List<Procuracao> procuracoes;

  DadosSaida({required this.procuracoes});

  factory DadosSaida.fromJson(Map<String, dynamic> json) {
    return DadosSaida(procuracoes: (json['procuracoes'] as List<dynamic>).map((e) => Procuracao.fromJson(e as Map<String, dynamic>)).toList());
  }

  Map<String, dynamic> toJson() {
    return {'procuracoes': procuracoes.map((e) => e.toJson()).toList()};
  }
}

class Procuracao {
  final String numeroProcuracao;
  final Outorgante outorgante;
  final Outorgado outorgado;
  final String dataInicio;
  final String dataFim;
  final List<String> servicosAutorizados;

  Procuracao({required this.numeroProcuracao, required this.outorgante, required this.outorgado, required this.dataInicio, required this.dataFim, required this.servicosAutorizados});

  factory Procuracao.fromJson(Map<String, dynamic> json) {
    return Procuracao(numeroProcuracao: json['numeroProcuracao'] as String, outorgante: Outorgante.fromJson(json['outorgante'] as Map<String, dynamic>), outorgado: Outorgado.fromJson(json['outorgado'] as Map<String, dynamic>), dataInicio: json['dataInicio'] as String, dataFim: json['dataFim'] as String, servicosAutorizados: (json['servicosAutorizados'] as List<dynamic>).map((e) => e as String).toList());
  }

  Map<String, dynamic> toJson() {
    return {'numeroProcuracao': numeroProcuracao, 'outorgante': outorgante.toJson(), 'outorgado': outorgado.toJson(), 'dataInicio': dataInicio, 'dataFim': dataFim, 'servicosAutorizados': servicosAutorizados};
  }
}

class Outorgante {
  final String cnpjCpf;
  final String nome;

  Outorgante({required this.cnpjCpf, required this.nome});

  factory Outorgante.fromJson(Map<String, dynamic> json) {
    return Outorgante(cnpjCpf: json['cnpjCpf'] as String, nome: json['nome'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'cnpjCpf': cnpjCpf, 'nome': nome};
  }
}

class Outorgado {
  final String cnpjCpf;
  final String nome;

  Outorgado({required this.cnpjCpf, required this.nome});

  factory Outorgado.fromJson(Map<String, dynamic> json) {
    return Outorgado(cnpjCpf: json['cnpjCpf'] as String, nome: json['nome'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'cnpjCpf': cnpjCpf, 'nome': nome};
  }
}
