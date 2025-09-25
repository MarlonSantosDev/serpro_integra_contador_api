class TransmitirDeclaracaoResponse {
  final int status;
  final List<MensagemDefis> mensagens;
  final SaidaEntregar dados;

  TransmitirDeclaracaoResponse({required this.status, required this.mensagens, required this.dados});

  factory TransmitirDeclaracaoResponse.fromJson(Map<String, dynamic> json) {
    return TransmitirDeclaracaoResponse(
      status: json['status'] as int,
      mensagens: (json['mensagens'] as List<dynamic>).map((e) => MensagemDefis.fromJson(e as Map<String, dynamic>)).toList(),
      dados: SaidaEntregar.fromJson(json['dados'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados.toJson()};
  }
}

class MensagemDefis {
  final String codigo;
  final String texto;

  MensagemDefis({required this.codigo, required this.texto});

  factory MensagemDefis.fromJson(Map<String, dynamic> json) {
    return MensagemDefis(codigo: json['codigo'] as String, texto: json['texto'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'codigo': codigo, 'texto': texto};
  }
}

class SaidaEntregar {
  final String declaracaoPdf;
  final String reciboPdf;
  final String idDefis;

  SaidaEntregar({required this.declaracaoPdf, required this.reciboPdf, required this.idDefis});

  factory SaidaEntregar.fromJson(Map<String, dynamic> json) {
    return SaidaEntregar(declaracaoPdf: json['declaracaoPdf'] as String, reciboPdf: json['reciboPdf'] as String, idDefis: json['idDefis'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'declaracaoPdf': declaracaoPdf, 'reciboPdf': reciboPdf, 'idDefis': idDefis};
  }
}
