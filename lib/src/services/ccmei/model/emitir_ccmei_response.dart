import 'mensagem_ccmei.dart';
import 'dart:convert';

class EmitirCcmeiResponse {
  final int status;
  final List<MensagemCcmei> mensagens;
  final EmitirCcmeiDados dados;

  EmitirCcmeiResponse({
    required this.status,
    required this.mensagens,
    required this.dados,
  });

  factory EmitirCcmeiResponse.fromJson(Map<String, dynamic> json) {
    return EmitirCcmeiResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List)
          .map((e) => MensagemCcmei.fromJson(e))
          .toList(),
      dados: EmitirCcmeiDados.fromJson(
        jsonDecode(json['dados'].replaceAll('""', '","'))[0],
      ),
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

class EmitirCcmeiDados {
  final String cnpj;
  final String pdf;

  EmitirCcmeiDados({required this.cnpj, required this.pdf});

  factory EmitirCcmeiDados.fromJson(Map<String, dynamic> json) {
    return EmitirCcmeiDados(
      cnpj: json['cnpj'].toString(),
      pdf: json['pdf'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'cnpj': cnpj, 'pdf': pdf};
  }
}
