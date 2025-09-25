class CaixaPostalResponse {
  final List<Mensagem> mensagens;

  CaixaPostalResponse({required this.mensagens});

  factory CaixaPostalResponse.fromJson(Map<String, dynamic> json) {
    return CaixaPostalResponse(mensagens: (json['mensagens'] as List<dynamic>).map((e) => Mensagem.fromJson(e as Map<String, dynamic>)).toList());
  }

  Map<String, dynamic> toJson() {
    return {'mensagens': mensagens.map((e) => e.toJson()).toList()};
  }
}

class Mensagem {
  final String id;
  final String assunto;
  final String dataRecebimento;
  final bool lida;

  Mensagem({required this.id, required this.assunto, required this.dataRecebimento, required this.lida});

  factory Mensagem.fromJson(Map<String, dynamic> json) {
    return Mensagem(
      id: json['id'] as String,
      assunto: json['assunto'] as String,
      dataRecebimento: json['dataRecebimento'] as String,
      lida: json['lida'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'assunto': assunto, 'dataRecebimento': dataRecebimento, 'lida': lida};
  }
}
