import 'dart:convert';
import 'defis_response.dart';

/// Response para consultar a última declaração transmitida na DEFIS
class ConsultarUltimaDeclaracaoResponse {
  final int status;
  final List<MensagemDefis> mensagens;
  final UltimaDeclaracao dados;

  ConsultarUltimaDeclaracaoResponse({required this.status, required this.mensagens, required this.dados});

  factory ConsultarUltimaDeclaracaoResponse.fromJson(Map<String, dynamic> json) {
    return ConsultarUltimaDeclaracaoResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List<dynamic>).map((e) => MensagemDefis.fromJson(e as Map<String, dynamic>)).toList(),
      dados: UltimaDeclaracao.fromJson(jsonDecode(json['dados'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados.toJson()};
  }
}

/// Modelo para última declaração
class UltimaDeclaracao {
  final String idDefis;
  final String declaracaoPdf;
  final String reciboPdf;

  UltimaDeclaracao({required this.idDefis, required this.declaracaoPdf, required this.reciboPdf});

  factory UltimaDeclaracao.fromJson(Map<String, dynamic> json) {
    return UltimaDeclaracao(idDefis: json['idDefis'].toString(), declaracaoPdf: json['declaracao'].toString(), reciboPdf: json['recibo'].toString());
  }

  Map<String, dynamic> toJson() {
    return {'idDefis': idDefis, 'declaracao': declaracaoPdf, 'recibo': reciboPdf};
  }
}
