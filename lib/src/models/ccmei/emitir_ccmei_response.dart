import 'mensagem_ccmei.dart';

class EmitirCcmeiResponse {
  final int status;
  final List<MensagemCcmei> mensagens;
  final EmitirCcmeiDados dados;

  EmitirCcmeiResponse({required this.status, required this.mensagens, required this.dados});

  factory EmitirCcmeiResponse.fromJson(Map<String, dynamic> json) {
    return EmitirCcmeiResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List<dynamic>).map((e) => MensagemCcmei.fromJson(e as Map<String, dynamic>)).toList(),
      dados: EmitirCcmeiDados.fromJson(json['dados'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados.toJson()};
  }
}

class EmitirCcmeiDados {
  final String cnpj;
  final String pdf;

  EmitirCcmeiDados({required this.cnpj, required this.pdf});

  factory EmitirCcmeiDados.fromJson(Map<String, dynamic> json) {
    return EmitirCcmeiDados(cnpj: json['cnpj'].toString(), pdf: json['pdf'].toString());
  }

  Map<String, dynamic> toJson() {
    return {'cnpj': cnpj, 'pdf': pdf};
  }
}
