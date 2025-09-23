class EmitirCcmeiResponse {
  final int status;
  final List<String> mensagens;
  final EmitirCcmeiDados dados;

  EmitirCcmeiResponse({required this.status, required this.mensagens, required this.dados});

  factory EmitirCcmeiResponse.fromJson(Map<String, dynamic> json) {
    return EmitirCcmeiResponse(status: json['status'] as int, mensagens: (json['mensagens'] as List<dynamic>).map((e) => e as String).toList(), dados: EmitirCcmeiDados.fromJson(json['dados'] as Map<String, dynamic>));
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens, 'dados': dados.toJson()};
  }
}

class EmitirCcmeiDados {
  final String cnpj;
  final String pdf;

  EmitirCcmeiDados({required this.cnpj, required this.pdf});

  factory EmitirCcmeiDados.fromJson(Map<String, dynamic> json) {
    return EmitirCcmeiDados(cnpj: json['cnpj'] as String, pdf: json['pdf'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'cnpj': cnpj, 'pdf': pdf};
  }
}
