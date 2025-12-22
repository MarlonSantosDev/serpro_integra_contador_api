import 'dart:convert';
import 'defis_response.dart';

/// Response para consultar uma declaração específica transmitida na DEFIS
class ConsultarDeclaracaoEspecificaResponse {
  final int status;
  final List<MensagemDefis> mensagens;
  final DeclaracaoEspecifica dados;

  ConsultarDeclaracaoEspecificaResponse({
    required this.status,
    required this.mensagens,
    required this.dados,
  });

  factory ConsultarDeclaracaoEspecificaResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return ConsultarDeclaracaoEspecificaResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List<dynamic>)
          .map((e) => MensagemDefis.fromJson(e as Map<String, dynamic>))
          .toList(),
      dados: DeclaracaoEspecifica.fromJson(jsonDecode(json['dados'])),
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

/// Modelo para declaração específica
class DeclaracaoEspecifica {
  final String declaracaoPdf;
  final String reciboPdf;

  DeclaracaoEspecifica({required this.declaracaoPdf, required this.reciboPdf});

  factory DeclaracaoEspecifica.fromJson(Map<String, dynamic> json) {
    return DeclaracaoEspecifica(
      declaracaoPdf: json['declaracao'].toString(),
      reciboPdf: json['recibo'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'declaracao': declaracaoPdf, 'recibo': reciboPdf};
  }
}
