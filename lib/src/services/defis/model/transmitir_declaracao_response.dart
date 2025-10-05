import 'defis_response.dart';
import 'dart:convert';

class TransmitirDeclaracaoResponse {
  final int status;
  final List<MensagemDefis> mensagens;
  final SaidaEntregar dados;

  TransmitirDeclaracaoResponse({required this.status, required this.mensagens, required this.dados});

  factory TransmitirDeclaracaoResponse.fromJson(Map<String, dynamic> json) {
    return TransmitirDeclaracaoResponse(
      status: int.parse(json['status'].toString()),
      mensagens: (json['mensagens'] as List).map((e) => MensagemDefis.fromJson(e)).toList(),
      dados: SaidaEntregar.fromJson(jsonDecode(json['dados'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'mensagens': mensagens.map((e) => e.toJson()).toList(), 'dados': dados.toJson()};
  }
}

class SaidaEntregar {
  final String declaracaoPdf;
  final String reciboPdf;
  final String idDefis;

  SaidaEntregar({required this.declaracaoPdf, required this.reciboPdf, required this.idDefis});

  factory SaidaEntregar.fromJson(Map<String, dynamic> json) {
    return SaidaEntregar(
      declaracaoPdf: json['declaracaoPdf'].toString(),
      reciboPdf: json['reciboPdf'].toString(),
      idDefis: json['idDefis'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'declaracaoPdf': declaracaoPdf, 'reciboPdf': reciboPdf, 'idDefis': idDefis};
  }
}
